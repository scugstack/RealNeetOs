local helper = {}
local sUtils = loadLibrary("stringUtils")

function helper.read()
    local typed = ""
    local initial_x = graphics.term.getCursorPos()
    graphics.term.write("_")
    while true do
        local _,keycode,char = awaitEvent("keyPressed")
        if keycode == asciiCodes.Tab then
            char = "\t"
        end
        if keycode == asciiCodes.BackSpace then
            typed = typed:sub(1,typed:len()-1)
            local _,cy = graphics.term.getCursorPos()
            graphics.term.setCursorPos(initial_x,cy)
            graphics.term.write(typed.."_".." ")
        elseif keycode == asciiCodes.Enter then
            local _,cy = graphics.term.getCursorPos()
            graphics.term.setCursorPos(initial_x,cy)
            print(typed.." ")
            return typed
        else
            typed = typed..char
            local _,cy = graphics.term.getCursorPos()
            graphics.term.setCursorPos(initial_x,cy)
            graphics.term.write(typed.."_")
        end
    end
end

function helper.resolveProgram(name)
    local path = env.get("PATH")
    local locations = sUtils.split(path,"?")
    for _,location in ipairs(locations) do
        if fs.exists(fs.combine(env.substituteInString(location),name..".lua")) then
            return fs.combine(env.substituteInString(location),name..".lua")
        end
    end
end

return helper