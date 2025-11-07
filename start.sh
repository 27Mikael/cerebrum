#!/bin/sh
bun run build
serve -s dist -l ${PORT:-3000}
