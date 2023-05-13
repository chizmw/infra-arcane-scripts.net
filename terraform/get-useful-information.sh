#!/bin/bash
set -e

commit_version="$(git describe --tags --always)"
project_dir="$(basename "$(git rev-parse --show-toplevel)")"

jq -n \
    --arg commit_version "$commit_version" \
    --arg project_dir "$project_dir" \
    '{"commit_version": $commit_version, "project_dir": $project_dir}'
