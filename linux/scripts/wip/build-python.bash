#!/usr/bin/env bash
set -euo pipefail

CORES="$(nproc)"
PYTHON_VERSION="3.14.3"
DEVROOT="${HOME}/src/dev"

PY_PREFIX="${DEVROOT}/opt/python/${PYTHON_VERSION}"
PY_SRC_DIR="${DEVROOT}/src"
PY_BUILD_DIR="${DEVROOT}/build/python-${PYTHON_VERSION}"
PY_TARBALL="Python-${PYTHON_VERSION}.tar.xz"
PY_SRC_TREE="${PY_SRC_DIR}/Python-${PYTHON_VERSION}"

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
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libffi-dev \
    liblzma-dev \
    uuid-dev \
    libncursesw5-dev

header "Downloading Python ${PYTHON_VERSION} source"
cd "${PY_SRC_DIR}"
if [[ ! -f "${PY_TARBALL}" ]]; then
    curl -LO "https://www.python.org/ftp/python/${PYTHON_VERSION}/${PY_TARBALL}"
fi

header "Extracting source"
if [[ ! -d "${PY_SRC_TREE}" ]]; then
    tar -xf "${PY_TARBALL}"
fi

header "Configuring build (out-of-tree)"
mkdir -p "${PY_BUILD_DIR}"
cd "${PY_BUILD_DIR}"

"${PY_SRC_TREE}/configure" \
    --prefix="${PY_PREFIX}" \
    --with-ensurepip=install

header "Building with ${CORES} CPU cores"
make -j"${CORES}"

header "Installing into: ${PY_PREFIX}"
make install

header "Creating symlinks in: ${DEVROOT}/bin"
ln -sf "../opt/python/${PYTHON_VERSION}/bin/python3.14" "${DEVROOT}/bin/python3"
ln -sf "python3" "${DEVROOT}/bin/python"

ln -sf "../opt/python/${PYTHON_VERSION}/bin/pip3.14" "${DEVROOT}/bin/pip3"
ln -sf "pip3" "${DEVROOT}/bin/pip"

header "Creating version switching symlink: opt/python/current -> ${PYTHON_VERSION}"
ln -sfn "${PYTHON_VERSION}" "${DEVROOT}/opt/python/current"

header "Updating PATH for this shell session"
export PATH="${DEVROOT}/bin:${PATH}"
hash -r || true

header "Verifying"
which python
python --version

which pip
pip --version

python -c "import ssl, sqlite3, zlib, bz2, lzma, ctypes; print('ok')"
python -c "import sys; print(sys.executable)"

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

header "Printing ~/.bashrc"
cat "${BASHRC}"

header "Printing PATH"
echo "${PATH}" | tr ':' '\n'
