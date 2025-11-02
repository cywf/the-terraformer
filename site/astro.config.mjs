import { defineConfig } from 'astro/config';
import react from '@astrojs/react';
import tailwind from '@astrojs/tailwind';

// https://astro.build/config
export default defineConfig({
  site: 'https://cywf.github.io',
  base: '/the-terraformer',
  integrations: [
    react(),
    tailwind({
      applyBaseStyles: false,
    }),
  ],
  output: 'static',
  trailingSlash: 'ignore',
  vite: {
    build: {
      // Reduce chunk size to avoid memory issues
      chunkSizeWarningLimit: 1000,
      rollupOptions: {
        output: {
          manualChunks: (id) => {
            // Keep react and chart.js together
            if (id.includes('node_modules/react') || id.includes('node_modules/react-dom')) {
              return 'react-vendor';
            }
            if (id.includes('node_modules/chart.js') || id.includes('node_modules/react-chartjs-2')) {
              return 'chart';
            }
            // Put mermaid in its own chunk to avoid bundling issues
            if (id.includes('node_modules/mermaid')) {
              return 'mermaid';
            }
            // Split other large dependencies
            if (id.includes('node_modules')) {
              return 'vendor';
            }
          },
        },
      },
    },
    ssr: {
      // Don't try to bundle mermaid during SSR
      noExternal: ['chart.js', 'react-chartjs-2'],
    },
  },
});
