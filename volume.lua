local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")

volume_widget = wibox.widget.imagebox()
volume_widget.volume = 0
volume_widget.muted = false
volume_widget.full_notified = false
local mouse_over

volume_widget:connect_signal("mouse::enter", function()
   local text = "Volume : "..volume_widget.volume.."%"
   if volume_widget.muted then text = text.." (muted)" end
   mouse_over = naughty.notify({ text = text })
end)
volume_widget:connect_signal("mouse::leave", function()
   naughty.destroy(mouse_over)
end)

function update_volume(widget)
   local fd = io.popen("amixer sget Master")
   local status = fd:read("*all")
   fd:close()
   local icon_path = awful.util.getdir("config").."/icons/"
 
   local volume = tonumber(string.match(status, "(%d?%d?%d)%%"))
   local icon_prefix = "016_Status-audio-volume-"
   local icon_suffix = "-icon.png"
   local level = ""
 
   status = string.match(status, "%[(o[^%]]*)%]")
   local muted = string.find(status, "off", 1, true)

   if volume == 0 or muted then
       level = "muted"
   elseif volume < 45 then
       level = "low"
   elseif volume < 90 then
       level = "medium"
   else
       level = "high"
   end
   if volume == 100 and not full_notified and not muted then
      naughty.notify({ text = "Volume : "..volume.."%" })
      full_notified = true
   elseif volume < 100 or muted then
      full_notified = false
   end

   widget.volume = volume
   widget.muted = muted
   widget.full_notified = full_notified
   widget:set_image(icon_path..icon_prefix..level..icon_suffix)
end
 
update_volume(volume_widget)
 
mytimer = timer({ timeout = 0.2 })
mytimer:connect_signal("timeout", function () update_volume(volume_widget) end)
mytimer:start()

