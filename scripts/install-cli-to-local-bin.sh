#!/usr/bin/env bash
# Install Cilium CLI and Hubble CLI (no sudo).
# DevNet Learning Lab: default install dir is /home/developer/.local/bin (on PATH).
# Override: INSTALL_BIN_DIR=/other/path bash install-cli-to-local-bin.sh
# Pin versions: CILIUM_CLI_VERSION=v0.x HUBBLE_VERSION=v1.x

set -euo pipefail

if [[ -n "${INSTALL_BIN_DIR:-}" ]]; then
  TARGET="${INSTALL_BIN_DIR}"
elif [[ -d /home/developer ]]; then
  TARGET="/home/developer/.local/bin"
else
  TARGET="${HOME}/.local/bin"
fi
mkdir -p "${TARGET}"

case "$(uname -m)" in
  x86_64)  ARCH=amd64 ;;
  aarch64) ARCH=arm64 ;;
  arm64)   ARCH=arm64 ;;
  *) echo "unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

OS=linux
if [[ "$(uname -s)" == "Darwin" ]]; then
  OS=darwin
fi

TMP="$(mktemp -d)"
trap 'rm -rf "${TMP}"' EXIT

CILIUM_CLI_VER="${CILIUM_CLI_VERSION:-v0.16.22}"
HUBBLE_VER="${HUBBLE_VERSION:-v1.18.6}"

CILIUM_TAR="cilium-${OS}-${ARCH}.tar.gz"
HUBBLE_TAR="hubble-${OS}-${ARCH}.tar.gz"

echo "Installing cilium CLI ${CILIUM_CLI_VER} -> ${TARGET}"
cd "${TMP}"
curl -fsSL -o "${CILIUM_TAR}" \
  "https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VER}/${CILIUM_TAR}"
curl -fsSL -o "${CILIUM_TAR}.sha256sum" \
  "https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VER}/${CILIUM_TAR}.sha256sum"
sha256sum -c "${CILIUM_TAR}.sha256sum"
tar xzf "${CILIUM_TAR}" cilium
install -m 0755 cilium "${TARGET}/cilium"

echo "Installing hubble CLI ${HUBBLE_VER} -> ${TARGET}"
curl -fsSL -o "${HUBBLE_TAR}" \
  "https://github.com/cilium/hubble/releases/download/${HUBBLE_VER}/${HUBBLE_TAR}"
curl -fsSL -o "${HUBBLE_TAR}.sha256sum" \
  "https://github.com/cilium/hubble/releases/download/${HUBBLE_VER}/${HUBBLE_TAR}.sha256sum"
sha256sum -c "${HUBBLE_TAR}.sha256sum"
tar xzf "${HUBBLE_TAR}" hubble
install -m 0755 hubble "${TARGET}/hubble"

echo "Done. Ensure PATH includes ${TARGET}"
"${TARGET}/cilium" version
"${TARGET}/hubble" version
