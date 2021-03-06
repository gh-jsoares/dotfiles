-- {{{ Required libraries
local awesome, client, mouse, screen, tag = awesome, client, mouse, screen, tag
local ipairs, string, os, table, tostring, tonumber, type = ipairs, string, os, table, tostring, tonumber, type

local gears         = require("gears")
local awful         = require("awful")
require("awful.autofocus")
local wibox         = require("wibox")
local beautiful     = require("beautiful")
local naughty       = require("naughty")
local lain          = require("lain")
--local menubar       = require("menubar")
local freedesktop   = require("freedesktop")
local hotkeys_popup = require("awful.hotkeys_popup").widget
require("awful.hotkeys_popup.keys")
local my_table      = awful.util.table or gears.table -- 4.{0,1} compatibility
local dpi           = require("beautiful.xresources").apply_dpi
-- }}}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify({ preset = naughty.config.presets.critical,
	title = "Oops, there were errors during startup!",
	text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function (err)
		if in_error then return end
		in_error = true

		naughty.notify({ preset = naughty.config.presets.critical,
		title = "Oops, an error happened!",
		text = tostring(err) })
		in_error = false
	end)
end
-- }}}

-- {{{ Autostart windowless processes

-- This function will run once every time Awesome is started
local function run_once(cmd_arr)
	for _, cmd in ipairs(cmd_arr) do
		awful.spawn.with_shell(string.format("pgrep -u $USER -fx '%s' > /dev/null || (%s)", cmd, cmd))
	end
end

run_once({
	"unclutter -root",
	"xset -b",
	"vmtoolsd -n vmusr",
	"picom -b --config $HOME/.config/picom.conf"
	--"nitrogen --restore"
}) -- entries must be separated by commas

-- }}}

-- {{{ Variable definitions

local chosen_theme = "roxie"
local modkey       = "Mod4"
local altkey       = "Mod1"
local terminal     = "alacritty"
local vi_focus     = false -- vi-like client focus - https://github.com/lcpz/awesome-copycats/issues/275
local cycle_prev   = true -- cycle trough all previous client or just the first -- https://github.com/lcpz/awesome-copycats/issues/274
local editor       = os.getenv("EDITOR") or "nvim"
local browser      = os.getenv("BROWSER") or "chromium"
local scrlocker    = "slock"

awful.util.terminal = terminal
awful.util.tagnames = { "1", "2", "3", "4", "5" }
awful.layout.layouts = {
	--awful.layout.suit.floating,
	awful.layout.suit.tile,
	--awful.layout.suit.tile.left,
	--awful.layout.suit.tile.bottom,
	--awful.layout.suit.tile.top,
	--awful.layout.suit.fair,
	--awful.layout.suit.fair.horizontal,
	--awful.layout.suit.spiral,
	--awful.layout.suit.spiral.dwindle,
	--awful.layout.suit.max,
	--awful.layout.suit.max.fullscreen,
	--awful.layout.suit.magnifier,
	--awful.layout.suit.corner.nw,
	--awful.layout.suit.corner.ne,
	--awful.layout.suit.corner.sw,
	--awful.layout.suit.corner.se,
	--lain.layout.cascade,
	--lain.layout.cascade.tile,
	--lain.layout.centerwork,
	--lain.layout.centerwork.horizontal,
	--lain.layout.termfair,
	--lain.layout.termfair.center,
}

awful.util.taglist_buttons = my_table.join(
awful.button({ }, 1, function(t) t:view_only() end),
awful.button({ modkey }, 1, function(t)
	if client.focus then
		client.focus:move_to_tag(t)
	end
end),
awful.button({ }, 3, awful.tag.viewtoggle),
awful.button({ modkey }, 3, function(t)
	if client.focus then
		client.focus:toggle_tag(t)
	end
end),
awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

awful.util.tasklist_buttons = my_table.join(
awful.button({ }, 1, function (c)
	if c == client.focus then
		c.minimized = true
	else
		--c:emit_signal("request::activate", "tasklist", {raise = true})<Paste>

		-- Without this, the following
		-- :isvisible() makes no sense
		c.minimized = false
		if not c:isvisible() and c.first_tag then
			c.first_tag:view_only()
		end
		-- This will also un-minimize
		-- the client, if needed
		client.focus = c
		c:raise()
	end
end),
awful.button({ }, 2, function (c) c:kill() end),
awful.button({ }, 3, function ()
	local instance = nil

	return function ()
		if instance and instance.wibox.visible then
			instance:hide()
			instance = nil
		else
			instance = awful.menu.clients({theme = {width = dpi(250)}})
		end
	end
end),
awful.button({ }, 4, function () awful.client.focus.byidx(1) end),
awful.button({ }, 5, function () awful.client.focus.byidx(-1) end)
)

lain.layout.termfair.nmaster           = 3
lain.layout.termfair.ncol              = 1
lain.layout.termfair.center.nmaster    = 3
lain.layout.termfair.center.ncol       = 1
lain.layout.cascade.tile.offset_x      = dpi(2)
lain.layout.cascade.tile.offset_y      = dpi(32)
lain.layout.cascade.tile.extra_padding = dpi(5)
lain.layout.cascade.tile.nmaster       = 5
lain.layout.cascade.tile.ncol          = 2

beautiful.init(string.format("%s/.config/awesome/themes/%s/theme.lua", os.getenv("HOME"), chosen_theme))
-- }}}

-- {{{ Menu
local myawesomemenu = {
	{ "hotkeys", function() return false, hotkeys_popup.show_help end },
	{ "manual", terminal .. " -e man awesome" },
	{ "edit config", string.format("%s -e %s %s", terminal, editor, awesome.conffile) },
	{ "restart", awesome.restart },
	{ "quit", function() awesome.quit() end }
}
awful.util.mymainmenu = freedesktop.menu.build({
	icon_size = beautiful.menu_height or dpi(16),
	before = {
		{ "Awesome", myawesomemenu, beautiful.awesome_icon },
		-- other triads can be put here
	},
	after = {
		{ "Open terminal", terminal },
		-- other triads can be put here
	}
})

--menubar.utils.terminal = terminal -- Set the Menubar terminal for applications that require it
-- }}}

-- {{{ Screen
-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", function(s)
	-- Wallpaper
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		-- If wallpaper is a function, call it with the screen
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, true)
	end
end)

-- No borders when rearranging only 1 non-floating or maximized client
screen.connect_signal("arrange", function (s)
	local only_one = #s.tiled_clients == 1
	for _, c in pairs(s.clients) do
		if c.fullscreen or c.maximized then
			c.border_width = 0
		else
			c.border_width = beautiful.border_width
		end
	end
end)

-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(function(s) beautiful.at_screen_connect(s) end)
-- }}}

-- {{{ Mouse bindings
root.buttons(my_table.join(
	awful.button({ }, 3, function () awful.util.mymainmenu:toggle() end),
	awful.button({ }, 4, awful.tag.viewnext),
	awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = my_table.join(
-- Hotkeys
awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
{description = "show help", group="awesome"}),

-- Tag browsing
awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
{description = "view previous", group = "tag"}),
awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
{description = "view next", group = "tag"}),
awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
{description = "go back", group = "tag"}),

-- Non-empty tag browsing
awful.key({ altkey }, "Left", function () lain.util.tag_view_nonempty(-1) end,
{description = "view  previous nonempty", group = "tag"}),
awful.key({ altkey }, "Right", function () lain.util.tag_view_nonempty(1) end,
{description = "view  previous nonempty", group = "tag"}),

-- By direction client focus
awful.key({ altkey }, "j",
function()
	awful.client.focus.global_bydirection("down")
	if client.focus then client.focus:raise() end
end,
{description = "focus down", group = "client"}),
awful.key({ altkey }, "k",
function()
	awful.client.focus.global_bydirection("up")
	if client.focus then client.focus:raise() end
end,
{description = "focus up", group = "client"}),
awful.key({ altkey }, "h",
function()
	awful.client.focus.global_bydirection("left")
	if client.focus then client.focus:raise() end
end,
{description = "focus left", group = "client"}),
awful.key({ altkey }, "l",
function()
	awful.client.focus.global_bydirection("right")
	if client.focus then client.focus:raise() end
end,
{description = "focus right", group = "client"}),

-- Show menu
awful.key({ modkey,           }, "w", function () awful.util.mymainmenu:show() end,
{description = "show main menu", group = "awesome"}),

-- Layout manipulation
awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
{description = "swap with next client by index", group = "client"}),
awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
{description = "swap with previous client by index", group = "client"}),
awful.key({ modkey,           }, "Tab",
function ()
	if cycle_prev then
		awful.client.focus.byidx(1)
		if client.focus then
			client.focus:raise()
		end
	end
end,
{description = "go forth", group = "client"}),
awful.key({ modkey, "Shift"   }, "Tab",
function ()
	if cycle_prev then
		awful.client.focus.byidx(-1)
		if client.focus then
			client.focus:raise()
		end
	end
end,
{description = "go back", group = "client"}),

-- Show/Hide Wibox
awful.key({ modkey }, "b", function ()
	for s in screen do
		s.mywibox.visible = not s.mywibox.visible
		if s.mybottomwibox then
			s.mybottomwibox.visible = not s.mybottomwibox.visible
		end
	end
end,
{description = "toggle wibox", group = "awesome"}),

-- On the fly useless gaps change
awful.key({ altkey, "Control" }, "+", function () lain.util.useless_gaps_resize(1) end,
{description = "increment useless gaps", group = "tag"}),
awful.key({ altkey, "Control" }, "-", function () lain.util.useless_gaps_resize(-1) end,
{description = "decrement useless gaps", group = "tag"}),
awful.key({ altkey, "Control" }, "g", function ()
	local gap = beautiful.useless_gap
	local no_gaps = beautiful.no_gaps or false

	if no_gaps then
		lain.util.useless_gaps_resize(beautiful.useless_gap)
		beautiful.no_gaps = false
	else
		lain.util.useless_gaps_resize(-beautiful.useless_gap)
		beautiful.no_gaps = true
	end
end,
{description = "toggle gaps", group = "tag"}),

-- Standard program
awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
{description = "open a terminal", group = "launcher"}),

awful.key({ modkey, "Control" }, "r", awesome.restart,
{description = "reload awesome", group = "awesome"}),

awful.key({ modkey, "Shift"   }, "q", awesome.quit,
{description = "quit awesome", group = "awesome"}),

awful.key({ altkey, "Shift"   }, "l",     function () awful.tag.incmwfact( 0.05)          end,
{description = "increase master width factor", group = "layout"}),

awful.key({ altkey, "Shift"   }, "h",     function () awful.tag.incmwfact(-0.05)          end,
{description = "decrease master width factor", group = "layout"}),

awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
{description = "increase the number of master clients", group = "layout"}),

awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
{description = "decrease the number of master clients", group = "layout"}),

awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
{description = "increase the number of columns", group = "layout"}),

awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
{description = "decrease the number of columns", group = "layout"}),

awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
{description = "select next", group = "layout"}),

awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
{description = "select previous", group = "layout"}),

-- Widgets popups
awful.key({ altkey, }, "c", function () if beautiful.cal then beautiful.cal.show(7) end end,
{description = "show calendar", group = "widgets"}),
awful.key({ altkey, }, "h", function () if beautiful.fs then beautiful.fs.show(7) end end,
{description = "show filesystem", group = "widgets"}),
awful.key({ altkey, }, "w", function () if beautiful.weather then beautiful.weather.show(7) end end,
{description = "show weather", group = "widgets"}),

-- ALSA volume control
awful.key({ }, "XF86AudioRaiseVolume",
function ()
	beautiful.volume:inc()
end,
{description = "volume up", group = "hotkeys"}),
awful.key({ }, "XF86AudioLowerVolume",
function ()
	beautiful.volume:dec()
end,
{description = "volume down", group = "hotkeys"}),
awful.key({ }, "XF86AudioMute",
function ()
	beautiful.volume:toggle()
end,
{description = "toggle mute", group = "hotkeys"}),
awful.key({ altkey, "Control" }, "m",
function ()
	beautiful.volume:max()
end,
{description = "volume 100%", group = "hotkeys"}),
awful.key({ altkey, "Control" }, "0",
function ()
	beautiful.volume:zero()
end,
{description = "volume 0%", group = "hotkeys"}),

-- Default
--[[ Menubar
awful.key({ modkey }, "p", function() menubar.show() end,
{description = "show the menubar", group = "launcher"})
--]]
--[[ dmenu
awful.key({ modkey }, "x", function ()
	os.execute(string.format("dmenu_run -i -fn 'Monospace' -nb '%s' -nf '%s' -sb '%s' -sf '%s'",
	beautiful.bg_normal, beautiful.fg_normal, beautiful.bg_focus, beautiful.fg_focus))
end,
{description = "show dmenu", group = "launcher"})
--]]
-- alternatively use rofi, a dmenu-like application with more features
-- check https://github.com/DaveDavenport/rofi for more details
--[[ rofi
awful.key({ modkey }, "x", function ()
	os.execute(string.format("rofi -show %s -theme %s",
	'run', 'dmenu'))
end,
{description = "show rofi", group = "launcher"}),
--]]
-- Prompt
awful.key({ modkey }, "r", function () awful.screen.focused().mypromptbox:run() end,
{description = "run prompt", group = "launcher"})
--]]
)

clientkeys = my_table.join(
awful.key({ altkey, "Shift"   }, "m",      lain.util.magnify_client,
{description = "magnify client", group = "client"}),
awful.key({ modkey,           }, "f",
function (c)
	c.fullscreen = not c.fullscreen
	c:raise()
end,
{description = "toggle fullscreen", group = "client"}),
awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
{description = "close", group = "client"}),
awful.key({ modkey, "Control" }, "space",  function(c)
	c.floating = not c.floating
end,
{description = "toggle floating", group = "client"}),
awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
{description = "move to master", group = "client"}),
awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
{description = "move to screen", group = "client"}),
awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
{description = "toggle keep on top", group = "client"}),
awful.key({ modkey,           }, "m",
function (c)
	c.maximized = not c.maximized
	c:raise()
end ,
{description = "maximize", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	-- Hack to only show tags 1 and 9 in the shortcut window (mod+s)
	local descr_view, descr_toggle, descr_move, descr_toggle_focus
	if i == 1 or i == 9 then
		descr_view = {description = "view tag #", group = "tag"}
		descr_toggle = {description = "toggle tag #", group = "tag"}
		descr_move = {description = "move focused client to tag #", group = "tag"}
		descr_toggle_focus = {description = "toggle focused client on tag #", group = "tag"}
	end
	globalkeys = my_table.join(globalkeys,
	-- View tag only.
	awful.key({ modkey }, "#" .. i + 9,
	function ()
		local screen = awful.screen.focused()
		local tag = screen.tags[i]
		if tag then
			tag:view_only()
		end
	end,
	descr_view),
	-- Toggle tag display.
	awful.key({ modkey, "Control" }, "#" .. i + 9,
	function ()
		local screen = awful.screen.focused()
		local tag = screen.tags[i]
		if tag then
			awful.tag.viewtoggle(tag)
		end
	end,
	descr_toggle),
	-- Move client to tag.
	awful.key({ modkey, "Shift" }, "#" .. i + 9,
	function ()
		if client.focus then
			local tag = client.focus.screen.tags[i]
			if tag then
				client.focus:move_to_tag(tag)
			end
		end
	end,
	descr_move),
	-- Toggle tag on focused client.
	awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
	function ()
		if client.focus then
			local tag = client.focus.screen.tags[i]
			if tag then
				client.focus:toggle_tag(tag)
			end
		end
	end,
	descr_toggle_focus)
	)
end

clientbuttons = gears.table.join(
awful.button({ }, 1, function (c)
	c:emit_signal("request::activate", "mouse_click", {raise = true})
end),
awful.button({ modkey }, 1, function (c)
	c:emit_signal("request::activate", "mouse_click", {raise = true})
	awful.mouse.client.move(c)
end),
awful.button({ modkey }, 3, function (c)
	c:emit_signal("request::activate", "mouse_click", {raise = true})
	awful.mouse.client.resize(c)
end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
	-- All clients will match this rule.
	{ rule = { },
	properties = { border_width = beautiful.border_width,
	border_color = beautiful.border_normal,
	focus = awful.client.focus.filter,
	raise = true,
	keys = clientkeys,
	buttons = clientbuttons,
	screen = awful.screen.preferred,
	placement = awful.placement.no_overlap+awful.placement.no_offscreen,
	size_hints_honor = false,
	titlebars_enabled = false
}
    },

    -- Titlebars
    { rule_any = { type = { "dialog", "normal" } },
    properties = { titlebars_enabled = false } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	if not awesome.startup then awful.client.setslave(c) end

	if awesome.startup and
		not c.size_hints.user_position
		and not c.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end
end)

-- Show only titlebars if floating
client.connect_signal("property::floating", function(c)
    if c.floating then
        awful.titlebar.show(c)
    else
        awful.titlebar.hide(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
	-- Custom
	if beautiful.titlebar_fun then
		beautiful.titlebar_fun(c)
		return
	end

	-- Default
	-- buttons for the titlebar
	local buttons = my_table.join(
		awful.button({ }, 1, function()
			c:emit_signal("request::activate", "titlebar", {raise = true})
			awful.mouse.client.move(c)
		end),
		awful.button({ }, 2, function() c:kill() end),
		awful.button({ }, 3, function()
			c:emit_signal("request::activate", "titlebar", {raise = true})
			awful.mouse.client.resize(c)
		end)
	)

	awful.titlebar(c, {size = dpi(16)}) : setup {
		{ -- Left
			--awful.titlebar.widget.iconwidget(c),
			buttons = buttons,
			layout  = wibox.layout.fixed.horizontal
		},
		{ -- Middle
			{ -- Title
				align  = "center",
				widget = awful.titlebar.widget.titlewidget(c)
			},
			buttons = buttons,
			layout  = wibox.layout.flex.horizontal
		},
		layout = wibox.layout.align.horizontal
	}
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
