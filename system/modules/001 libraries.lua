local fs = require("fs")

local function loadFile(path)
    if not fs.exists(path) then
        error("file not found",2)
    end
    local handle = fs.open(path,"r")
    local code = handle.read("a")
    handle.close()
    return load(code,path)
end

function _G.loadLibrary(libName)
    if fs.exists("system:/libraries/"..libName) then
        return loadFile("system:/libraries/"..libName)()
    elseif fs.exists("system:/libraries/"..libName..".lua") then
        return loadFile("system:/libraries/"..libName..".lua")()
    elseif fs.exists("system:/libraries/"..libName.."/init.lua") then
        return loadFile("system:/libraries/"..libName.."/init.lua")()
    end
end