# vite-runtime-env

Docker base image to inject environment variables at runtime into static frontends (e.g. Vite).

## Why?

Vite embeds environment variables at build time, making Docker images environment-specific. This image generates a `/env.js` file at container startup that reads environment variables at runtime, no rebuild required.

## Quick start

Feed [this file](https://raw.githubusercontent.com/birabittoh/vite-runtime-env/refs/heads/main/README.md) to your favorite coding agent and it'll set it up for you.

## Usage

### 1. Load the generated file

Load `/env.js`:

```html
<script>
  const script = document.createElement('script');
  script.src = '/env.js';
  script.onerror = () => console.log('Docker env not loaded, falling back to build-time variables');
  document.head.appendChild(script);
</script>
```

Access variables:

```js
const config = window.__ENV__ || {
  API_URL: import.meta.env.VITE_API_URL || '',
  APP_ENV: 'development'
};

console.log(config.API_URL);
```

### 2. Build your docker image

```Dockerfile
# Build stage
FROM node:20-alpine AS build
WORKDIR /app
COPY . .
RUN npm ci && npm run build

# Runtime stage
FROM ghcr.io/birabittoh/vite-runtime-env:latest

COPY --from=build /app/dist /usr/share/nginx/html
```

### 3. Set your environment variables

```yaml
services:
  frontend:
    container_name: my-app
    image: my-app:latest
    restart: unless-stopped
    ports:
      - "8080:80"
    environment:
      # List keys to be exposed
      - ENV_KEYS=API_URL,APP_ENV

      # Set their values
      - API_URL=https://api.example.com
      - APP_ENV=production
```

> The healthcheck is defined in the base image and is inherited automatically — no need to redeclare it in Compose.
