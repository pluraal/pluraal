import express from "express";
import cors from "cors";
import { readdir, readFile } from "node:fs/promises";
import { join, resolve } from "node:path";

const app = express();
const PORT = 3001;

// Reference-models directory (relative to this file -> ../specs/reference-models)
const MODELS_DIR = resolve(import.meta.dirname, "../../specs/reference-models");

app.use(cors());

/** List available reference model documents. */
app.get("/api/documents", async (_req, res) => {
  try {
    const files = await readdir(MODELS_DIR);
    const mdFiles = files
      .filter((f) => f.endsWith(".md"))
      .map((f) => ({
        name: f.replace(/\.md$/, ""),
        path: `/api/documents/${encodeURIComponent(f.replace(/\.md$/, ""))}`,
      }));
    res.json(mdFiles);
  } catch (err) {
    res.status(500).json({ error: "Failed to list documents" });
  }
});

/** Serve a single reference model document as raw markdown. */
app.get("/api/documents/:name", async (req, res) => {
  try {
    const name = decodeURIComponent(req.params.name);
    const filePath = join(MODELS_DIR, `${name}.md`);
    const content = await readFile(filePath, "utf-8");
    res.type("text/markdown").send(content);
  } catch (err) {
    res.status(404).json({ error: "Document not found" });
  }
});

app.listen(PORT, () => {
  console.log(`[dev-server] API server running at http://localhost:${PORT}`);
  console.log(`[dev-server] Serving reference models from ${MODELS_DIR}`);
});
