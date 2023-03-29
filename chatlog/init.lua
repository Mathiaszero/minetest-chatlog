-- License: MIT

chatlog = {}
chatlog.modname = core.get_current_modname()

function chatlog.log(lvl, msg)
	if not msg then
		msg = lvl
		lvl = nil
	end

	msg = "[" .. chatlog.modname .. "] " .. msg
	if not lvl then
		core.log(msg)
	else
		core.log(lvl, msg)
	end
end


chatlog.format = core.settings:get("chatlog.format") or "%m/%d/%Y %H:%M:%S"
chatlog.single_file = core.settings:get_bool("chatlog.single_file", true)

chatlog.out = minetest.get_worldpath() .. "/chatlog"
if chatlog.single_file then
	chatlog.out = chatlog.out .. ".txt"
end


local function write_log(name, msg)
	local out_file = chatlog.out
	if not chatlog.single_file then
		-- make sure directory exists
		if not core.mkdir(chatlog.out) then
			chatlog.log("error", "could not create directory for writing: " .. chatlog.out)
			return
		end

		out_file = chatlog.out .. "/" .. os.date("%Y_%m_%d") .. ".txt"
	end

	local f = io.open(out_file, "a")
	local type = type(name)
	local ip = msg:match("(%d+%.%d+%.%d+%.%d+)")

	if f then
		if type=="string" and ip~=nil then
			--is a chat message
			f:write("(" .. os.date(chatlog.format) .. ") [" .. "Server" .. "]: " .. name .. " joined the game with ip " .. msg .. "\n")
		elseif type=="string" and ip==nil then
			f:write("(" .. os.date(chatlog.format) .. ") [" .. name .. "]: " .. msg .. "\n")
		--elseif type~="string" then
		else
			f:write("(" .. os.date(chatlog.format) .. ") [" .. "Server" .. "]: " .. name:get_player_name() .. " left the game" .. "\n")
		end

		f:close()
	else
		chatlog.log("error", "could not open chatlog file for writing: " .. out_file)
	end
end

if not core.settings:get_bool("chatlog.disable", false) then
	core.register_on_chat_message(write_log)
	core.register_on_prejoinplayer(write_log)
	core.register_on_leaveplayer(write_log)
end
