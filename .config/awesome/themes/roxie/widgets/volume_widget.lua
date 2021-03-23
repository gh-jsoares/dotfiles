local wibox = require('wibox')
local beautiful = require('beautiful')
local gears = require('gears')

local ICON_DIR = os.getenv('HOME') .. '/.config/awesome/themes/roxie/icons/'

local widget = {}

function widget.get_widget()
    local main_color = beautiful.fg_normal
    local mute_color = beautiful.fg_urgent
    local bg_color = '#ffffff11'
    local width = 30
    local margins = 7
    local with_icon = true

    local bar = wibox.widget {
        {
            {
                id = 'icon',
                image = ICON_DIR .. 'audio-volume-high-symbolic.svg',
                resize = false,
                widget = wibox.widget.imagebox,
            },
            valign = 'center',
            visible = with_icon,
            layout = wibox.container.place,
        },
        {
            id = 'bar',
            max_value = 100,
            forced_width = width,
            color = main_color,
            margins = { top = margins, bottom = margins },
            background_color = bg_color,
            shape = gears.shape[shape],
            widget = wibox.widget.progressbar,
        },
        spacing = 4,
        layout = wibox.layout.fixed.horizontal,
        set_volume_level = function(self, new_value)
		local value = tonumber(new_value)
            	self:get_children_by_id('bar')[1]:set_value(value)
		if value == 0 or self.muted then
            		self:get_children_by_id('icon')[1]:set_image(ICON_DIR .. 'audio-volume-muted-symbolic.svg')
		elseif value > 66 then
            		self:get_children_by_id('icon')[1]:set_image(ICON_DIR .. 'audio-volume-high-symbolic.svg')
		elseif value > 33 then
            		self:get_children_by_id('icon')[1]:set_image(ICON_DIR .. 'audio-volume-medium-symbolic.svg')
		else
            		self:get_children_by_id('icon')[1]:set_image(ICON_DIR .. 'audio-volume-low-symbolic.svg')
		end
        end,
        mute = function(self)
		self.muted = true
            	self:get_children_by_id('bar')[1]:set_color(mute_color)
            	self:get_children_by_id('icon')[1]:set_image(ICON_DIR .. 'audio-volume-muted-symbolic.svg')
        end,
        unmute = function(self)
		self.muted = false
            	self:get_children_by_id('bar')[1]:set_color(main_color)
        end
    }

    return bar
end

return widget
