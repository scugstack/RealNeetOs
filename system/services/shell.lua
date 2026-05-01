local term = graphics.term
term.clear()
term.setCursorPos(1,1)
local shellpath = env.get("SHELL")
if shellpath and fs.exists(shellpath) then
    loadfile(shellpath)()
else
    printerror("failed to find the shell program")
end