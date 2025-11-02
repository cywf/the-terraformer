#!/usr/bin/env node

/**
 * Fetch GitHub discussions data
 * This script is run during CI/CD to snapshot discussions
 */

import { writeFileSync } from 'fs';
import { join } from 'path';

const GITHUB_TOKEN = process.env.GITHUB_TOKEN || '';
const REPO_OWNER = 'cywf';
const REPO_NAME = 'the-terraformer';

interface Discussion {
  title: string;
  url: string;
  body?: string;
  category?: string;
  author?: string;
  comments?: number;
  createdAt?: string;
}

async function fetchWithAuth(url: string, body?: any) {
  const headers: HeadersInit = {
    'Content-Type': 'application/json',
    'User-Agent': 'the-terraformer-site',
  };
  
  if (GITHUB_TOKEN) {
    headers['Authorization'] = `Bearer ${GITHUB_TOKEN}`;
  }
  
  const options: RequestInit = {
    method: body ? 'POST' : 'GET',
    headers,
  };
  
  if (body) {
    options.body = JSON.stringify(body);
  }
  
  const response = await fetch(url, options);
  
  if (!response.ok) {
    throw new Error(`GitHub API error: ${response.status} ${response.statusText}`);
  }
  
  return response.json();
}

async function fetchDiscussions(): Promise<Discussion[]> {
  console.log('Fetching discussions...');
  
  // Use GraphQL API to fetch discussions
  const query = `
    query {
      repository(owner: "${REPO_OWNER}", name: "${REPO_NAME}") {
        discussions(first: 25, orderBy: {field: CREATED_AT, direction: DESC}) {
          nodes {
            title
            url
            bodyText
            category {
              name
            }
            author {
              login
            }
            comments {
              totalCount
            }
            createdAt
          }
        }
      }
    }
  `;
  
  try {
    const result = await fetchWithAuth('https://api.github.com/graphql', { query });
    
    if (result.data?.repository?.discussions?.nodes) {
      const discussions: Discussion[] = result.data.repository.discussions.nodes.map((node: any) => ({
        title: node.title,
        url: node.url,
        body: node.bodyText?.substring(0, 200) || '',
        category: node.category?.name || '',
        author: node.author?.login || 'Unknown',
        comments: node.comments?.totalCount || 0,
        createdAt: node.createdAt,
      }));
      
      console.log(`✓ Fetched ${discussions.length} discussions`);
      return discussions;
    }
  } catch (error) {
    console.error('Failed to fetch discussions using GraphQL:', error);
  }
  
  return [];
}

async function main() {
  try {
    const discussions = await fetchDiscussions();
    
    const outputPath = join(process.cwd(), 'public', 'data', 'discussions.json');
    writeFileSync(outputPath, JSON.stringify(discussions, null, 2));
    
    console.log(`✓ Discussions saved to ${outputPath}`);
  } catch (error) {
    console.error('Failed to fetch discussions:', error);
    
    // Create empty fallback
    const outputPath = join(process.cwd(), 'public', 'data', 'discussions.json');
    writeFileSync(outputPath, JSON.stringify([], null, 2));
    console.log('✓ Created empty discussions file');
  }
}

main();
