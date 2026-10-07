# shellcheck shell=bash
# Sourced by skills-sync.sh and install-sync.sh; not meant to be run.

# skills_in_the_way <clone> <dest>...
#
# Prints the entries in the given skill dirs that link-skills.sh would replace:
# those named like a skill it links (same find selection) that are not a
# symlink into <clone>. That covers real directories, plain files and symlinks
# to other places, such as Omarchy's links into /usr/share/omarchy.
skills_in_the_way() {
  local clone="$1" resolved skill_md name dest entry target
  shift
  resolved="$(readlink -f "$clone")"
  while IFS= read -r -d '' skill_md; do
    name="$(basename "$(dirname "$skill_md")")"
    for dest in "$@"; do
      entry="$dest/$name"
      if [ -L "$entry" ]; then
        target="$(readlink "$entry")"
        case "$target" in
          "$clone"/* | "$resolved"/*) continue ;;
        esac
      elif [ ! -e "$entry" ]; then
        continue
      fi
      echo "$entry"
    done
  done < <(find "$clone/skills" -name SKILL.md -not -path '*/node_modules/*' -not -path '*/deprecated/*' -not -path '*/misc/*' -print0)
}
