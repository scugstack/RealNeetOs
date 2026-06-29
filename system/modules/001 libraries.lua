local function loadFile(path)
    if not files.exists(path) then
        error("file not found",2)
    end
    local handle = files.open(path,"r")
    local code = handle.read("a")
    handle.close()
    return load(code,path)
end

function _G.loadLibrary(libName)
    if files.exists("system:/libraries/"..libName) then
        return loadFile("system:/libraries/"..libName)()
    elseif files.exists("system:/libraries/"..libName..".lua") then
        return loadFile("system:/libraries/"..libName..".lua")()
    elseif files.exists("system:/libraries/"..libName.."/init.lua") then
        return loadFile("system:/libraries/"..libName.."/init.lua")()
    end
end