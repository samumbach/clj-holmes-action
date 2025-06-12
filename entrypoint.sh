#!/bin/bash

set -euo pipefail

rules_repository="$1"
output_type="$2"
output_file="$3"
fail_on_result="$4"
verbose="$5"
path="$6"
ignored_paths="$7"
rule_tags="$8"
rule_severities="$9"
rule_precisions="${10}"

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

while IFS= read -r x; do
  SCAN_ARGS+=(--ignored-paths "$x")
done <<<"${ignored_paths}"

while IFS= read -r x; do
  SCAN_ARGS+=(--rule-tags "$x")
done <<<"${rule_tags}"

while IFS= read -r x; do
  SCAN_ARGS+=(--rule-severity "$x")
done <<<"${rule_severities}"

while IFS= read -r x; do
  SCAN_ARGS+=(--rule-precision "$x")
done <<<"${rule_precisions}"

echo "SCAN_ARGS:"
printf -- "- #%s#\n" "${SCAN_ARGS[@]}"
echo ""

clj-holmes fetch-rules -r "$rules_repository"
clj-holmes scan -p . "${SCAN_ARGS[@]}"
