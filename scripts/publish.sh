#!/bin/sh
set -e

IMAGE="birabittoh/vite-runtime-env"

if [ -z "$1" ]; then
  VERSION="latest"
else
  VERSION="$1"
fi

echo "Building image: $IMAGE:$VERSION"

docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t $IMAGE:latest \
  -t $IMAGE:$VERSION \
  --push .

echo "Done."
