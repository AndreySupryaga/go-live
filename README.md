# go-live — скіл «опублікуй мій сайт»

Скіл для AI-агента: Claude (застосунок Claude, вкладка Code) або Codex (застосунок ChatGPT).
Ви кажете **«опублікуй на сайт»** — агент ставить потрібні програми, пропонує вільну адресу,
додає іконку й прев'ю для месенджерів і публікує сайт на Vercel. Результат — посилання
`https://<назва>.vercel.app`, а за бажанням і ваш власний домен.

Два варіанти, агент спитає на першому запуску:

- **Через GitHub (рекомендовано)** — копія проєкту й історія всіх змін у приватному репозиторії
  GitHub; сайт оновлюється сам після кожного збереження.
- **Напряму у Vercel** — один акаунт, найменше кроків.

## Встановлення

Відкрийте застосунок Claude (вкладка Code) або ChatGPT (Codex) і напишіть агенту:

> Встанови скіл з https://github.com/AndreySupryaga/go-live

Агент попросить дозволу записати файли — натисніть «Дозволити». Потім почніть **нову розмову**:
скіл підхоплюється на старті.

### Для AI-агента: як встановити

1. Папка скіла:
   - Claude (застосунок Claude, Claude Code): `~/.claude/skills/go-live`
     (Windows: `%USERPROFILE%\.claude\skills\go-live`).
   - Codex (застосунок ChatGPT, Codex CLI): `~/.agents/skills/go-live`
     (Windows: `%USERPROFILE%\.agents\skills\go-live`).
2. Є git → `git clone https://github.com/AndreySupryaga/go-live <папка>`.
   Немає git → завантажте архів і розпакуйте вміст папки `go-live-main` у `<папка>`:
   ```bash
   curl -fsSL -o "$TMPDIR/go-live.zip" https://github.com/AndreySupryaga/go-live/archive/refs/heads/main.zip
   unzip -o -q "$TMPDIR/go-live.zip" -d "$TMPDIR" && mkdir -p ~/.claude/skills \
     && rm -rf ~/.claude/skills/go-live && mv "$TMPDIR/go-live-main" ~/.claude/skills/go-live
   ```
   Для Codex замініть `~/.claude/skills` на `~/.agents/skills`. PowerShell: `Invoke-WebRequest … -OutFile go-live.zip`,
   `Expand-Archive`, `Move-Item`.
3. Перевірте, що `<папка>/SKILL.md` існує. Скажіть людині почати нову розмову (у Claude Code CLI
   досить `/reload-skills`).

Вручну через інтерфейс: Claude → Customize → Skills → Upload a skill (ZIP із папкою `go-live`);
ChatGPT → Skills → Upload a skill.

## Що далі

1. Відкрийте в застосунку папку з вашим сайтом (Claude: Code → Local → Open folder; ChatGPT:
   Codex → Add new project).
2. Напишіть: **«опублікуй на сайт»**.
3. Відповідайте на запитання агента і натискайте «Дозволити», коли він просить. Вхід у GitHub і
   Vercel підтверджуєте самі у браузері — пароль агенту не потрібен.

Інші фрази:

- «опублікуй зміни» — оновити сайт;
- «зміни адресу сайту на …»;
- «підключи GitHub» — увімкнути копію й історію змін для сайту, опублікованого напряму;
- «підключи домен anna-yoga.com» — свій домен.

## Скільки це коштує

- **Агент.** Claude — від тарифу Pro, 20 $/міс. Codex входить у тарифи ChatGPT, на безкоштовному з
  невеликими лімітами; Plus — 20 $/міс.
- **Vercel Hobby** — безкоштовно для особистих і некомерційних проєктів. Сайт, що рекламує ваші
  платні послуги, Vercel вважає комерційним: для нього тариф Pro, 20 $/міс.
- **GitHub** з приватними репозиторіями — безкоштовно.
- **Домен** — від ≈ 11 $/рік за `.com` у Vercel; `.com.ua` в українських реєстраторів —
  ≈ 460–740 грн/рік.

## Що знадобиться

- Акаунт GitHub — https://github.com/signup (можна через Google).
- Акаунт Vercel — https://vercel.com/signup, кнопка Continue with GitHub.
- Потрібні програми агент встановить сам. Вам — натиснути «Дозволити»; комп’ютер може один раз
  попросити підтвердження.
