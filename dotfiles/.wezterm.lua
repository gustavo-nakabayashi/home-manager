local wezterm = require 'wezterm'

local mux = wezterm.mux
local act = wezterm.action

wezterm.on('gui-startup', function()
  local window = mux.spawn_window({})
  window:gui_window():maximize()

end)

local config = wezterm.config_builder()

config.window_decorations = "RESIZE"
config.color_scheme = 'tokyonight-storm'
config.font = wezterm.font('FiraCode Nerd Font')
config.font_size = 14
config.line_height = 1.2
config.use_dead_keys = false
config.scrollback_lines = 5000
-- config.window_background_opacity = 0
config.macos_window_background_blur = 100
config.hide_tab_bar_if_only_one_tab = true
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

config.keys = {}

for i = 1, 5, 1 do
  local x = {
    key = tostring(i),
    mods = 'SUPER',
    action = act.Multiple {
      act.SendKey { key = 'Space', mods = 'CTRL' },
      act.SendKey { key = tostring(i) },
    },
  }
  table.insert(config.keys, x)
end

config.background = {
  {
    source = {
      Color = 'black'
    },
    width = "100%",
    height = "100%",
    opacity = 0.75
  }
}

return config
