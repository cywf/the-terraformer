#!/usr/bin/env node

/**
 * Fetch repository statistics from GitHub API
 * This script is run during CI/CD to snapshot repository data
 */

import { writeFileSync } from 'fs';
import { join } from 'path';

const GITHUB_TOKEN = process.env.GITHUB_TOKEN || '';
const REPO_OWNER = 'cywf';
const REPO_NAME = 'the-terraformer';

interface RepoData {
  stars: number;
  forks: number;
  watchers: number;
  languages: Record<string, number>;
  commitActivity: { week: number; total: number }[];
}

async function fetchWithAuth(url: string) {
  const headers: HeadersInit = {
    'Accept': 'application/vnd.github.v3+json',
    'User-Agent': 'the-terraformer-site',
  };
  
  if (GITHUB_TOKEN) {
    headers['Authorization'] = `Bearer ${GITHUB_TOKEN}`;
  }
  
  const response = await fetch(url, { headers });
  
  if (!response.ok) {
    throw new Error(`GitHub API error: ${response.status} ${response.statusText}`);
  }
  
  return response.json();
}

async function fetchRepoStats(): Promise<RepoData> {
  console.log('Fetching repository statistics...');
  
  // Fetch basic repo info
  const repoInfo = await fetchWithAuth(
    `https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}`
  );
  
  // Fetch languages
  const languages = await fetchWithAuth(
    `https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/languages`
  );
  
  // Fetch commit activity (52 weeks)
  const commitActivity = await fetchWithAuth(
    `https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/stats/commit_activity`
  );
  
  const stats: RepoData = {
    stars: repoInfo.stargazers_count || 0,
    forks: repoInfo.forks_count || 0,
    watchers: repoInfo.watchers_count || 0,
    languages: languages || {},
    commitActivity: commitActivity || [],
  };
  
  console.log(`✓ Fetched stats: ${stats.stars} stars, ${stats.forks} forks`);
  
  return stats;
}

async function main() {
  try {
    const stats = await fetchRepoStats();
    
    const outputPath = join(process.cwd(), 'public', 'data', 'stats.json');
    writeFileSync(outputPath, JSON.stringify(stats, null, 2));
    
    console.log(`✓ Statistics saved to ${outputPath}`);
  } catch (error) {
    console.error('Failed to fetch repository statistics:', error);
    
    // Create fallback data
    const fallbackStats: RepoData = {
      stars: 0,
      forks: 0,
      watchers: 0,
      languages: { TypeScript: 50, JavaScript: 30, HTML: 20 },
      commitActivity: [],
    };
    
    const outputPath = join(process.cwd(), 'public', 'data', 'stats.json');
    writeFileSync(outputPath, JSON.stringify(fallbackStats, null, 2));
    console.log('✓ Created fallback statistics file');
  }
}

main();
