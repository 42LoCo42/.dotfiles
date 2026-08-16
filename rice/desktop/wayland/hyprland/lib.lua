---@diagnostic disable: lowercase-global

fmt = string.format

function state(name)
	file = fmt("%s/.cache/hyprstate-%s", os.getenv("HOME"), name)

	get = function()
		h = io.open(file, "r")
		if h == nil then
			return false
		else
			io.close(h)
			return true
		end
	end

	set = function(val)
		if val then
			io.close(io.open(file, "w"))
		else
			os.remove(file)
		end

		return val
	end

	return {
		get = get,
		set = set,

		tgl = function()
			return set(not get())
		end,
	}
end

function dropdown(cmd)
	return function()
		ws = hl.get_active_workspace()
		class = fmt("dropdown_%s", string.match(cmd, "%S+"))
		window = hl.get_windows({ class = class })[1]

		if window == nil then
			hl.dispatch(hl.dsp.exec_cmd(
				fmt("foot -a %s %s", class, cmd), --
				{ float = true, dim_around = true }
			))
		elseif window.workspace == ws then
			hl.dispatch(hl.dsp.window.move({
				window = window,
				workspace = "special:dropdown",
				follow = false,
			}))
		else
			hl.dispatch(hl.dsp.window.move({
				window = window,
				workspace = ws,
			}))
		end
	end
end

function terminal()
	ws = "1"
	class = "foot-main-terminal"
	should_move = true

	if hl.get_active_workspace().name ~= ws then
		hl.dispatch(hl.dsp.focus({ workspace = ws }))
		should_move = false
	end

	present = #hl.get_windows({
		workspace = ws,
		class = class,
	}) > 0

	if not present then
		hl.dispatch(hl.dsp.exec_cmd(fmt("foot -a %s tmux new-session -A -s 0", class)))
	elseif should_move then
		hl.dispatch(hl.dsp.focus({ workspace = "previous" }))
	end
end

for _, dir in pairs({ "left", "right", "up", "down" }) do
	hl.bind(fmt("SUPER + %s", dir), hl.dsp.focus({ direction = dir }))
	hl.bind(fmt("SUPER + SHIFT + %s", dir), hl.dsp.window.swap({ direction = dir }))
end

for i = 1, 10 do
	key = i - 1

	hl.bind(fmt("SUPER + %s", key), function()
		hl.dispatch(hl.dsp.focus({ workspace = i }))
	end)

	hl.bind(fmt("SUPER + SHIFT + %s", key), function()
		hl.dispatch(hl.dsp.window.move({ workspace = i }))
	end)
end
