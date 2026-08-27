# Host facts for the work laptop (Apple Silicon, full admin, no MDM).
#
# FIRST BOOTSTRAP: fill the two CHANGE-ME values below on the work machine
# (`whoami` gives the username), then follow "Work laptop bootstrap" in the
# README.
{
  flakeAttr = "work";
  username = "CHANGE-ME"; # `whoami` on the work laptop
  gitEmail = "CHANGE-ME@work.example";

  # "none" until this machine's app list has been fully reconciled —
  # IT- or colleague-installed tools must not be silently uninstalled.
  # Tighten to "zap" deliberately, later, if ever.
  homebrewCleanup = "none";
  extraTaps = [ ];
  extraBrews = [ ];
  extraCasks = [ ];
  extraPackages = [ ];
}
