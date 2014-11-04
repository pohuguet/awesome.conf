local blingbling = require("blingbling")
local vicious = require("vicious")
local beautiful = require("beautiful")
local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")

local icon_path = awful.util.getdir("config").."/icons/"

syswidget = {}

-- Bottom widgets:
syswidget.cpu_graph = blingbling.line_graph({
   height = 16,
   width = 80,
   show_text = true,
   label = "Cpu: $percent %",
})
vicious.register(syswidget.cpu_graph, vicious.widgets.cpu,'$1',2)

syswidget.mem_graph = blingbling.line_graph({
   height = 16,
   width = 80,
   show_text = true,
   label = "Mem: $percent %",
})
vicious.register(syswidget.mem_graph, vicious.widgets.mem, '$1', 2)

syswidget.home_fs_usage=blingbling.value_text_box({
   height = 16,
   width = 40,
   v_margin = 3
})
syswidget.home_fs_usage:set_text_background_color(beautiful.widget_background)
syswidget.home_fs_usage:set_values_text_color(colors_stops)
syswidget.home_fs_usage:set_font_size(9)
syswidget.home_fs_usage:set_background_color("#00000000")
syswidget.home_fs_usage:set_label("home: $percent %")
vicious.register(syswidget.home_fs_usage, vicious.widgets.fs, "${/home used_p}", 120 )

syswidget.root_fs_usage=blingbling.value_text_box({
   height = 16,
   width = 40,
   v_margin = 3
})
syswidget.root_fs_usage:set_text_background_color(beautiful.widget_background)
syswidget.root_fs_usage:set_values_text_color(colors_stops)
--syswidget.root_fs_usage:set_rounded_size(0.4)
syswidget.root_fs_usage:set_font_size(9)
syswidget.root_fs_usage:set_background_color("#00000000")
syswidget.root_fs_usage:set_label("root: $percent %")
vicious.register(syswidget.root_fs_usage, vicious.widgets.fs, "${/ used_p}", 120 )


syswidget.pkg_updates = wibox.widget.imagebox()
syswidget.pkg_updates.n = {}
syswidget.pkg_updates.nb = 0

syswidget.pkg_updates:connect_signal("mouse::enter", function(widget)
   widget.n = naughty.notify({ text = widget.nb.." updates" })
end)
syswidget.pkg_updates:connect_signal("mouse::leave", function(widget)
  naughty.destroy(widget.n)
end)
syswidget.pkg_updates:buttons(awful.util.table.join(awful.button({ }, 1, function()
   local ret = awful.util.spawn(terminal.." -e su -c 'pacman -Suy'")
   naughty.notify({ text = ret })
end)))

vicious.register(syswidget.pkg_updates, vicious.widgets.pkg, function(widget, args)
   widget.nb = args[1]
   if args[1] == 0 then
      widget:set_image(icon_path.."ok-icon.png") 
   else
      --return "<span color=''>" .. args[1] .. "</span> new pkgs | "
      widget:set_image(icon_path.."reload-icon.png")
   end
end,60,"Arch")

return syswidget
