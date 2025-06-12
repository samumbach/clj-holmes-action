#!/bin/bash

set -euo pipefail

rules_repository="$1"
output_type="$2"
output_file="$3"
fail_on_result="$4"
verbose="$5"
path="$6"
IFS=, read -ra ignored_paths   <<<"$7"
IFS=, read -ra rule_tags       <<<"$8"
IFS=, read -ra rule_severities <<<"$9"
IFS=, read -ra rule_precisions <<<"$10"

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

for x in "${ignored_paths[@]}"; do
  SCAN_ARGS+=(--ignored-paths "$x")
done

for x in "${rule_tags[@]}"; do
  SCAN_ARGS+=(--rule-tags "$x")
done

for x in "${rule_severities[@]}"; do
  SCAN_ARGS+=(--rule-severity "$x")
done

for x in "${rule_precisions[@]}"; do
  SCAN_ARGS+=(--rule-precision "$x")
done

echo "SCAN_ARGS:"
printf -- "- #%s#\n" "${SCAN_ARGS[@]}"
echo ""

clj-holmes fetch-rules -r "$rules_repository"
clj-holmes scan -p . "${SCAN_ARGS[@]}"
