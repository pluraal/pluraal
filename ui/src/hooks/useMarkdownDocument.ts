import { useState, useEffect } from "react";
import { unified } from "unified";
import remarkParse from "remark-parse";
import remarkGfm from "remark-gfm";
import type { Root } from "mdast";

const parser = unified().use(remarkParse).use(remarkGfm);

interface MarkdownDocumentState {
  tree: Root | null;
  raw: string;
  loading: boolean;
  error: string | null;
}

/**
 * Fetches a markdown document from the given URL and parses it into an mdast
 * syntax tree using remark-parse with GFM support.
 */
export function useMarkdownDocument(url: string): MarkdownDocumentState {
  const [state, setState] = useState<MarkdownDocumentState>({
    tree: null,
    raw: "",
    loading: true,
    error: null,
  });

  useEffect(() => {
    let cancelled = false;

    setState({ tree: null, raw: "", loading: true, error: null });

    fetch(url)
      .then((res) => {
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        return res.text();
      })
      .then((markdown) => {
        if (cancelled) return;
        const tree = parser.parse(markdown);
        setState({ tree, raw: markdown, loading: false, error: null });
      })
      .catch((err) => {
        if (cancelled) return;
        setState({ tree: null, raw: "", loading: false, error: err.message });
      });

    return () => {
      cancelled = true;
    };
  }, [url]);

  return state;
}
