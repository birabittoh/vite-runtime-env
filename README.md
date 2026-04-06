# vite-runtime-env

Docker base image to inject environment variables at runtime into static frontends (e.g. Vite).

## Problem

Vite embeds environment variables at build time, making Docker images environment-specific.

## Solution

This image generates a `/env.js` file at container startup using environment variables.

No rebuild required.

---

## Usage

### 1. Build your Vite app

```Dockerfile
FROM node:20-alpine AS build
WORKDIR /app
COPY . .
RUN npm ci && npm run build
```

### 2. Use this image

```Dockerfile
FROM ghcr.io/birabittoh/vite-runtime-env:latest

COPY --from=build /app/dist /usr/share/nginx/html
```

---

## Run

```bash
docker run -p 8080:80 \
  -e ENV_KEYS=API_URL,APP_ENV \
  -e API_URL=https://api.example.com \
  -e APP_ENV=production \
  ghcr.io/birabittoh/vite-runtime-env
```

---

## Frontend integration

Add this to `index.html`:

```html
<script src="/env.js"></script>
```

Access variables in your app:

```js
const config = window.__ENV__;

console.log(config.API_URL);
```

---

## Notes

* `ENV_KEYS` is required
* Only variables listed in `ENV_KEYS` will be exposed
* Missing variables default to empty string

---

## Example Dockerfile (full multi-stage)

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

---

## License

MIT
