local awful = require("awful")
local spawn = require("awful.spawn")
local watch = require("awful.widget.watch")
local horizontal_bar = require("themes.roxie.widgets.volume_widget")

local GET_VOLUME_CMD = 'amixer -D pulse sget Master'
local INC_VOLUME_CMD = 'amixer -D pulse sset Master 5%+'
local DEC_VOLUME_CMD = 'amixer -D pulse sset Master 5%-'
local TOG_VOLUME_CMD = 'amixer -D pulse sset Master toggle'

local volume = {}

local function worker()
    local refresh_rate = 0.3

    volume.widget = horizontal_bar.get_widget()
    local volume_level = 0

    local function update_graphic(widget, stdout)
        local mute = string.match(stdout, "%[(o%D%D?)%]")   -- \[(o\D\D?)\] - [on] or [off]
        if mute == 'off' then
		widget:mute()
	elseif mute == 'on' then
		widget:unmute()
	end
        volume_level = string.match(stdout, "(%d?%d?%d)%%") -- (\d?\d?\d)\%)
        volume_level = string.format("% 3d", volume_level)
        widget:set_volume_level(volume_level)
    end

    function volume:inc()
        spawn.easy_async(INC_VOLUME_CMD, function(stdout) update_graphic(volume.widget, stdout) end)
    end

    function volume:dec()
        spawn.easy_async(DEC_VOLUME_CMD, function(stdout) update_graphic(volume.widget, stdout) end)
    end

    function volume:toggle()
        spawn.easy_async(TOG_VOLUME_CMD, function(stdout) update_graphic(volume.widget, stdout) end)
    end

    volume.widget:buttons(
            awful.util.table.join(
                    awful.button({}, 4, function() volume:inc() end),
                    awful.button({}, 5, function() volume:dec() end),
                    awful.button({}, 1, function() volume:toggle() end)
            )
    )
    local volume_tooltip = awful.tooltip {
		objects        = { volume.widget },
		timer_function = function() return volume_level end,
	}

    watch(GET_VOLUME_CMD, refresh_rate, update_graphic, volume.widget)

    return volume.widget
end

return setmetatable(volume, { __call = function(_, ...) return worker(...) end })
