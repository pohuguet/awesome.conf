---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local math = { ceil = math.ceil }
local setmetatable = setmetatable
local helpers = require("vicious.helpers")
local awful = require("awful")

local io = {
    open  = io.open,
    popen = io.popen
}
local string = {
    find  = string.find,
    match = string.match
}
-- }}}


-- Wifi: provides wireless information for a requested interface
-- vicious.widgets.wifi
local wifi = {}


-- {{{ Variable definitions
local iw_bin = "iw"
local iw_paths = { "/sbin", "/usr/sbin", "/usr/local/sbin", "/usr/bin" }
-- }}}


-- {{{ Wireless widget type
local function worker(format, warg)
    if not warg then return end

    -- Default values
    local winfo = {
        ["{ssid}"] = "N/A",
        ["{mode}"] = "N/A",
        ["{chan}"] = 0,
        ["{rate}"] = 0,
        ["{link}"] = 0,
        ["{linp}"] = 0,
        ["{sign}"] = 0
    }

    -- Sbin paths aren't in user PATH, search for the binary
    if iw_bin == "iw" then
        for _, p in ipairs(iw_paths) do
            local f = io.open(p.."/"..iw_bin, "rb")
            if f then
                iw_bin = p.."/"..iw_bin
                f:close()
                break
            end
        end
    end

    -- Get data from iw_bin where available
    local f = io.popen(iw_bin.." dev ".. warg.." link 2>&1")
    local iw = f:read("*all")
    f:close()

    -- iw_bin wasn't found, isn't executable, or non-wireless interface
    if iw == nil or string.find(iw, "No such device") then
        return winfo
    end

    -- Output differs from system to system, some stats can be
    -- separated by =, and not all drivers report all stats

    -- SSID can have almost anything in it
    winfo["{ssid}"] = helpers.escape(
      --string.match(iw, 'SSID[=:]([%s]?[^\n]*)'
      string.match(iw, 'SSID[=:][%s]?([^\n]*)'
    ) or winfo["{ssid}"])

    -- Modes are simple, but also match the "-" in Ad-Hoc
    winfo["{mode}"] = string.match(iw, "Mode[=:]([%w%-]*)") or winfo["{mode}"]

    -- Channels are plain digits
    winfo["{chan}"] = tonumber(
      string.match(iw, "Channel[=:]([%d]+)"
    ) or winfo["{chan}"])

    -- Bitrate can start with a space, we don't want to display Mb/s
    winfo["{rate}"] = tonumber(
      string.match(iw, "tx bitrate[=:]([%s]?[%d%.]*)"
    ) or winfo["{rate}"])

    -- Link quality can contain a slash (32/70), match only the first number
    winfo["{link}"] = tonumber(
      string.match(iw, "Link Quality[=:]([%d]+)"
    ) or winfo["{link}"])

    -- Link quality percentage
    winfo["{linp}"] = tonumber(
      string.match(
         awful.util.pread("awk 'NR==3 {print $3 \"00\"}' /proc/net/wireless"),
         "([%d+]*)"
      ) or winfo["{linp}"]
    )
    if not winfo["{linp}"] then winfo["{linp}"] = 0 end

    -- Signal level can be a negative value, don't display decibel notation
    winfo["{sign}"] = tonumber(
      string.match(iw, "signal[=:]([%s]?[%-]?[%d]+)"
    ) or winfo["{sign}"])

    return winfo
end
-- }}}

return setmetatable(wifi, { __call = function(_, ...) return worker(...) end })
