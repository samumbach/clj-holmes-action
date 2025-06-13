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
extra_scan_args="${11}"
declare -a extra_scan_args_sh="(${12})"
declare -p extra_scan_args_sh &>/dev/null || extra_scan_args_sh=()

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

while IFS=$' \t\n' read -r x; do
  if [[ -n "$x" ]]; then
    SCAN_ARGS+=(--ignored-paths "$x")
  fi
done <<<"${ignored_paths}"

while IFS=$' \t\n' read -r x; do
  if [[ -n "$x" ]]; then
    SCAN_ARGS+=(--rule-tags "$x")
  fi
done <<<"${rule_tags}"

while IFS=$' \t\n' read -r x; do
  if [[ -n "$x" ]]; then
    SCAN_ARGS+=(--rule-severity "$x")
  fi
done <<<"${rule_severities}"

while IFS=$' \t\n' read -r x; do
  if [[ -n "$x" ]]; then
    SCAN_ARGS+=(--rule-precision "$x")
  fi
done <<<"${rule_precisions}"

# when extra_scan_args is empty, yields no args
# TODO: when extra_scan_args has trailing newline, yields an empty final arg (which may or may not be what the user intended)
if [[ -n "${extra_scan_args}" ]]; then
  while IFS=$'\n' read -r x; do
    SCAN_ARGS+=("$x")
  done <<<"${extra_scan_args}"
fi

SCAN_ARGS+=("${extra_scan_args_sh[@]}")

echo "SCAN_ARGS:"
printf -- "- #%s#\n" "${SCAN_ARGS[@]}"
echo ""

clj-holmes fetch-rules -r "$rules_repository"
clj-holmes scan -p . "${SCAN_ARGS[@]}"
