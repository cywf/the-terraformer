import { useEffect, useRef, useState } from 'react';

interface MermaidViewerProps {
  diagrams: { name: string; content: string }[];
}

export default function MermaidViewer({ diagrams }: MermaidViewerProps) {
  const [selectedDiagram, setSelectedDiagram] = useState<string>(diagrams[0]?.name || '');
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const containerRef = useRef<HTMLDivElement>(null);
  const mermaidRef = useRef<any>(null);

  useEffect(() => {
    // Dynamically import mermaid
    import('mermaid').then((mod) => {
      mermaidRef.current = mod.default;
      mermaidRef.current.initialize({
        startOnLoad: false,
        theme: 'dark',
        themeVariables: {
          darkMode: true,
          primaryColor: '#7c3aed',
          primaryTextColor: '#fff',
          primaryBorderColor: '#db2777',
          lineColor: '#f59e0b',
          secondaryColor: '#db2777',
          tertiaryColor: '#10b981',
          background: '#0f172a',
          mainBkg: '#1e293b',
          secondBkg: '#334155',
          textColor: '#e2e8f0',
          border1: '#475569',
          border2: '#64748b',
          fontFamily: 'ui-sans-serif, system-ui, sans-serif',
        },
        securityLevel: 'loose',
      });
      setIsLoading(false);
    });
  }, []);

  useEffect(() => {
    if (!isLoading && mermaidRef.current && containerRef.current && selectedDiagram) {
      const diagram = diagrams.find((d) => d.name === selectedDiagram);
      if (diagram) {
        renderDiagram(diagram.content);
      }
    }
  }, [selectedDiagram, isLoading, diagrams]);

  const renderDiagram = async (content: string) => {
    if (!containerRef.current || !mermaidRef.current) return;

    try {
      containerRef.current.innerHTML = '';
      const div = document.createElement('div');
      div.className = 'mermaid';
      div.textContent = content;
      containerRef.current.appendChild(div);

      await mermaidRef.current.run({
        nodes: [div],
      });
    } catch (error) {
      console.error('Failed to render mermaid diagram:', error);
      if (containerRef.current) {
        containerRef.current.innerHTML = `
          <div class="alert alert-error">
            <span>Failed to render diagram. Please check the syntax.</span>
          </div>
        `;
      }
    }
  };

  if (diagrams.length === 0) {
    return (
      <div className="alert alert-info">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          className="stroke-current shrink-0 w-6 h-6"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth="2"
            d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
          ></path>
        </svg>
        <span>No diagrams available</span>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Diagram Selector */}
      {diagrams.length > 1 && (
        <div className="flex flex-wrap gap-2">
          {diagrams.map((diagram) => (
            <button
              key={diagram.name}
              onClick={() => setSelectedDiagram(diagram.name)}
              className={`btn btn-sm ${
                selectedDiagram === diagram.name ? 'btn-primary' : 'btn-outline'
              }`}
            >
              {diagram.name}
            </button>
          ))}
        </div>
      )}

      {/* Diagram Container */}
      <div className="bg-base-200 rounded-lg p-6 min-h-[400px] overflow-x-auto">
        {isLoading ? (
          <div className="flex items-center justify-center h-96">
            <span className="loading loading-spinner loading-lg"></span>
          </div>
        ) : (
          <div ref={containerRef} className="flex justify-center items-center"></div>
        )}
      </div>

      {/* Info */}
      <div className="alert alert-info">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          className="stroke-current shrink-0 w-6 h-6"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth="2"
            d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
          ></path>
        </svg>
        <span>
          Viewing: <strong>{selectedDiagram}</strong>
        </span>
      </div>
    </div>
  );
}
