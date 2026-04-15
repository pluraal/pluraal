import { useState, useEffect, Suspense } from "react";
import { useMarkdownDocument } from "./hooks/useMarkdownDocument";
import { MarkdownRenderer } from "./components/MarkdownRenderer";

interface DocEntry {
  name: string;
  path: string;
}

function DocumentViewer({ docPath }: { docPath: string }) {
  const { tree, raw, loading, error } = useMarkdownDocument(docPath);

  if (loading) return <div className="loading">Loading document…</div>;
  if (error) return <div className="error">Error: {error}</div>;
  if (!tree) return null;

  return (
    <article className="document-view">
      <MarkdownRenderer tree={tree} />
    </article>
  );
}

export function App() {
  const [documents, setDocuments] = useState<DocEntry[]>([]);
  const [selected, setSelected] = useState<string | null>(null);
  const [listError, setListError] = useState<string | null>(null);

  useEffect(() => {
    fetch("/api/documents")
      .then((res) => {
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        return res.json();
      })
      .then((docs: DocEntry[]) => {
        setDocuments(docs);
        if (docs.length > 0 && !selected) {
          setSelected(docs[0].path);
        }
      })
      .catch((err) => setListError(err.message));
  }, []);

  return (
    <div className="app-layout">
      <nav className="sidebar">
        <h1 className="sidebar-title">Pluraal</h1>
        <h2 className="sidebar-subtitle">Specification Viewer</h2>
        {listError && <p className="error">Failed to load documents: {listError}</p>}
        <ul className="doc-list">
          {documents.map((doc) => (
            <li key={doc.name}>
              <button
                className={`doc-link ${selected === doc.path ? "active" : ""}`}
                onClick={() => setSelected(doc.path)}
              >
                {doc.name}
              </button>
            </li>
          ))}
        </ul>
      </nav>
      <main className="content">
        {selected ? (
          <DocumentViewer docPath={selected} />
        ) : (
          <div className="placeholder">Select a document from the sidebar.</div>
        )}
      </main>
    </div>
  );
}
