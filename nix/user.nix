{ config, pkgs, lib, hostSpec, ... }:

let
  dotfilesDir = "${config.home.homeDirectory}/Projects/dotfiles-mac-nix";
in
{
  home.username = hostSpec.username;
  home.homeDirectory = "/Users/${hostSpec.username}";
  home.stateVersion = "23.11";
  # No home-manager manual man pages: their options.json doc build trips
  # the "without a proper context" eval warning under Determinate Nix.
  manual.manpages.enable = false;
  home.language.base = "en_US.UTF-8";

  home.packages = with pkgs; [
    git
    curl
    wget
    jq
    fd
    fastfetch
    awscli2 # declarative aws CLI (personal Mac also has an imperative /usr/local/bin/aws from the Amazon .pkg — the nix one takes PATH precedence)
    neovim
    poppler-utils # pdftotext & friends (was lost when brew zapped herdr's deps)
    gnumake # kickstart.nvim: build dep
    tree-sitter # kickstart.nvim: nvim-treesitter main branch requires the CLI to install parsers
    ripgrep
    killall
    lazygit
    tree
    bun
    rustup
    zip
    unzip
    jdk21
    nerd-fonts.hack
    roboto
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    font-awesome
  ] ++ map (name: pkgs.${name}) hostSpec.extraPackages;

  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    JAVA_HOME = "${pkgs.jdk21.home}";
    ANDROID_HOME = "${config.home.homeDirectory}/Library/Android/sdk";
  };

  # Android SDK is installed imperatively via sdkmanager under ~/Library/Android/sdk;
  # Flutter stays a manual install under ~/development/flutter (pinned to 3.44.x).
  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/development/flutter/bin"
    "${config.home.homeDirectory}/Library/Android/sdk/platform-tools"
    "${config.home.homeDirectory}/Library/Android/sdk/cmdline-tools/latest/bin"
    "${config.home.homeDirectory}/Library/Android/sdk/emulator"
  ];

  programs.git = {
    enable = true;
    lfs.enable = true;
    signing.format = null;
    settings = {
      user = {
        name = "Gayashan Amarasinghe";
        email = hostSpec.gitEmail;
      };
      core.editor = "nvim";
      color.ui = true;
      push.autoSetupRemote = true;
      pull.rebase = true;
      rebase.updateRefs = true;
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      line-numbers = true;
      side-by-side = true;
    };
  };

  # Neovim is a plain package, NOT programs.neovim: the module generates its
  # own ~/.config/nvim/init.lua, which collides with the kickstart.nvim config
  # tracked in files/.config/nvim/ (linked writable below so lazy.nvim can
  # keep lazy-lock.json version-controlled in the repo). EDITOR and vim/vi
  # aliases are set manually instead of via the module.

  # tmux prefix "C-a" is Ctrl+A (tmux runs in the shell and never sees Cmd).
  # Deliberately distinct from WezTerm's Cmd+A leader.
  programs.tmux = {
    enable = true;
    prefix = "C-a";
    keyMode = "vi";
    mouse = true;
    baseIndex = 1;
    escapeTime = 10;
    terminal = "tmux-256color"; # HM default is "screen" — wrong for WezTerm
    extraConfig = ''
      # Terminator terminology: -h gives SIDE-BY-SIDE panes.
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind C-a send-prefix
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      set -g renumber-windows on
    '';
  };

  # atuin owns Ctrl+R (its integration is sourced after fzf's); fzf keeps
  # Ctrl+T (files) and Alt+C (cd). historyWidget disabled to make that explicit.
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    historyWidget.command = "";
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [ "--height=40%" "--layout=reverse" "--border" ];
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "auto";
    git = true;
  };

  programs.bat = {
    enable = true;
    config.theme = "base16";
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    flags = [ "--disable-up-arrow" ];
    settings = {
      style = "compact";
      inline_height = 20;
      show_preview = true;
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      command_timeout = 1000;
      add_newline = false;
      format = "$username$hostname$directory$git_branch$git_state$git_status$cmd_duration$line_break$character";

      directory.style = "blue";

      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
        vimcmd_symbol = "[❮](green)";
      };

      git_branch = {
        format = "[$branch]($style)";
        style = "bright-black";
      };

      git_status = {
        format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)";
        style = "cyan";
        stashed = "≡";
      };

      git_state = {
        format = "\\([$state( $progress_current/$progress_total)]($style)\\) ";
        style = "bright-black";
      };

      cmd_duration = {
        format = "[$duration]($style) ";
        style = "yellow";
      };

      python = {
        format = "[$virtualenv]($style) ";
        style = "bright-black";
      };
    };
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ".." = "cd ..";
      "..." = "cd ../../";
      m = "git switch main";
      mst = "git switch master";
      pull = "git pull";
      push = "git push";
      pushf = "git push --force";
      add = "git add .";
      amend = "git commit --amend";
      reset = "git reset --soft HEAD^";
      rebasem = "git rebase -i main";
      rebasemst = "git rebase -i master";
      rebuild = "sudo /run/current-system/sw/bin/darwin-rebuild switch --flake ~/Projects/dotfiles-mac-nix#${hostSpec.flakeAttr}";
      ll = "eza -la --group-directories-first --git";
      la = "eza -a";
      l = "eza";
      gcm = "git checkout master";
      gits = "git status";
      gitp = "git push -v";
      glp = "git log --pretty=oneline";
      tailf = "tail -n 100 -f";
      fn = "find -name";
      mv = "mv -v";
      cp = "cp -v";
      nv = "nvim";
      vim = "nvim";
      vi = "nvim";
      qq = "ranger .";
      prj = "cd ~/Projects/";
      pip = "pip3";
      python = "python3";
    };
    profileExtra = ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
    '';
    initContent = ''
      bindkey '^f' autosuggest-accept
    '';
  };

  home.file = {
    ".config/wezterm".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/files/.config/wezterm";
    # Writable target on purpose: lazy.nvim maintains lazy-lock.json inside
    # the repo, so plugin versions are tracked in git alongside init.lua.
    ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/files/.config/nvim";
  };

  # AeroSpace and Karabiner read their configs at LOGIN, before the /nix
  # volume may be mounted. home.file symlinks route through /nix/store
  # (~/.config/x -> /nix/store/...-home-manager-files/... -> repo), which
  # dangles at that moment — both apps then silently fall back to default
  # configs (no shortcuts, no Hyper key) until manually reloaded. So these
  # two are linked DIRECTLY to the repo, no store hop.
  #
  # karabiner: link the FILE, not the directory — Karabiner owns assets/
  # and automatic_backups/ in ~/.config/karabiner and writes to them. If
  # Karabiner's GUI ever replaces the symlink with a real file, rerun
  # `rebuild` to restore it.
  home.activation.loginCriticalConfigLinks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ln -sfn "${dotfilesDir}/files/.config/aerospace" "$HOME/.config/aerospace"
    mkdir -p "$HOME/.config/karabiner"
    ln -sfn "${dotfilesDir}/files/.config/karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"
  '';
}
