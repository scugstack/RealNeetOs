local path = ...
local target = fs.resolve(path or "/")
if not target then print("directory not found") return end
if not fs.isDir(target) then print("target is not a directory:",target)  return end
print(table.unpack(fs.list(target.."/")))