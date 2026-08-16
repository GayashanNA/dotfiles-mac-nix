{ pkgs, ... }:

{
  # If you use Determinate Nix Installer (recommended), let it manage Nix itself.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;

  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    # Don't auto-update taps during rebuild activation: Homebrew's tap-trust
    # is per-revision, so a mid-bundle tap update invalidates the trust for
    # nikitabobko/tap and aborts activation at the cleanup step. After any
    # deliberate `brew update`, re-run: brew trust nikitabobko/tap
    global.autoUpdate = false;
    taps = [
      "hashicorp/tap"
      "nikitabobko/tap" # AeroSpace
    ];
    brews = [
      "autoconf"
      "flyctl"
      "gh"
      "hashicorp/tap/terraform"
      "python@3.12"
      "ranger"
    ];
    casks = [
      "aerospace" # i3-style tiling WM (nikitabobko/tap)
      "wezterm"
      "amethyst" # keep during AeroSpace trial: removal would zap its prefs
      "claude"
      "docker-desktop"
      "firefox"
      "google-chrome"
      "google-drive"
      "karabiner-elements"
      "logi-options+"
      "obsidian"
      "visual-studio-code"
      "vlc"
      "windscribe"
    ];
  };

  environment.systemPackages = with pkgs; [
    starship
  ];

  system.primaryUser = "gayashan";
  users.users.gayashan = {
    home = "/Users/gayashan";
    shell = pkgs.zsh;
  };

  system.defaults = {
    NSGlobalDomain = {
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      "com.apple.swipescrolldirection" = false;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      AppleShowAllExtensions = true;
    };

    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
    };

    trackpad = {
      Clicking = true;
    };
  };

  environment.systemPath = [
    "/run/current-system/sw/bin"
    "/etc/profiles/per-user/gayashan/bin"
  ];

  system.stateVersion = 6;
}
