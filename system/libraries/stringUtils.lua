local utils = {}

--All of this is not mine because I suck at string manipulation.

--from https://stackoverflow.com/a/7615129 by Mateen Ulhaq and user973713 (whoever that is)
function utils.split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end


--derived from https://stackoverflow.com/a/28664691 by Paul Kulchenko
function utils.shellSplit(text)
  local words = {}
  local spat, epat, buf, quoted = [=[^(['"])]=], [=[(['"])$]=]
  for str in text:gmatch("%S+") do
    local squoted = str:match(spat)
    local equoted = str:match(epat)
    local escaped = str:match([=[(\*)['"]$]=])
    if squoted and not quoted and not equoted then
      buf, quoted = str, squoted
    elseif buf and equoted == quoted and #escaped % 2 == 0 then
      str, buf, quoted = buf .. ' ' .. str, nil, nil
    elseif buf then
      buf = buf .. ' ' .. str
    end
    if not buf then words[#words+1] = (str:gsub(spat,""):gsub(epat,"")) end
  end
  if buf then error("Missing matching quote for "..buf,2) end
  return words
end

return utils