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
   widget.rate = args['{rate}']
   widget.sign = args['{sign}']
   widget.linp = args['{linp}']

   local text = "ssid: "..widget.ssid.."\n"
           .."rate: "..widget.rate.."\n"
           .."sign: "..widget.sign.."\n"
           .."linp: "..widget.linp

--   naughty.notify({ text = text })

   local value = "000"
   if widget.ssid == "N/A" then
      value= "none"
   elseif widget.linp >= 90 then
      value = "100"
   elseif widget.linp > 60 then
      value = "075"
   elseif widget.linp > 40 then
      value = "050"
   elseif widget.linp > 15 then
      value = "025"
   end
      

   local f = "016_wifi-"..value.."-icon.png"
   widget:set_image(icon_path..f)
end, 10, "wlan0")

--w.wifi = blingbling.net({
--   width = 400,
--   height = 16,
--   interface = "wlan0",
--})
--w.wifi:set_ippopup()


return w
