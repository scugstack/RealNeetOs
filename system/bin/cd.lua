local path = ...
if not path then
    print("usage: cd <path>")
end
local newpath = fs.resolve(path)
if not newpath then print("directory not found") return end
if not fs.isDir(newpath) then print("destination is not a directory")  return end
env.set("CURRENT_WORKING_DIRECTORY",newpath.."/")