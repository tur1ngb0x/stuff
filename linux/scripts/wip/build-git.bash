#!/usr/bin/env bash
set -euo pipefail

CORES="$(nproc)"
GIT_VERSION="2.48.1"
DEVROOT="${HOME}/src/dev"

GIT_PREFIX="${DEVROOT}/opt/git/${GIT_VERSION}"
GIT_SRC_DIR="${DEVROOT}/src"
GIT_BUILD_DIR="${DEVROOT}/build/git-${GIT_VERSION}"
GIT_TARBALL="git-${GIT_VERSION}.tar.xz"
GIT_SRC_TREE="${GIT_SRC_DIR}/git-${GIT_VERSION}"

header() { builtin printf '\033[7m [+] %s \033[0m\n' "$*"; }

header "Creating directory layout under: ${DEVROOT}"
mkdir -p "${DEVROOT}/"{bin,opt,src,build}

header "Installing build dependencies (requires sudo)"
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    ca-certificates \
    curl \
    xz-utils \
    pkg-config \
    gettext \
    libssl-dev \
    zlib1g-dev \
    libcurl4-openssl-dev \
    libexpat1-dev \
    libpcre2-dev

header "Downloading Git ${GIT_VERSION} source"
cd "${GIT_SRC_DIR}"
if [[ ! -f "${GIT_TARBALL}" ]]; then
    curl -LO "https://www.kernel.org/pub/software/scm/git/${GIT_TARBALL}"
fi

header "Extracting source"
if [[ ! -d "${GIT_SRC_TREE}" ]]; then
    tar -xf "${GIT_TARBALL}"
fi

header "Removing previous build and install (clean rebuild)"
rm -rf "${GIT_BUILD_DIR}"
rm -rf "${GIT_PREFIX}"

header "Cleaning source tree"
make -C "${GIT_SRC_TREE}" distclean || true

header "Configuring build (out-of-tree)"
mkdir -p "${GIT_BUILD_DIR}"
cd "${GIT_BUILD_DIR}"

header "Building with ${CORES} CPU cores"
make -C "${GIT_SRC_TREE}" -j"${CORES}" \
    prefix="${GIT_PREFIX}" \
    USE_LIBPCRE2=YesPlease \
    all

header "Installing into: ${GIT_PREFIX}"
make -C "${GIT_SRC_TREE}" \
    prefix="${GIT_PREFIX}" \
    USE_LIBPCRE2=YesPlease \
    install

header "Creating symlinks in: ${DEVROOT}/bin"
ln -sf "../opt/git/${GIT_VERSION}/bin/git" "${DEVROOT}/bin/git"

header "Creating version switching symlink: opt/git/current -> ${GIT_VERSION}"
ln -sfn "${GIT_VERSION}" "${DEVROOT}/opt/git/current"

header "Updating PATH for this shell session"
export PATH="${DEVROOT}/bin:${PATH}"
hash -r || true

header "Verifying"
command -v git
git --version

header "Done"
echo "To use in future shells:"
echo "  export PATH=\"${DEVROOT}/bin:\$PATH\""

header "Ensuring DEVROOT and PATH are set in ~/.bashrc"

BASHRC="${HOME}/.bashrc"
MARK_BEGIN="# >>> devroot >>>"
MARK_END="# <<< devroot <<<"

if ! grep -qF "${MARK_BEGIN}" "${BASHRC}" 2>/dev/null; then
    {
        echo ""
        echo "${MARK_BEGIN}"
        echo "export DEVROOT=\"\$HOME/src/dev\""
        echo "export PATH=\"\$DEVROOT/bin:\$PATH\""
        echo "${MARK_END}"
    } >> "${BASHRC}"
    header "Added DEVROOT/PATH block to ${BASHRC}"
else
    header "DEVROOT/PATH block already present in ${BASHRC}"
fi

header "Printing PATH"
echo "${PATH}" | tr ':' '\n'
