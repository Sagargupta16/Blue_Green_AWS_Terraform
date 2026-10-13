import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// Relative asset paths (CRA's "homepage": "./") and the build in client/build,
// which the Express server and the Dockerfile both read.
export default defineConfig({
  plugins: [react()],
  base: "./",
  build: { outDir: "build" },
});
