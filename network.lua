local blingbling = require("blingbling")
local vicious = require("vicious")
local beautiful = require("beautiful")
local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")

local icon_path = awful.util.getdir("config").."/icons/"

w = {}

w.wifi = wibox.widget.imagebox()
w.wifi:fit(14,14)
w.wifi:set_resize(true)

vicious.register(w.wifi, vicious.widgets.wifi, function(widget, args)
   widget.ssid = args['{ssid}']

   local f = "016_wifi-"

   f = f.."100"
   f = f.."-icon.png"
   widget:set_image(icon_path..f)
end, 36000, "wlan")



return w
