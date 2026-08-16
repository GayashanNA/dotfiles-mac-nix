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
    EDITOR = "vim";
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
      core.editor = "vim";
      color.ui = true;
      push.autoSetupRemote = true;
      pull.rebase = true;
      rebase.updateRefs = true;
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
      ll = "ls -alF";
      la = "ls -A";
      l = "ls -CF";
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
