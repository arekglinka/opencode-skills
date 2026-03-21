#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."
spago build
bun -e "import(\"./output/Test.Main/index.js\").then(m => m.main())"
