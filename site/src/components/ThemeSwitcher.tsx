import { useEffect, useState } from 'react';

const THEMES = [
  'nightfall',
  'dracula',
  'cyberpunk',
  'dark-neon',
  'hackerman',
  'gamecore',
  'neon-accent',
];

const DEFAULT_THEME = import.meta.env.DEFAULT_THEME || 'nightfall';

export default function ThemeSwitcher() {
  const [theme, setTheme] = useState<string>(DEFAULT_THEME);
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
    
    // Get theme from localStorage or use system preference
    const savedTheme = localStorage.getItem('theme');
    if (savedTheme && THEMES.includes(savedTheme)) {
      setTheme(savedTheme);
      document.documentElement.setAttribute('data-theme', savedTheme);
    } else if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
      setTheme(DEFAULT_THEME);
      document.documentElement.setAttribute('data-theme', DEFAULT_THEME);
    } else {
      setTheme(DEFAULT_THEME);
      document.documentElement.setAttribute('data-theme', DEFAULT_THEME);
    }
  }, []);

  const handleThemeChange = (newTheme: string) => {
    setTheme(newTheme);
    localStorage.setItem('theme', newTheme);
    document.documentElement.setAttribute('data-theme', newTheme);
  };

  if (!mounted) {
    return null;
  }

  return (
    <div className="dropdown dropdown-end">
      <label 
        tabIndex={0} 
        className="btn btn-ghost btn-sm gap-2"
        aria-label="Select theme"
      >
        <svg 
          xmlns="http://www.w3.org/2000/svg" 
          fill="none" 
          viewBox="0 0 24 24" 
          strokeWidth={1.5} 
          stroke="currentColor" 
          className="w-5 h-5"
          aria-hidden="true"
        >
          <path 
            strokeLinecap="round" 
            strokeLinejoin="round" 
            d="M9.53 16.122a3 3 0 00-5.78 1.128 2.25 2.25 0 01-2.4 2.245 4.5 4.5 0 008.4-2.245c0-.399-.078-.78-.22-1.128zm0 0a15.998 15.998 0 003.388-1.62m-5.043-.025a15.994 15.994 0 011.622-3.395m3.42 3.42a15.995 15.995 0 004.764-4.648l3.876-5.814a1.151 1.151 0 00-1.597-1.597L14.146 6.32a15.996 15.996 0 00-4.649 4.763m3.42 3.42a6.776 6.776 0 00-3.42-3.42" 
          />
        </svg>
        <span className="hidden sm:inline">{theme}</span>
      </label>
      <ul 
        tabIndex={0} 
        className="dropdown-content z-[1] menu p-2 shadow-2xl bg-base-200 rounded-box w-52 max-h-96 overflow-y-auto"
      >
        {THEMES.map((themeName) => (
          <li key={themeName}>
            <button
              className={`${theme === themeName ? 'active' : ''}`}
              onClick={() => handleThemeChange(themeName)}
              aria-pressed={theme === themeName}
            >
              {themeName}
            </button>
          </li>
        ))}
      </ul>
    </div>
  );
}
