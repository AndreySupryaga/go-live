# Встановлення програм без терміналу і без sudo

Людина пише із застосунку (Claude або ChatGPT) і не вміє працювати з терміналом. Ставиш ти;
вона лише натискає «Дозволити» в застосунку. Системне вікно на macOS буде лише одне — для Git
(режим «Сейф»); на Windows — запит «Так» на кожне встановлення. Перед кожним кроком
скажи, яке вікно вона побачить і що там натиснути.

Перевірка після встановлення — та сама команда `--version`. Програма встановилась, а команда її не
бачить → спершу спробуй повний шлях (нижче), потім попроси перезапустити застосунок.

## macOS

### Node.js (обидва режими)

Є Homebrew (`command -v brew`) → `brew install node`.

Немає → офіційний архів у `~/.local/node`: без пароля, без вікон установника.

```bash
V=$(curl -fsSL https://nodejs.org/dist/index.json 2>/dev/null | tr '{' '\n' | grep -m1 '"lts":"' \
  | sed -E 's/.*"version":"([^"]+)".*/\1/')
A=$(uname -m | sed 's/x86_64/x64/')              # arm64 або x64
mkdir -p ~/.local/node && curl -fsSL "https://nodejs.org/dist/$V/node-$V-darwin-$A.tar.gz" \
  | tar -xz -C ~/.local/node --strip-components=1
export PATH="$HOME/.local/node/bin:$PATH"; node --version
npm i -g vercel                                  # без sudo: папка належить людині
```

Кожна наступна команда запускається в новій оболонці, тому **на початку кожної** команди з `node`,
`npm`, `npx` або `vercel` пиши `export PATH="$HOME/.local/node/bin:$PATH";`.

### Git (лише «Сейф»)

`xcode-select -p` нічого не вивів → `xcode-select --install`. З'явиться системне вікно
«Встановити інструменти розробника» → Встановити → Погоджуюсь. Завантаження триває 5–15 хвилин;
попроси написати «готово», коли вікно закриється. Не запускай `git --version` до цього: на чистому
Mac він сам відкриває те саме вікно.

### GitHub CLI `gh` (лише «Сейф»)

Є Homebrew → `brew install gh`. Немає → архів із релізу в `~/.local/bin` (без пароля і без вікон;
`.pkg` для `gh` не підписаний, macOS його блокує — не використовуй):

```bash
T=$(curl -fsSL https://api.github.com/repos/cli/cli/releases/latest | grep -m1 '"tag_name"' \
  | sed -E 's/.*"v([^"]+)".*/\1/')
A=$(uname -m | sed 's/x86_64/amd64/')            # arm64 або amd64
curl -fsSL -o "$TMPDIR/gh.zip" "https://github.com/cli/cli/releases/download/v$T/gh_${T}_macOS_${A}.zip"
rm -rf "$TMPDIR/gh-unzip" && unzip -o -q "$TMPDIR/gh.zip" -d "$TMPDIR/gh-unzip"
mkdir -p ~/.local/bin && cp "$TMPDIR/gh-unzip/gh_${T}_macOS_${A}/bin/gh" ~/.local/bin/gh
~/.local/bin/gh --version
```

`~/.local/bin` часто немає в PATH → у командах пиши `~/.local/bin/gh` замість `gh`.

### Vercel CLI

Після Node: `npm i -g vercel`. Node з Homebrew або з `~/.local/node` ставить її без пароля. Помилка прав
(`EACCES`, Node з офіційного `.pkg`) → не чіпай `sudo`, пиши `npx --yes vercel@latest …` у кожній
команді. Перевірка: `vercel --version`.

## Windows

Є `winget` (Windows 10/11). Windows покаже запит «Дозволити цій програмі вносити зміни?» → «Так».

```powershell
winget install --id OpenJS.NodeJS.LTS -e --accept-source-agreements --accept-package-agreements
# лише «Сейф»:
winget install --id Git.Git -e --accept-source-agreements --accept-package-agreements
winget install --id GitHub.cli -e --accept-source-agreements --accept-package-agreements
```

Після встановлення застосунок не бачить нових програм, доки його не перезапустити. Спершу спробуй
повні шляхи: `"C:\Program Files\nodejs\node.exe"`, `"C:\Program Files\nodejs\npx.cmd"`,
`"C:\Program Files\GitHub CLI\gh.exe"`, `"C:\Program Files\Git\cmd\git.exe"`. Не допомогло →
попроси людину **повністю закрити застосунок** (Claude або ChatGPT: правий клік на значку в треї →
Вийти), відкрити знову, повернутися в цю розмову і написати «продовжуй».

Скрипт `check-name.sh` і приклади в SKILL.md написані для bash. Застосунок Claude на Windows
використовує Git Bash, якщо Git встановлено; без нього і в ChatGPT команди йдуть через PowerShell —
виконуй еквіваленти (`curl.exe`, `Start-Process <url>`, `Expand-Archive`).

## Linux

Node.js — менеджером пакетів дистрибутива або з https://nodejs.org; `gh` — https://github.com/cli/cli/blob/trunk/docs/install_linux.md.
Пароль `sudo` людина вводить сама у вбудованому терміналі застосунку.
