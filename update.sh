#!/data/data/com.termux/files/usr/bin/bash
# =============================================
#  Termux Setup & Update Script
#  Clone repo → bash update.sh
# =============================================

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
R='\033[0;31m' G='\033[0;32m' Y='\033[1;33m'
B='\033[0;34m' C='\033[0;36m' W='\033[1;37m' N='\033[0m'

banner() {
  echo -e "${C}"
  echo "  ╔╦╗╔═╗╦═╗╔╦╗╦ ╦═╗ ╦  ╔═╗╔═╗╔╦╗╦ ╦╔═╗"
  echo "   ║ ║╣ ╠╦╝║║║║ ║╔╩╦╝  ╚═╗║╣  ║ ║ ║╠═╝"
  echo "   ╩ ╚═╝╩╚═╩ ╩╚═╝╩ ╚═  ╚═╝╚═╝ ╩ ╚═╝╩  "
  echo -e "${N}"
  echo -e "${W}  Termux Updater — github.com/YOU/termux-setup${N}"
  echo -e "  ─────────────────────────────────────────"
  echo ""
}

# ── Mirrors ──────────────────────────────────────────────────
declare -A MIRRORS=(
  [1]="https://packages-cf.termux.dev/apt/termux-main|Termux Official (Cloudflare CDN)"
  [2]="https://packages.termux.dev/apt/termux-main|Termux Official (Direct)"
  [3]="https://grimler.se/termux-packages-24/termux-main|Grimler (Sweden)"
  [4]="https://mirror.mwt.me/termux/main|MWT Mirror (US)"
  [5]="https://termux.librehat.com/apt/termux-main|LibreHat Mirror"
)

select_mirror() {
  echo -e "${Y}[1/4] Mirror Selection${N}"
  echo ""
  for i in 1 2 3 4 5; do
    IFS='|' read -r url name <<< "${MIRRORS[$i]}"
    echo -e "  ${B}[$i]${N} ${W}$name${N}"
    echo -e "      ${C}$url${N}"
    echo ""
  done

  echo -ne "${W}  Pick a mirror [1-5] (default: 1): ${N}"
  read -r choice
  choice=${choice:-1}

  if [[ -z "${MIRRORS[$choice]}" ]]; then
    echo -e "${R}  Invalid choice — defaulting to Cloudflare${N}"
    choice=1
  fi

  IFS='|' read -r MIRROR_URL MIRROR_NAME <<< "${MIRRORS[$choice]}"
  echo -e "${G}  ✓ Selected: $MIRROR_NAME${N}"
  echo ""
}

apply_mirror() {
  echo -e "${Y}[2/4] Applying Mirror${N}"
  cp "$PREFIX/etc/apt/sources.list" "$PREFIX/etc/apt/sources.list.bak" 2>/dev/null
  echo "deb $MIRROR_URL stable main" > "$PREFIX/etc/apt/sources.list"
  echo -e "${G}  ✓ sources.list updated${N}"
  echo -e "${G}  ✓ Backup saved to sources.list.bak${N}"
  echo ""
}

# ── Package Update ────────────────────────────────────────────
update_packages() {
  echo -e "${Y}[3/4] Updating Packages${N}"
  echo ""

  echo -e "  ${W}→ Fetching package lists...${N}"
  pkg update -y 2>&1 | tail -3

  echo -e "  ${W}→ Upgrading installed packages...${N}"
  pkg upgrade -y 2>&1 | tail -5

  echo -e "${G}  ✓ Packages up to date${N}"
  echo ""
}

# ── Copy Files from Repo ──────────────────────────────────────
copy_files() {
  echo -e "${Y}[4/4] Installing Config Files from Repo${N}"
  echo ""

  FILES_DIR="$REPO_DIR/files"

  copy_if_exists() {
    local src="$1" dest="$2" label="$3"
    if [ -f "$src" ]; then
      mkdir -p "$(dirname "$dest")"
      cp "$src" "$dest"
      echo -e "  ${G}✓${N} $label"
    else
      echo -e "  ${B}–${N} $label (not in repo, skipping)"
    fi
  }

  copy_if_exists "$FILES_DIR/.bashrc"           "$HOME/.bashrc"                   ".bashrc"
  copy_if_exists "$FILES_DIR/.profile"          "$HOME/.profile"                  ".profile"
  copy_if_exists "$FILES_DIR/termux.properties" "$HOME/.termux/termux.properties" "termux.properties"
  copy_if_exists "$FILES_DIR/motd"              "$PREFIX/etc/motd"                "motd"
  copy_if_exists "$FILES_DIR/colors.properties" "$HOME/.termux/colors.properties" "colors.properties"

  echo ""
}

# ── Optional Extra Packages ───────────────────────────────────
install_extras() {
  echo -ne "${W}  Install recommended extras? (git curl wget nano vim python) [y/N]: ${N}"
  read -r answer
  echo ""

  if [[ "$answer" =~ ^[Yy]$ ]]; then
    PKGS=(git curl wget nano vim python openssh)
    for p in "${PKGS[@]}"; do
      echo -ne "  Installing ${C}$p${N}... "
      pkg install -y "$p" &>/dev/null \
        && echo -e "${G}✓${N}" \
        || echo -e "${R}✗ (check manually)${N}"
    done
    echo ""
  fi
}

# ── Run ───────────────────────────────────────────────────────
banner

# Termux check
if [ -z "$PREFIX" ] || [ ! -d "$PREFIX/bin" ]; then
  echo -e "${R}ERROR: This script must be run inside Termux.${N}"
  exit 1
fi

select_mirror
apply_mirror
update_packages
copy_files
install_extras

# Done
echo -e "─────────────────────────────────────────"
echo -e "${G}✅ All done!${N}"
echo -e "   Restart Termux or run:  ${C}source ~/.bashrc${N}"
echo ""
