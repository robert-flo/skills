#!/usr/bin/env bash
set -euo pipefail

# Run by skills-sync.service. Keeps the clone this script lives in on the
# latest origin/personal and relinks its skills with scripts/link-skills.sh.
#
# Exit codes: 0 when there is nothing to do, the network is down, or the clone
# is skipped (not on `personal`, or dirty). Non-zero when the fetch fails for
# another reason (authentication, missing remote), when the fast-forward or the
# relink fails, or when a skill's name is taken in ~/.claude/skills or
# ~/.agents/skills by something that is not a link into this clone. In that
# last case nothing is relinked or deleted; the fast-forward stays, and every
# later run retries the relink until the entries are moved away.
#
# Every desktop notification is sent once per (SHA, reason); the record lives
# in ~/.local/state/skills-sync/notified and is written only when notify-send
# succeeded.

REPO="$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)"
BRANCH=personal
DESTS=("$HOME/.claude/skills" "$HOME/.agents/skills")
STATE_DIR="$HOME/.local/state/skills-sync"
NOTIFIED="$STATE_DIR/notified"
PENDING="$STATE_DIR/relink-pending"

# shellcheck source=scripts/skills-in-the-way.sh
. "$REPO/scripts/skills-in-the-way.sh"

log() { echo "skills-sync: $*"; }

# notify <sha> <reason> <urgency> <message>
notify() {
  local sha="$1" reason="$2" urgency="$3" message="$4"
  mkdir -p "$STATE_DIR"
  if grep -qxF "$sha $reason" "$NOTIFIED" 2>/dev/null; then
    log "already notified for $sha ($reason), not notifying again"
    return 0
  fi
  if ! command -v notify-send >/dev/null 2>&1; then
    log "notify-send not found, will try again next run"
    return 0
  fi
  if ! notify-send -u "$urgency" -a skills-sync "skills-sync" "$message"; then
    log "notify-send failed, will try again next run"
    return 0
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

# Never prompt, and give up on a stalled SSH connection instead of hanging.
export GIT_TERMINAL_PROMPT=0
export GIT_SSH_COMMAND="${GIT_SSH_COMMAND:-ssh -o BatchMode=yes -o ConnectTimeout=20}"

if ! fetch_err="$(git fetch --quiet origin "$BRANCH" 2>&1)"; then
  case "$fetch_err" in
    *"Could not resolve host"* | *"Temporary failure in name resolution"* | \
      *"Network is unreachable"* | *"No route to host"* | *"timed out"* | \
      *"Connection refused"* | *"Couldn't connect to server"*)
      log "fetch of origin/$BRANCH failed, looks offline, skipping"
      exit 0
      ;;
  esac
  printf '%s\n' "$fetch_err"
  log "fetch of origin/$BRANCH failed and it does not look like a network outage"
  known_sha="$(git rev-parse --verify --quiet "origin/$BRANCH" || echo none)"
  notify "$known_sha" fetch-failed critical "git fetch of origin/$BRANCH failed (not a network outage). Skills not updated: $REPO"
  exit 1
fi

remote_sha="$(git rev-parse "origin/$BRANCH")"
local_sha="$(git rev-parse HEAD)"

if git merge-base --is-ancestor "$remote_sha" "$local_sha"; then
  if [ ! -e "$PENDING" ]; then
    log "up to date at $local_sha"
    exit 0
  fi
  log "up to date at $local_sha, but its skills are not linked yet; retrying the relink"
else
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
  mkdir -p "$STATE_DIR"
  touch "$PENDING"
fi

in_the_way="$(skills_in_the_way "$REPO" "${DESTS[@]}" | sort -u)"
if [ -n "$in_the_way" ]; then
  log "not relinking: these entries have a skill's name and are not links into $REPO, so link-skills.sh would replace them:"
  while IFS= read -r entry; do log "  $entry"; done <<<"$in_the_way"
  log "nothing was deleted; the clone stays fast-forwarded at $(git rev-parse HEAD). Move them away and the next run relinks"
  notify "$remote_sha" in-the-way critical "Skills not relinked: $(wc -l <<<"$in_the_way") entries in the way ($(xargs -d '\n' -n1 basename <<<"$in_the_way" | sort -u | paste -sd ' ')). See journalctl --user -u skills-sync"
  exit 1
fi

if ! link_out="$("$REPO/scripts/link-skills.sh" 2>&1)"; then
  echo "$link_out"
  log "link-skills.sh failed"
  notify "$remote_sha" link-failed critical "link-skills.sh failed after updating to ${remote_sha:0:7}: $REPO"
  exit 1
fi
log "linked $(grep -c '^linked ' <<<"$link_out") skill entries"
rm -f -- "$PENDING"

prune_broken_links
log "done at $remote_sha"
