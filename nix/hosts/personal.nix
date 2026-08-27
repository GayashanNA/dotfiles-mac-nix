# Host facts for the personal MacBook Pro.
# Consumed by flake.nix and threaded into host.nix / user.nix as `hostSpec`.
{
  flakeAttr = "mac"; # darwinConfigurations.<attr>; the `rebuild` alias uses it
  username = "gayashan";
  gitEmail = "gayashan.amarasinghe@gmail.com";

  # Homebrew: anything not declared gets uninstalled on rebuild ("zap").
  # Safe here because this machine's list has been reconciled.
  homebrewCleanup = "zap";
  extraTaps = [ ];
  extraBrews = [
    "autoconf"
    "flyctl"
    "python@3.12"
  ];
  extraCasks = [
    "docker-desktop"
    "google-drive"
    "logi-options+"
    "vlc"
    "windscribe"
  ];
  extraPackages = [ ]; # nixpkgs attribute names (see user.nix)
}
