local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")
local icon_path = awful.util.getdir("config").."/icons/"

battery_widget = wibox.widget.imagebox()
battery_widget.adapter = "BAT0"
battery_widget.low_notified = false
battery_widget.battery = 0
battery_widget.charging = false
local mouse_over
 
battery_widget:connect_signal("mouse::enter", function()
   mouse_over = naughty.notify({
      text = "Battery : "..battery_widget.battery.."%"
   })
end)
battery_widget:connect_signal("mouse::leave", function()
   naughty.destroy(mouse_over)
end)
 
function battery_status(widget)
   local sys_path = "/sys/class/power_supply/"..widget.adapter.."/"
   local sys_files = { "charge_now", "charge_full", "status" }
   local values = {}

   for i,file in ipairs(sys_files) do
      local f = io.open(sys_path..file)
      values[file] = f:read()
      f:close()
   end

   local icon_prefix = "016_Status-battery-"
   local icon_suffix = "-icon.png"
   local level = ""
   local battery = math.floor(values["charge_now"] * 100 / values["charge_full"])
   local charging = (not values["status"]:match("Discharging"))

   if battery > 100 then
      battery = 100
   end
   level = string.format("%03d", math.floor((battery+19)/20)*20)

   if charging then
      level = "charging-" .. level
      low_notified = false
   end

   if ((battery < 20) and (not charging) and (not low_notified)) then
      naughty.notify({
         text = "Low battery",
         icon = icon_path.."016_Status-battery-missing-icon.png"
      })
      low_notified = true
   end

   widget.low_notified = low_notified
   widget.battery = battery
   widget.charging = charging
   widget:set_image(icon_path..icon_prefix..level..icon_suffix)
end
 
battery_status(battery_widget)
 
mytimer = timer({ timeout = 1 })
mytimer:connect_signal("timeout", function () battery_status(battery_widget) end)
mytimer:start()

