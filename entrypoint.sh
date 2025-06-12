#!/bin/bash

set -euo pipefail

rules_repository="$1"
output_type="$2"
output_file="$3"
fail_on_result="$4"
verbose="$5"
path="$6"

if [[ -d "${path}" ]]; then
  cd "${path}"
fi

SCAN_ARGS=()

if [[ $verbose == "true" ]]; then
  SCAN_ARGS+=(--verbose)
else
  SCAN_ARGS+=(--no-verbose)
fi

if [[ $fail_on_result == "true" ]]; then
  SCAN_ARGS+=(--fail-on-result)
else
  SCAN_ARGS+=(--no-fail-on-result)
fi

if [[ $output_type == "stdout" ]]; then
  SCAN_ARGS+=(-t "$output_type")
else
  SCAN_ARGS+=(-t "$output_type" -o "$output_file")
fi

echo "SCAN_ARGS:"
printf -- "- #%s#" "${SCAN_ARGS[@]}"
echo ""

clj-holmes fetch-rules -r "$rules_repository"
clj-holmes scan -p . "${SCAN_ARGS[@]}"
