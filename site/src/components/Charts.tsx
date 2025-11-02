import { useEffect, useRef } from 'react';
import {
  Chart as ChartJS,
  ArcElement,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  Title,
  Tooltip,
  Legend,
  type ChartConfiguration,
} from 'chart.js';

ChartJS.register(
  ArcElement,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  Title,
  Tooltip,
  Legend
);

interface LanguageData {
  [key: string]: number;
}

interface CommitActivity {
  week: number;
  total: number;
}

export function LanguageChart({ languages }: { languages: LanguageData }) {
  const chartRef = useRef<HTMLCanvasElement>(null);
  const chartInstance = useRef<ChartJS | null>(null);

  useEffect(() => {
    if (!chartRef.current) return;

    const ctx = chartRef.current.getContext('2d');
    if (!ctx) return;

    // Destroy existing chart
    if (chartInstance.current) {
      chartInstance.current.destroy();
    }

    const labels = Object.keys(languages);
    const data = Object.values(languages);
    const colors = [
      '#7c3aed', '#db2777', '#f59e0b', '#10b981', '#3b82f6',
      '#ef4444', '#8b5cf6', '#ec4899', '#06b6d4',
    ];

    const config: ChartConfiguration = {
      type: 'pie',
      data: {
        labels,
        datasets: [
          {
            data,
            backgroundColor: colors.slice(0, labels.length),
            borderColor: 'rgba(0, 0, 0, 0.5)',
            borderWidth: 1,
          },
        ],
      },
      options: {
        responsive: true,
        maintainAspectRatio: true,
        plugins: {
          legend: {
            position: 'bottom',
            labels: {
              color: 'rgba(255, 255, 255, 0.8)',
            },
          },
          title: {
            display: true,
            text: 'Language Distribution',
            color: 'rgba(255, 255, 255, 0.9)',
          },
        },
      },
    };

    chartInstance.current = new ChartJS(ctx, config);

    return () => {
      if (chartInstance.current) {
        chartInstance.current.destroy();
      }
    };
  }, [languages]);

  return <canvas ref={chartRef}></canvas>;
}

export function CommitActivityChart({ activity }: { activity: CommitActivity[] }) {
  const chartRef = useRef<HTMLCanvasElement>(null);
  const chartInstance = useRef<ChartJS | null>(null);

  useEffect(() => {
    if (!chartRef.current || !activity.length) return;

    const ctx = chartRef.current.getContext('2d');
    if (!ctx) return;

    // Destroy existing chart
    if (chartInstance.current) {
      chartInstance.current.destroy();
    }

    // Take last 12 weeks
    const last12Weeks = activity.slice(-12);
    const labels = last12Weeks.map((_, i) => `Week ${i + 1}`);
    const data = last12Weeks.map((w) => w.total);

    const config: ChartConfiguration = {
      type: 'bar',
      data: {
        labels,
        datasets: [
          {
            label: 'Commits',
            data,
            backgroundColor: 'rgba(124, 58, 237, 0.8)',
            borderColor: 'rgba(124, 58, 237, 1)',
            borderWidth: 1,
          },
        ],
      },
      options: {
        responsive: true,
        maintainAspectRatio: true,
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              color: 'rgba(255, 255, 255, 0.8)',
            },
            grid: {
              color: 'rgba(255, 255, 255, 0.1)',
            },
          },
          x: {
            ticks: {
              color: 'rgba(255, 255, 255, 0.8)',
            },
            grid: {
              color: 'rgba(255, 255, 255, 0.1)',
            },
          },
        },
        plugins: {
          legend: {
            labels: {
              color: 'rgba(255, 255, 255, 0.8)',
            },
          },
          title: {
            display: true,
            text: '12-Week Commit Activity',
            color: 'rgba(255, 255, 255, 0.9)',
          },
        },
      },
    };

    chartInstance.current = new ChartJS(ctx, config);

    return () => {
      if (chartInstance.current) {
        chartInstance.current.destroy();
      }
    };
  }, [activity]);

  return <canvas ref={chartRef}></canvas>;
}

export function StatsSkeleton() {
  return (
    <div className="animate-pulse space-y-4">
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="h-32 bg-base-300 rounded-lg"></div>
        <div className="h-32 bg-base-300 rounded-lg"></div>
        <div className="h-32 bg-base-300 rounded-lg"></div>
      </div>
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <div className="h-64 bg-base-300 rounded-lg"></div>
        <div className="h-64 bg-base-300 rounded-lg"></div>
      </div>
    </div>
  );
}
