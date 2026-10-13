# Test App client

React 19 frontend for the Blue-Green test app, built with Vite 8.

## Scripts

- `yarn start` - dev server with hot reload
- `yarn build` - production build into `build/`, which the Express server (`../index.js`) and the Dockerfile serve
- `yarn preview` - serve the production build locally

`vite.config.js` sets `base: "./"` so asset paths stay relative, as the old Create React App `homepage: "./"` did.
