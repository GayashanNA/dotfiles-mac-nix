local wezterm = require("wezterm")

local config = wezterm.config_builder()

local is_windows = os.getenv("OS") and os.getenv("OS"):lower():find("windows")
local is_macos = wezterm.target_triple:lower():find("darwin") ~= nil

config.color_scheme = "rose-pine-moon"
config.max_fps = 120
config.font = wezterm.font("Hack Nerd Font", { weight = "DemiBold" })
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_frame = {
  font = wezterm.font("Hack Nerd Font", { weight = "Bold" }),
}
config.inactive_pane_hsb = {
  saturation = 0.0,
  brightness = 0.5,
}

if is_windows then
  config.win32_system_backdrop = "Acrylic"
  config.window_background_opacity = 0.7
  config.window_frame.font_size = 10.0
end

if is_macos then
  config.window_background_opacity = 0.8
  config.macos_window_background_blur = 50
  config.font_size = 15.0
  config.window_frame.font_size = 13.0
end

-- ===========================================================================
-- Tiling-WM friendliness (AeroSpace)
-- ===========================================================================
-- Don't let font-size changes resize the OS window out from under AeroSpace.
config.adjust_window_size_when_changing_font_size = false
-- Deliberately NOT setting window_close_confirmation = "NeverPrompt":
-- AeroSpace binds ⌥Q to close, and the default confirmation (which only
-- appears when a process is still running) is the last line of defence
-- against a mistyped ⌥Q killing live jobs.

-- ===========================================================================
-- Keys: Terminator muscle memory
-- ===========================================================================
-- Mods below are WezTerm's names for Mac keys: ALT = ⌥ Option, CMD = ⌘,
-- CTRL = ⌃, SHIFT = ⇧.
--
-- TERMINOLOGY (do not "fix" this, it is correct):
--   Terminator "Split Vertically"   (⌃⇧E) = panes SIDE BY SIDE = SplitHorizontal
--   Terminator "Split Horizontally" (⌃⇧O) = panes STACKED      = SplitVertical
--
-- Division of labour, no collisions (letters vs arrows):
--   ⌥ + h/j/k/l -> AeroSpace: focus between OS WINDOWS
--   ⌥ + arrows  -> WezTerm:   focus between PANES
--
-- LEADER is ⌘A. ⌘ never leaves the terminal emulator, so it cannot collide
-- with tmux (prefix ⌃A), zsh (⌃A = beginning-of-line), or nvim.
local act = wezterm.action

config.leader = { key = "a", mods = "CMD", timeout_milliseconds = 1000 }

config.keys = {
  -- splits -- ⌃⇧E = Terminator "split vertically" = pane to the RIGHT
  { key = "e", mods = "CTRL|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  -- ⌃⇧O = Terminator "split horizontally" = pane BELOW
  { key = "o", mods = "CTRL|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "\\", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

  -- pane navigation
  { key = "LeftArrow", mods = "ALT", action = act.ActivatePaneDirection("Left") },
  { key = "DownArrow", mods = "ALT", action = act.ActivatePaneDirection("Down") },
  { key = "UpArrow", mods = "ALT", action = act.ActivatePaneDirection("Up") },
  { key = "RightArrow", mods = "ALT", action = act.ActivatePaneDirection("Right") },
  { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
  { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
  { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
  { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
  { key = "p", mods = "LEADER", action = act.PaneSelect({}) },

  -- pane resize
  { key = "LeftArrow", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Left", 3 }) },
  { key = "DownArrow", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Down", 3 }) },
  { key = "UpArrow", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Up", 3 }) },
  { key = "RightArrow", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Right", 3 }) },

  -- pane lifecycle
  { key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentPane({ confirm = true }) },
  { key = "x", mods = "CTRL|SHIFT", action = act.TogglePaneZoomState },
  { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
  { key = "r", mods = "LEADER", action = act.RotatePanes("Clockwise") },

  -- tabs
  { key = "t", mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "PageUp", mods = "CTRL", action = act.ActivateTabRelative(-1) },
  { key = "PageDown", mods = "CTRL", action = act.ActivateTabRelative(1) },

  -- new OS window (AeroSpace tiles it beside the current one)
  { key = "n", mods = "LEADER", action = act.SpawnWindow },

  { key = "f", mods = "LEADER", action = act.Search({ CaseSensitiveString = "" }) },
  { key = "[", mods = "LEADER", action = act.ActivateCopyMode },
}

-- LEADER + 1..9 -> jump to tab N
for i = 1, 9 do
  table.insert(config.keys, { key = tostring(i), mods = "LEADER", action = act.ActivateTab(i - 1) })
end

return config
