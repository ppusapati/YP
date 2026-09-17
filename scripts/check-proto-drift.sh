#!/usr/bin/env bash
# Fail if regenerating protobuf code changed anything under the given paths.
#
# Usage:
#   check-proto-drift.sh "<how to fix it>" <pathspec> [<pathspec>...]
#
# Run this straight after `buf generate`, with the paths that generation was
# supposed to write to.
#
# Why this is not `git diff --exit-code`
# -------------------------------------
# `git diff` compares the index against the working tree, and an untracked file
# is in neither — so a *newly generated* file is invisible to it. That is not a
# corner case here: it is the exact shape of the drift these jobs exist to
# catch. A new service's bindings are all new files, so the check would pass
# while the service had no client at all in that language. Six services sat
# like that in the Dart tree behind a green tick.
#
# `git status --porcelain` reports added, modified and deleted alike, which is
# what "did regeneration change anything" actually means.
set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "usage: $0 \"<how to fix it>\" <pathspec> [<pathspec>...]" >&2
  exit 2
fi

remedy="$1"
shift

# --untracked-files=all rather than the default `normal`, which collapses a
# directory of new files into a single entry naming the directory. The
# collapsed form is still non-empty so the check would fire either way, but the
# listing below is the thing a person reads to find out what changed.
drift="$(git status --porcelain --untracked-files=all -- "$@")"

if [ -z "$drift" ]; then
  echo "Generated code is up to date."
  exit 0
fi

echo "Generated protobuf code is stale — $remedy."
echo
echo "Changed by regeneration:"
echo "$drift"
echo

# The content of what changed, for the tracked files. Capped, because a
# first-time regeneration of a whole language can be thousands of lines and an
# unreadable log teaches people to ignore the job.
echo "Diff (first 200 lines):"
git --no-pager diff -- "$@" | head -200

exit 1
