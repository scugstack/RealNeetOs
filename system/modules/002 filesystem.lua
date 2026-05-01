_G.fs = require("fs")
_G.fs.list = _G.fs.getChildren
local utils = loadLibrary("stringUtils")

function _G.fs.combine(...)
    local v = table.concat({...},"/"):gsub("%/%/","/")
    return v
end

function _G.fs.getName(path)
    if type(path) ~= "string" then error("expected type string for path instead got: "..type(path),2) end
    local components = utils.split(path,"/")
    return components[#components]
end

function _G.fs.getDir(path)
    if type(path) ~= "string" then error("expected type string for path instead got: "..type(path),2) end
    local components = utils.split(path,"/")
    components[#components] = nil
    return table.concat(components,"/")
end

function _G.fs.copy(source,dest)
    if type(source) ~= "string" then error("expected type string for source instead got: "..type(source),2) end
    if type(dest) ~= "string" then error("expected type string for dest instead got: "..type(dest),2) end
    if fs.exists(dest) then fs.delete(dest) end

    local source_handle = fs.open(source,"r")
    local source_data = source_handle.read("a")
    source_handle.close()

    local dest_handle = fs.open(dest,"a+")
    dest_handle.write(source_data)
    dest_handle.close()
end

function _G.fs.move(source,dest)
    if type(source) ~= "string" then error("expected type string for source instead got: "..type(source),2) end
    if type(dest) ~= "string" then error("expected type string for dest instead got: "..type(dest),2) end
    fs.copy(source,dest)
    fs.delete(source)
end

function _G.loadfile(path)
    if not fs.exists(path) then
        error("file not found",2)
    end
    local handle = fs.open(path,"r")
    local code = handle.read("a")
    handle.close()
    return load(code,path)
end

local function reOrder(t)
    local out = {}
    for _,v in pairs(t) do
        out[#out+1] = v
    end
    return out
end

function _G.fs.resolve(path)
    local cwd = env.get("CURRENT_WORKING_DIRECTORY")
    local components = utils.split(path,"/")
    local components_cwd = utils.split(fs.combine(cwd,path),"/")
    local index = 1
    while true do
        if components[index+1] == ".." then
            components[index] = nil
            components[index+1] = nil
            components = reOrder(components)
        else
            index = index + 1
        end
        if components[index] == nil then
            break
        end
    end
    index = 1
    while true do
        if components_cwd[index+1] == ".." then
            components_cwd[index] = nil
            components_cwd[index+1] = nil
            components_cwd = reOrder(components_cwd)
        else
            index = index + 1
        end
        if components_cwd[index] == nil then
            break
        end
    end
    local combined_path = table.concat(components,"/")
    local combined_path_cwd = table.concat(components_cwd,"/")
    if fs.exists(combined_path_cwd) then
        return combined_path_cwd
    elseif fs.exists(combined_path) then
        return combined_path
    end
end