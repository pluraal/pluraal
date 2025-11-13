// Import the compiled Elm app
import ScopeViewer from './src/ScopeViewer.elm';

// Initialize the Elm app
const app = ScopeViewer.init({
  node: document.getElementById('scope-viewer-app'),
});
