local function getFilesToLoad(path)
    if path:sub(path:len(),path:len()) ~= "/" then
        path = path.."/"
    end
    local out = {}
    if files.isDir(path) then
        local children = files.getChildren(path)
        for _,child in ipairs(children) do
            local newpath = path..child
            if files.isDir(child) then
                for _,i in ipairs(getFilesToLoad(newpath.."/")) do
                    out[#out+1] = i
                end
            else
                out[#out+1] = newpath
            end
        end
    else
        return {path}
    end
    return out
end

local function loadFile(path)
    if not files.exists(path) then
        error("file not found",2)
    end
    local handle = files.open(path,"r")
    local code = handle.read("a")
    handle.close()
    return load(code,path)
end

for _,i in ipairs(getFilesToLoad("system:/modules")) do
    write("loading module: ",i.."... ")
    local success, moduleName, module = pcall(loadFile(i))
    if success then
        print("ok")
    else
        printerror("failed!")
        printerror(moduleName)
    end
end
for _,i in ipairs(getFilesToLoad("system:/services")) do
    write("starting service: ",i.."... ")
    local func, error = loadFile(i)
    if not func then
        printerror("failed!")
        printerror(error)
    else
        threading.addThread(func)
        print("ok")
    end
end
while true do
    threading.step()
end