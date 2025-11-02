#!/usr/bin/env node

/**
 * Fetch GitHub Projects v2 data or fallback to issues grouped by labels
 * This script is run during CI/CD to snapshot project board data
 */

import { writeFileSync } from 'fs';
import { join } from 'path';

const GITHUB_TOKEN = process.env.GITHUB_TOKEN || '';
const REPO_OWNER = 'cywf';
const REPO_NAME = 'the-terraformer';

interface BoardItem {
  title: string;
  status: string;
  labels: string[];
  assignees: string[];
  url: string;
  number?: number;
}

interface ProjectData {
  items: BoardItem[];
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

async function fetchIssuesAsProject(): Promise<ProjectData> {
  console.log('Fetching open issues (fallback mode)...');
  
  const issues = await fetchWithAuth(
    `https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/issues?state=open&per_page=50`
  );
  
  const items: BoardItem[] = issues.map((issue: any) => {
    // Determine status from labels
    let status = 'Todo';
    const labels = issue.labels.map((l: any) => l.name);
    
    if (labels.some((l: string) => l.includes('in progress') || l.includes('doing'))) {
      status = 'In Progress';
    } else if (labels.some((l: string) => l.includes('done') || l.includes('completed'))) {
      status = 'Done';
    }
    
    return {
      title: issue.title,
      status,
      labels,
      assignees: issue.assignees?.map((a: any) => a.login) || [],
      url: issue.html_url,
      number: issue.number,
    };
  });
  
  console.log(`✓ Fetched ${items.length} issues`);
  
  return { items };
}

async function fetchProjects(): Promise<ProjectData> {
  console.log('Fetching project board data...');
  
  try {
    // Try to fetch Projects v2 data using GraphQL
    const query = `
      query {
        repository(owner: "${REPO_OWNER}", name: "${REPO_NAME}") {
          projectsV2(first: 1) {
            nodes {
              items(first: 50) {
                nodes {
                  content {
                    ... on Issue {
                      title
                      url
                      number
                      labels(first: 10) {
                        nodes {
                          name
                        }
                      }
                      assignees(first: 5) {
                        nodes {
                          login
                        }
                      }
                    }
                  }
                  fieldValues(first: 10) {
                    nodes {
                      ... on ProjectV2ItemFieldSingleSelectValue {
                        name
                        field {
                          ... on ProjectV2SingleSelectField {
                            name
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    `;
    
    const result = await fetchWithAuth('https://api.github.com/graphql', { query });
    
    if (result.data?.repository?.projectsV2?.nodes?.[0]?.items?.nodes) {
      const projectItems = result.data.repository.projectsV2.nodes[0].items.nodes;
      
      const items: BoardItem[] = projectItems
        .filter((item: any) => item.content)
        .map((item: any) => {
          const content = item.content;
          
          // Extract status from field values
          let status = 'Todo';
          const statusField = item.fieldValues?.nodes?.find(
            (fv: any) => fv.field?.name === 'Status'
          );
          if (statusField?.name) {
            status = statusField.name;
          }
          
          return {
            title: content.title,
            status,
            labels: content.labels?.nodes?.map((l: any) => l.name) || [],
            assignees: content.assignees?.nodes?.map((a: any) => a.login) || [],
            url: content.url,
            number: content.number,
          };
        });
      
      console.log(`✓ Fetched ${items.length} project items`);
      return { items };
    }
  } catch (error) {
    console.error('Failed to fetch Projects v2, falling back to issues:', error);
  }
  
  // Fallback to issues
  return fetchIssuesAsProject();
}

async function main() {
  try {
    const projectData = await fetchProjects();
    
    const outputPath = join(process.cwd(), 'public', 'data', 'projects.json');
    writeFileSync(outputPath, JSON.stringify(projectData, null, 2));
    
    console.log(`✓ Project data saved to ${outputPath}`);
  } catch (error) {
    console.error('Failed to fetch project data:', error);
    
    // Create empty fallback
    const fallbackData: ProjectData = { items: [] };
    const outputPath = join(process.cwd(), 'public', 'data', 'projects.json');
    writeFileSync(outputPath, JSON.stringify(fallbackData, null, 2));
    console.log('✓ Created empty project data file');
  }
}

main();
