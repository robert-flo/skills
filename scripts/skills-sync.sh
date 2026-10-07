#!/usr/bin/env bash
set -euo pipefail

# Run by skills-sync.service. Keeps the clone this script lives in on the
# latest origin/personal and relinks its skills with scripts/link-skills.sh.
#
# Exit codes: 0 when there is nothing to do, the network is down, or the clone
# is skipped (not on `personal`, or dirty). Non-zero when the fast-forward or
# the relink fails, so the unit shows up as failed.
#
# Every desktop notification is sent once per (remote SHA, reason); the record
# lives in ~/.local/state/skills-sync/notified.

REPO="$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)"
BRANCH=personal
DESTS=("$HOME/.claude/skills" "$HOME/.agents/skills")
STATE_DIR="$HOME/.local/state/skills-sync"
NOTIFIED="$STATE_DIR/notified"

log() { echo "skills-sync: $*"; }

# notify <remote-sha> <reason> <urgency> <message>
notify() {
  local sha="$1" reason="$2" urgency="$3" message="$4"
  mkdir -p "$STATE_DIR"
  if grep -qxF "$sha $reason" "$NOTIFIED" 2>/dev/null; then
    log "already notified for $sha ($reason), not notifying again"
    return 0
  fi
  if command -v notify-send >/dev/null 2>&1; then
    notify-send -u "$urgency" -a skills-sync "skills-sync" "$message" || log "notify-send failed"
  fi
  echo "$sha $reason" >>"$NOTIFIED"
}

# Removes symlinks in the harness skill dirs that are broken and point into
# this clone. Real directories and links to other places are never touched.
prune_broken_links() {
  local dest link target
  for dest in "${DESTS[@]}"; do
    [ -d "$dest" ] || continue
    for link in "$dest"/* "$dest"/.[!.]*; do
      [ -L "$link" ] || continue
      [ -e "$link" ] && continue
      target="$(readlink "$link")"
      case "$target" in
        "$REPO"/*)
          rm -- "$link"
          log "removed broken link $link -> $target"
          ;;
      esac
    done
  done
}

cd "$REPO"

if ! git fetch --quiet origin "$BRANCH" 2>&1; then
  log "fetch of origin/$BRANCH failed (offline?), skipping"
  exit 0
fi

remote_sha="$(git rev-parse "origin/$BRANCH")"
local_sha="$(git rev-parse HEAD)"

if git merge-base --is-ancestor "$remote_sha" "$local_sha"; then
  log "up to date at $local_sha"
  exit 0
fi

current_branch="$(git symbolic-ref --quiet --short HEAD || echo "(detached)")"
if [ "$current_branch" != "$BRANCH" ]; then
  log "clone $REPO is on $current_branch, not $BRANCH; skipping update to $remote_sha"
  notify "$remote_sha" wrong-branch normal "Clone is on $current_branch, not $BRANCH. Skills not updated: $REPO"
  exit 0
fi

if [ -n "$(git status --porcelain)" ]; then
  log "clone $REPO has uncommitted changes; skipping update to $remote_sha"
  notify "$remote_sha" dirty normal "Clone has uncommitted changes. Skills not updated: $REPO"
  exit 0
fi

if ! git merge --ff-only --quiet "origin/$BRANCH"; then
  log "cannot fast-forward $local_sha to $remote_sha"
  notify "$remote_sha" not-ff critical "Cannot fast-forward $BRANCH to ${remote_sha:0:7}. Skills not updated: $REPO"
  exit 1
fi
log "fast-forwarded $local_sha -> $remote_sha"

if ! link_out="$("$REPO/scripts/link-skills.sh" 2>&1)"; then
  echo "$link_out"
  log "link-skills.sh failed"
  notify "$remote_sha" link-failed critical "link-skills.sh failed after updating to ${remote_sha:0:7}: $REPO"
  exit 1
fi
log "linked $(grep -c '^linked ' <<<"$link_out") skill entries"

prune_broken_links
log "done at $remote_sha"
