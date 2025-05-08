#!/usr/bin/env bash
# Test harness: build the Ubuntu image, then run install.sh inside it.
#
# Usage:
#   test/run.sh                       # build + run install.sh (host arch)
#   test/run.sh install               # same
#   test/run.sh shell                 # build + drop into an interactive zsh
#   test/run.sh bash                  # build + drop into an interactive bash (post-install)
#   test/run.sh verify                # build + run the post-install verification
#   test/run.sh build                 # build the image only
#
# Environment:
#   ARCH=amd64|arm64   choose target arch (default: host)
#                      use ARCH=amd64 on Apple Silicon to test x86_64 builds

set -euo pipefail

REPO_ROOT="$(cd -P -- "$(dirname -- "$0")/.." && pwd -P)"
DOCKERFILE="$REPO_ROOT/test/Dockerfile.linux"

host_arch="$(uname -m)"
case "$host_arch" in
  arm64|aarch64) default_arch=arm64 ;;
  x86_64|amd64)  default_arch=amd64 ;;
  *)             default_arch=amd64 ;;
esac
ARCH="${ARCH:-$default_arch}"
PLATFORM="linux/${ARCH}"
IMAGE="dotfiles-linux-test:${ARCH}"

cd "$REPO_ROOT"

cmd="${1:-install}"

build() {
  echo "==> building image $IMAGE (platform $PLATFORM)"
  docker build --platform "$PLATFORM" -t "$IMAGE" -f "$DOCKERFILE" .
}

case "$cmd" in
  build)
    build
    ;;
  install)
    build
    echo "==> running install.sh in container"
    docker run --rm --platform "$PLATFORM" -i "$IMAGE"
    ;;
  shell)
    build
    docker run --rm --platform "$PLATFORM" -it "$IMAGE" /usr/bin/zsh
    ;;
  bash)
    build
    docker run --rm --platform "$PLATFORM" -it "$IMAGE" bash -c \
      '/home/tester/.dotfiles/install.sh && exec bash -i'
    ;;
  verify)
    build
    echo "==> running install.sh + verification in container"
    docker run --rm --platform "$PLATFORM" -i "$IMAGE" bash -c \
      '/home/tester/.dotfiles/install.sh && /home/tester/.dotfiles/test/verify.sh'
    ;;
  *)
    echo "unknown command: $cmd" >&2
    echo "usage: $0 [build|install|shell|verify]" >&2
    exit 2
    ;;
esac
