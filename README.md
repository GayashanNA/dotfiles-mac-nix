# dotfiles-mac-nix

This repo is the public, reusable core of my Mac setup.

It is built with [Nix](https://nixos.org/), [`nix-darwin`](https://github.com/nix-darwin/nix-darwin), [Home Manager](https://github.com/nix-community/home-manager), and declarative [Homebrew](https://brew.sh/). The goal is to give macOS developers a reproducible base they can fork and adapt without inheriting someone else's entire private dotfiles repo.

If you want the longer explanation, see the [blog post](https://open.substack.com/pub/kunchenguid/p/how-i-built-a-reproducible-mac-setup?utm_campaign=post-expanded-share&utm_medium=web).

## What this repo does

It gives you a structured starting point for managing a Mac setup in code:

- bootstrap a fresh Mac with `setup/mac.sh`
- configure macOS defaults with `nix-darwin`
- manage user packages and shell behavior with Home Manager
- install GUI apps and macOS-native tools declaratively with Homebrew
- keep selected app config in the repo and link it into place

App configs under `files/.config/` are linked into place with out-of-store symlinks, so editing them takes effect without a rebuild.

## Keyboard-driven setup

This machine runs an i3/Terminator-style keyboard workflow:

- **[AeroSpace](https://nikitabobko.github.io/AeroSpace/guide)** — i3-style tiling WM. ⌥⏎ focuses WezTerm; ⌥⇧⏎ opens a new terminal window tiled *beside* the current app; ⌥1–9 are workspaces; ⌥HJKL moves focus. Config: `files/.config/aerospace/aerospace.toml`.
- **[WezTerm](https://wezfurlong.org/wezterm/)** — Terminator-style panes: ⌃⇧E splits side-by-side, ⌃⇧O splits stacked, ⌥+arrows navigate panes, ⌘A is the leader. Config: `files/.config/wezterm/wezterm.lua`.
- **Karabiner-Elements** — ⇪ Caps Lock is Hyper (⌃⌥⌘⇧) when held, ⎋ Escape when tapped. Config: `files/.config/karabiner/karabiner.json`.
- **CLI toolkit** — neovim (EDITOR), tmux (prefix ⌃A), fzf, zoxide, eza, bat, atuin (⌃R history), delta — all via Home Manager modules in `nix/user.nix`.
- **Vorssaint** (menu bar) — owns: clipboard history (⌃⌥⌘V), Command Bar launcher (⌥Space), mouse scroll inversion (trackpad stays natural), keep-awake, system monitor. Deliberately OFF: its window management (AeroSpace owns that) and its Super Key (Karabiner owns ⇪). **Never install/uninstall packages via its Homebrew manager** — brew state is declarative here; GUI-installed packages get zapped on the next rebuild. Settings backup: `files/vorssaint/`.

Terminology note: Terminator's "split vertically" (side-by-side panes) is WezTerm's `SplitHorizontal` and AeroSpace's `horizontal` orientation — the tools name the axis, Terminator names the divider.

### Escape hatches

- Quit AeroSpace from the menu bar → windows float normally again, instantly.
- Quit Karabiner-Elements → ⇪ is plain Caps Lock again.
- `aerospace enable off` → disable tiling but keep the process alive.
- Any phase is one commit: `git revert <commit>` then `rebuild`.
- If a rebuild complains about `karabiner.json.backup`: `rm -f ~/.config/karabiner/karabiner.json.backup` (Karabiner's GUI occasionally replaces the managed symlink; the rebuild self-heals it).
- Never use macOS native fullscreen (green button / ⌃⌘F) — it creates a separate Space that AeroSpace cannot see. Use ⌥F instead.

## Repo structure

- `setup/mac.sh` — bootstrap a fresh Mac
- `flake.nix` — top-level Nix wiring
- `nix/host.nix` — machine-level macOS config (nix-darwin), Homebrew casks
- `nix/user.nix` — user environment: packages, shell, git, editor, CLI tools (Home Manager)
- `files/.config/aerospace/` — AeroSpace tiling WM config
- `files/.config/wezterm/` — WezTerm terminal config
- `files/.config/karabiner/` — Karabiner Hyper-key config
- `blog.md` — local copy of the upstream [blog post](https://open.substack.com/pub/kunchenguid/p/how-i-built-a-reproducible-mac-setup?utm_campaign=post-expanded-share&utm_medium=web)

## How to use it

### 1. Clone the repo

```bash
git clone git@github.com:kunchenguid/dotfiles-mac-nix.git ~/Projects/dotfiles-mac-nix
cd ~/Projects/dotfiles-mac-nix
```

### 2. Replace the placeholders

Update values like:

- `yourname`
- `/Users/yourname`
- `Your Name`
- `you@example.com`

If you are on an Intel Mac, change the system target in `flake.nix` from:

```nix
system = "aarch64-darwin";
```

to:

```nix
system = "x86_64-darwin";
```

### 3. Run the bootstrap script on a fresh Mac

This repo is primarily set up for Apple Silicon Macs. If you are on Intel, make the architecture change above before you run the bootstrap script.

```bash
bash setup/mac.sh
```

The script will:

- install [Determinate Nix Installer](https://determinate.systems/nix-installer/) if needed
- install [Homebrew](https://brew.sh/) if needed
- apply the `nix-darwin` + Home Manager config
- install [`nvm`](https://github.com/nvm-sh/nvm) and a default Node.js version if needed

## Work laptop bootstrap

The flake defines two hosts: `mac` (personal) and `work`. Shared config
lives in `nix/host.nix` + `nix/user.nix`; machines differ only by
`nix/hosts/{personal,work}.nix`. The whole keyboard stack — AeroSpace,
WezTerm, Karabiner, Vorssaint, nvim, CLI toolkit — is shared and needs no
porting.

On the work laptop (Apple Silicon, admin):

1. Install Xcode CLT: `xcode-select --install`
2. Install [Determinate Nix](https://determinate.systems/nix-installer/)
   and [Homebrew](https://brew.sh/)
3. `git clone <this repo> ~/Projects/dotfiles-mac-nix` (path matters — the
   config derives from it)
4. Edit `nix/hosts/work.nix`: fill `username` (`whoami`); commit
5. Create the local git identity files (emails are deliberately NOT in
   this repo — git reads these untracked files at runtime; a missing
   file is silently ignored):
   ```
   mkdir -p ~/.config/git
   printf '[user]\n\temail = <WORK EMAIL>\n'     > ~/.config/git/identity
   cp ~/.config/git/identity                       ~/.config/git/identity-work
   printf '[user]\n\temail = <PERSONAL EMAIL>\n' > ~/.config/git/identity-personal
   ```
   Repos under `~/work/` commit with the work identity, `~/Projects/`
   with the personal one, anything else with `identity` (the default —
   work, on that machine).
6. First build (before the `rebuild` alias exists):
   `sudo nix run nix-darwin -- switch --flake ~/Projects/dotfiles-mac-nix#work`
   — from then on it's just `rebuild`
7. Manual, one-time per machine:
   - AeroSpace: launch → grant Accessibility → quit & relaunch
   - Karabiner-Elements: launch → grant its driver/input permissions
   - Vorssaint: launch → import settings from `files/vorssaint/` → grant
     Accessibility → verify window management + Super Key modules are OFF
   - Mission Control: delete extra Desktops, un-fullscreen any apps
     (AeroSpace manages one native Space)
   - System Settings → Trackpad → Natural scrolling ON (mouse inversion
     comes from Vorssaint)

Note `homebrewCleanup = "none"` on the work host: pre-existing apps are
left alone. Tighten to `"zap"` only after the app list is fully declared.

## How I manage changes later

After the initial bootstrap, the usual workflow is:

1. edit the Nix config
2. run:

```bash
rebuild
```

This alias is included in the shell config and expands to the repo path used in this guide:

```bash
/run/current-system/sw/bin/darwin-rebuild switch --flake ~/Projects/dotfiles-mac-nix#mac
```

## Where to add new tools

My rough rule of thumb:

- use **Home Manager / Nix** for reproducible baseline CLI tools, fonts, shell utilities, and user environment packages
- use **Homebrew** for GUI apps and macOS-native tools that fit naturally there
- use **ecosystem-specific package managers** like `npm` when that is the right abstraction for the tool

A good setup does not force every tool through one package manager. It just makes the ownership of each layer clear.

## Why this setup looks like this

I wanted a setup that was:

- reproducible on a new Mac
- structured enough to maintain
- pragmatic about macOS
- publishable without oversharing the rest of my workflow

That is why this repo focuses on the reusable core.

## Related

- Long-form write-up: [blog post](https://open.substack.com/pub/kunchenguid/p/how-i-built-a-reproducible-mac-setup?utm_campaign=post-expanded-share&utm_medium=web)
- GitHub repo: <https://github.com/kunchenguid/dotfiles-mac-nix>
