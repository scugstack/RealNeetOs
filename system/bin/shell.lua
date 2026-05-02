env.set("CURRENT_WORKING_DIRECTORY","user:/")
local tHelp = loadLibrary("terminalHelper")
local sUtils = loadLibrary("stringUtils")
local term = graphics.term

while true do
    term.write(tostring(env.get("CURRENT_WORKING_DIRECTORY")).."> ")
    local command = tHelp.read()
    local components = sUtils.shellSplit(command)
    local program = components[1]
    local args = {table.unpack(components,2)}
    local path = tHelp.resolveProgram(program)
    if path then
        local func,err = loadfile(path)
        if func then
            local succ,err = pcall(func,table.unpack(args))
            if not succ then
                printerror(err)
            end
            graphics.setMode(graphics.modes.TEXT)
        else
            printerror(err)
        end
    else
        print("program not found:",program)
    end
end