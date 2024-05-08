#!/usr/bin/env bash

set -e

ci_dir="$(dirname "$0")"
. "${ci_dir}/ci-common.sh"

git_download coq_lsp

if [ "$DOWNLOAD_ONLY" ]; then exit 0; fi

( cd "${CI_BUILD_DIR}/coq_lsp"
  dune build --root . --only-packages=coq-lsp @install
  _build/install/default/bin/coq-lsp --version
)
