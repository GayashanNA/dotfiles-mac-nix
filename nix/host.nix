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
      # Fully-qualified on purpose: brew bundle rewrites ~/.homebrew/trust.json
      # on every run, keeping only entries it can attribute to a tap via the
      # Brewfile. A bare "aerospace" loses its trust entry each rebuild and
      # fails activation at cleanup; the qualified name self-maintains trust.
      "nikitabobko/tap/aerospace" # i3-style tiling WM
      "wezterm"
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
      "vorssaint" # menu bar toolkit: volume mixer, system monitor, clipboard
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
      # Natural scrolling ON for the trackpad; the MX Vertical mouse is
      # inverted back to classic wheel scrolling per-device in Logi Options+.
      "com.apple.swipescrolldirection" = true;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      AppleShowAllExtensions = true;
    };

    dock = {
      # Stop macOS reordering Spaces by recency — with AeroSpace, native
      # Space switching must be deterministic (also applied imperatively
      # 2026-08-16; declared here so it survives rebuilds).
      mru-spaces = false;
      # Group Mission Control thumbnails by app: AeroSpace parks hidden
      # windows shrunk in a corner, which otherwise renders in Mission
      # Control as unusable confetti (AeroSpace-documented workaround).
      expose-group-apps = true;
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
