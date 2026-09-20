local wezterm = require("wezterm")

local config = wezterm.config_builder()

local is_windows = os.getenv("OS") and os.getenv("OS"):lower():find("windows")
local is_macos = wezterm.target_triple:lower():find("darwin") ~= nil

-- Fixed light scheme (bright room): ink-on-paper, 18.6:1 text contrast.
-- Alternatives auditioned 2026-09-20: rose-pine-dawn (too muted), Gruvbox
-- Light Hard, GitHub Light Default.
--
-- Defined INLINE because WezTerm stable 20240203 (the last stable release)
-- has its builtin scheme list frozen at Feb 2024 — Flexoki isn't in it, and
-- an unknown scheme name silently falls back to the DEFAULT DARK palette.
-- Palette: upstream iTerm2-Color-Schemes "Flexoki Light".
config.color_schemes = {
  ["Flexoki Light"] = {
    foreground = "#100f0f",
    background = "#fffcf0",
    cursor_bg = "#100f0f",
    cursor_border = "#100f0f",
    cursor_fg = "#fffcf0",
    selection_bg = "#cecdc3",
    selection_fg = "#100f0f",
    ansi = { "#100f0f", "#af3029", "#66800b", "#ad8301", "#205ea6", "#a02f6f", "#24837b", "#6f6e69" },
    brights = { "#b7b5ac", "#d14d41", "#879a39", "#d0a215", "#4385be", "#ce5d97", "#3aa99f", "#cecdc3" },
  },
  ["Atom One Light"] = {
    foreground = "#2a2c33",
    background = "#f9f9f9",
    cursor_bg = "#bbbbbb",
    cursor_border = "#bbbbbb",
    cursor_fg = "#ffffff",
    selection_bg = "#ededed",
    selection_fg = "#2a2c33",
    ansi = { "#000000", "#de3e35", "#3f953a", "#d2b67c", "#2f5af3", "#950095", "#3f953a", "#bbbbbb" },
    brights = { "#000000", "#de3e35", "#3f953a", "#d2b67c", "#2f5af3", "#a00095", "#3f953a", "#ffffff" },
  },
}
config.color_scheme = "Atom One Light"
config.max_fps = 120
config.font = wezterm.font("Hack Nerd Font", { weight = "DemiBold" })
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_frame = {
  font = wezterm.font("Hack Nerd Font", { weight = "Bold" }),
}
-- Gentle dim that reads correctly on a LIGHT scheme (the old
-- saturation 0 / brightness 0.5 turned panes charcoal on dawn).
config.inactive_pane_hsb = {
  saturation = 0.9,
  brightness = 0.95,
}

if is_windows then
  config.win32_system_backdrop = "Acrylic"
  config.window_background_opacity = 0.7
  config.window_frame.font_size = 10.0
end

if is_macos then
  -- 0.95, not 0.8: translucency tuned for dark washes a light scheme out.
  config.window_background_opacity = 0.95
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
-- AeroSpace binds ⌥⇧C to close, and the default confirmation (which only
-- appears when a process is still running) is the last line of defence
-- against a mistyped ⌥⇧C killing live jobs.

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
  -- Base-layer leader splits for the split keyboard (\ and - live on its
  -- Symbols layer). v = Terminator "vertical" = side by side; s = stacked.
  { key = "v", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "s", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

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

  -- ⌘A E: open the whole scrollback in nvim (new tab) — relative numbers,
  -- 7k/d3j motions, / search. Close with :q as usual; the temp file is
  -- cleaned up afterwards.
  {
    key = "e",
    mods = "LEADER",
    action = wezterm.action_callback(function(window, pane)
      local text = pane:get_lines_as_text(pane:get_dimensions().scrollback_rows)
      local name = os.tmpname()
      local f = io.open(name, "w+")
      f:write(text)
      f:flush()
      f:close()
      window:perform_action(
        act.SpawnCommandInNewTab({
          args = { "/etc/profiles/per-user/gayashan/bin/nvim", name, "+$" },
        }),
        pane
      )
      wezterm.time.call_after(2, function() os.remove(name) end)
    end),
  },
}

-- LEADER + 1..9 -> jump to tab N
for i = 1, 9 do
  table.insert(config.keys, { key = tostring(i), mods = "LEADER", action = act.ActivateTab(i - 1) })
end

return config
