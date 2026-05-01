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
        loadfile(path)(table.unpack(args))
    end
end