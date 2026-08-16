{ config, pkgs, ... }:

let
  dotfilesDir = "${config.home.homeDirectory}/Projects/dotfiles-mac-nix";
in
{
  home.username = "gayashan";
  home.homeDirectory = "/Users/gayashan";
  home.stateVersion = "23.11";
  home.language.base = "en_US.UTF-8";

  home.packages = with pkgs; [
    git
    curl
    wget
    jq
    fd
    fastfetch
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
  ];

  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    # EDITOR is set to nvim by programs.neovim.defaultEditor
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
        email = "gayashan.amarasinghe@gmail.com";
      };
      core.editor = "nvim";
      color.ui = true;
      push.autoSetupRemote = true;
      pull.rebase = true;
      rebase.updateRefs = true;
    };
    delta = {
      enable = true;
      options = {
        navigate = true;
        line-numbers = true;
        side-by-side = true;
      };
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true; # sets EDITOR=nvim
    viAlias = true;
    vimAlias = true; # `vim` launches nvim; the old ~/.vimrc stops applying
    extraLuaConfig = ''
      -- ported from the old ~/.vimrc (snapshot: ~/keyboard-driven-rollback/.vimrc)
      vim.opt.number = true
      vim.opt.backup = false
      vim.opt.swapfile = false
      vim.opt.wrap = false
      vim.opt.mouse = "a"
      vim.opt.incsearch = true
      vim.opt.hlsearch = true
      vim.opt.ignorecase = true
      vim.opt.smartcase = true
      vim.opt.scrolloff = 3
      vim.opt.shiftwidth = 4
      vim.opt.softtabstop = 4
      vim.opt.tabstop = 4
      vim.opt.expandtab = true
      vim.opt.termguicolors = true
      vim.opt.clipboard = "unnamedplus"
      vim.g.mapleader = " "
      vim.keymap.set("n", "<leader>h", ":nohlsearch<CR>", { silent = true })
    '';
  };

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

  # Ctrl+R note: fzf's and atuin's zsh integrations both bind it; atuin should
  # own history search while fzf keeps Ctrl+T (files) and Alt+C (cd). If a
  # rebuild ever leaves Ctrl+R on fzf, re-init atuin last via a mkOrder'd
  # programs.zsh.initContent block.
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
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
      rebuild = "sudo /run/current-system/sw/bin/darwin-rebuild switch --flake ~/Projects/dotfiles-mac-nix#mac";
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
    ".config/aerospace".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/files/.config/aerospace";

    # Symlink the FILE, not the directory — Karabiner owns assets/ and
    # automatic_backups/ inside ~/.config/karabiner and writes to them.
    # If Karabiner's GUI rewrites this file, the next rebuild restores the
    # symlink (backupFileExtension); clear any stale .backup first:
    #   rm -f ~/.config/karabiner/karabiner.json.backup
    ".config/karabiner/karabiner.json".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/files/.config/karabiner/karabiner.json";
  };
}
