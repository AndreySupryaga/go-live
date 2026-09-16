#!/usr/bin/env bash
# Перевіряє, чи вільна назва одночасно на GitHub (у вашому акаунті),
# на Vercel (серед ваших проєктів) і як адреса <назва>.vercel.app.
#
# Використання:  bash check-name.sh my-site my-site-2 my-landing
# Вивід (TSV):   назва <TAB> free|taken|invalid|unknown <TAB> пояснення

set -u

GH_USER="$(gh api user -q .login 2>/dev/null || true)"
VERCEL_OK=0
command -v vercel >/dev/null 2>&1 && vercel whoami >/dev/null 2>&1 && VERCEL_OK=1

for name in "$@"; do
  # Vercel: малі латинські літери, цифри, дефіс; до 63 символів (межа піддомену); без '---'
  if ! [[ "$name" =~ ^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$ ]] || [[ "$name" == *---* ]]; then
    printf '%s\tinvalid\tлише a-z, 0-9 і дефіс, до 63 символів, без дефісу на початку/в кінці\n' "$name"
    continue
  fi

  reasons=()

  if [ -n "$GH_USER" ] && gh repo view "$GH_USER/$name" >/dev/null 2>&1; then
    reasons+=("репозиторій github.com/$GH_USER/$name уже існує")
  fi

  if [ "$VERCEL_OK" = 1 ] && vercel project inspect "$name" >/dev/null 2>&1; then
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
