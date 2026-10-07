#!/usr/bin/env bash
set -euo pipefail

# Installs the skills-sync systemd user timer for a clone of robert-flo/skills.
#
#   scripts/install-sync.sh              from a clone: use that clone
#   curl -fsSL https://raw.githubusercontent.com/robert-flo/skills/personal/scripts/install-sync.sh | bash
#                                        no clone: use (or clone) ~/Work/tries/pj-fleet/fo-skills
#   scripts/install-sync.sh --uninstall  disable the timer, remove the units and
#                                        ~/.local/state/skills-sync; the clone and
#                                        the skill symlinks stay
#
# Safe to run again: unchanged units are left alone and an active timer stays
# as it is. SKILLS_SYNC_BRANCH picks the branch to clone (default personal);
# the timer itself always follows origin/personal.

REPO_URL=https://github.com/robert-flo/skills.git
BRANCH="${SKILLS_SYNC_BRANCH:-personal}"
DEFAULT_CLONE="$HOME/Work/tries/pj-fleet/fo-skills"
UNIT_DIR="$HOME/.config/systemd/user"
STATE_DIR="$HOME/.local/state/skills-sync"
UNITS=(skills-sync.service skills-sync.timer)

log() { echo "install-sync: $*"; }
die() { echo "install-sync: error: $*" >&2; exit 1; }

uninstall() {
  systemctl --user disable --now skills-sync.timer 2>/dev/null || true
  systemctl --user stop skills-sync.service 2>/dev/null || true
  local unit
  for unit in "${UNITS[@]}"; do
    if [ -e "$UNIT_DIR/$unit" ]; then
      rm -f -- "$UNIT_DIR/$unit"
      log "removed $UNIT_DIR/$unit"
    fi
  done
  systemctl --user daemon-reload
  systemctl --user reset-failed "${UNITS[@]}" 2>/dev/null || true
  if [ -e "$STATE_DIR" ]; then
    rm -rf -- "$STATE_DIR"
    log "removed $STATE_DIR"
  fi
  log "uninstalled (clone and skill symlinks left in place)"
}

# Prints the clone this script lives in, or nothing when it runs from a pipe.
script_clone() {
  local src="${BASH_SOURCE[0]:-}"
  [ -n "$src" ] && [ -f "$src" ] || return 0
  local dir
  dir="$(cd "$(dirname "$(readlink -f "$src")")/.." && pwd)"
  if [ -f "$dir/scripts/skills-sync.sh" ] && git -C "$dir" rev-parse --git-dir >/dev/null 2>&1; then
    echo "$dir"
  fi
}

# install_unit <name> <content>: writes the unit only when it differs.
install_unit() {
  local dest="$UNIT_DIR/$1" content="$2"
  if [ -f "$dest" ] && [ "$(cat "$dest")" = "$content" ]; then
    log "unchanged $dest"
    return 1
  fi
  printf '%s\n' "$content" >"$dest" || die "cannot write $dest"
  log "installed $dest"
}

# The repo's service unit with ExecStart pointing at this clone.
render_service() {
  local exec="${1//%/%%}" line
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      ExecStart=*) printf 'ExecStart="%s/scripts/skills-sync.sh"\n' "$exec" ;;
      *) printf '%s\n' "$line" ;;
    esac
  done <"$1/systemd/skills-sync.service"
}

case "${1:-}" in
  "") ;;
  --uninstall) uninstall; exit 0 ;;
  -h|--help) sed -n '4,15p' "${BASH_SOURCE[0]}" 2>/dev/null | sed 's/^# \{0,1\}//'; exit 0 ;;
  *) die "unknown argument: $1 (use --uninstall)" ;;
esac

command -v git >/dev/null 2>&1 || die "git is required"
command -v systemctl >/dev/null 2>&1 || die "systemctl is required"

clone="$(script_clone)"
if [ -n "$clone" ]; then
  log "using the clone this script lives in: $clone"
elif [ -e "$DEFAULT_CLONE" ]; then
  clone="$DEFAULT_CLONE"
  log "using existing clone: $clone"
else
  log "cloning $REPO_URL ($BRANCH) into $DEFAULT_CLONE"
  mkdir -p "$(dirname "$DEFAULT_CLONE")"
  git clone --quiet --branch "$BRANCH" "$REPO_URL" "$DEFAULT_CLONE"
  clone="$DEFAULT_CLONE"
fi

for f in scripts/skills-sync.sh scripts/link-skills.sh systemd/skills-sync.service systemd/skills-sync.timer; do
  [ -f "$clone/$f" ] || die "$clone has no $f; is it an up to date clone of $REPO_URL?"
done

mkdir -p "$UNIT_DIR"
changed=0
install_unit skills-sync.service "$(render_service "$clone")" && changed=1
install_unit skills-sync.timer "$(cat "$clone/systemd/skills-sync.timer")" && changed=1
if [ "$changed" = 1 ]; then
  systemctl --user daemon-reload
  log "reloaded the systemd user manager"
fi

if ! link_out="$("$clone/scripts/link-skills.sh" 2>&1)"; then
  echo "$link_out" >&2
  die "link-skills.sh failed"
fi
log "linked $(grep -c '^linked ' <<<"$link_out") skill entries"

if systemctl --user is-enabled --quiet skills-sync.timer && systemctl --user is-active --quiet skills-sync.timer; then
  log "skills-sync.timer already enabled and active"
else
  systemctl --user enable --now skills-sync.timer
  log "enabled and started skills-sync.timer"
fi
