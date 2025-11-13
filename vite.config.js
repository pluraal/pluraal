import { defineConfig } from 'vite';
import elmWatch from 'vite-plugin-elm-watch';

export default defineConfig({
  plugins: [
    elmWatch({
      mode: 'debug',
    }),
  ],
  // Development server configuration
  server: {
    port: 3000,
    open: true,
  },
});
