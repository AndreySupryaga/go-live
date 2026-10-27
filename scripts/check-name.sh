#!/usr/bin/env bash
# Перевіряє, чи вільна назва як адреса <назва>.vercel.app, серед ваших проєктів Vercel
# і (у режимі «Сейф») серед ваших репозиторіїв GitHub.
#
# Використання:  bash check-name.sh [--no-github] my-site my-site-2 my-landing
#   --no-github  режим «Просто»: репозиторії GitHub не перевіряти
# Вивід (TSV):   назва <TAB> free|taken|invalid|unknown <TAB> пояснення

set -u

CHECK_GITHUB=1
if [ "${1:-}" = "--no-github" ]; then CHECK_GITHUB=0; shift; fi

# Vercel CLI: встановлений або через npx (без глобального встановлення)
if command -v vercel >/dev/null 2>&1; then
  vc() { vercel "$@"; }
elif command -v npx >/dev/null 2>&1; then
  vc() { npx --yes vercel@latest "$@"; }
else
  vc() { return 127; }
fi
VERCEL_OK=0
vc whoami >/dev/null 2>&1 && VERCEL_OK=1

# GitHub CLI: у PATH або в ~/.local/bin (так його ставить скіл на macOS без Homebrew)
GH=""
if [ "$CHECK_GITHUB" = 1 ]; then
  if command -v gh >/dev/null 2>&1; then GH=gh
  elif [ -x "$HOME/.local/bin/gh" ]; then GH="$HOME/.local/bin/gh"
  fi
fi
GH_USER=""
[ -n "$GH" ] && GH_USER="$("$GH" api user -q .login 2>/dev/null || true)"

for name in "$@"; do
  # Vercel: малі латинські літери, цифри, дефіс; до 63 символів (межа піддомену); без '---'
  if ! [[ "$name" =~ ^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$ ]] || [[ "$name" == *---* ]]; then
    printf '%s\tinvalid\tлише a-z, 0-9 і дефіс, до 63 символів, без дефісу на початку/в кінці\n' "$name"
    continue
  fi

  reasons=()

  if [ -n "$GH_USER" ] && "$GH" repo view "$GH_USER/$name" >/dev/null 2>&1; then
    reasons+=("репозиторій github.com/$GH_USER/$name уже існує")
  fi

  if [ "$VERCEL_OK" = 1 ] && vc project inspect "$name" >/dev/null 2>&1; then
    reasons+=("проєкт $name уже є у вашому Vercel")
  fi

  # Вільний піддомен Vercel відповідає 404 із заголовком x-vercel-error: DEPLOYMENT_NOT_FOUND
  headers="$(curl -sI --max-time 10 "https://$name.vercel.app" 2>/dev/null || true)"
  if [ -z "$headers" ]; then
    printf '%s\tunknown\tне вдалося перевірити %s.vercel.app (немає мережі?)\n' "$name" "$name"
    continue
  fi
  if ! grep -qi 'x-vercel-error: *DEPLOYMENT_NOT_FOUND' <<<"$headers"; then
    reasons+=("адреса $name.vercel.app уже зайнята")
  fi

  if [ ${#reasons[@]} -eq 0 ]; then
    printf '%s\tfree\t%s.vercel.app вільна\n' "$name" "$name"
  else
    printf '%s\ttaken\t%s\n' "$name" "$(printf '%s; ' "${reasons[@]}" | sed 's/; $//')"
  fi
done
