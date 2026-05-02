local utils = {}

--All of this is not mine because I suck at string manipulation.

-- Source - https://stackoverflow.com/a/43582076
-- Posted by Jack Taylor, modified by community. See post 'Timeline' for change history
-- Retrieved 2026-05-01, License - CC BY-SA 3.0

-- gsplit: iterate over substrings in a string separated by a pattern
-- 
-- Parameters:
-- text (string)    - the string to iterate over
-- pattern (string) - the separator pattern
-- plain (boolean)  - if true (or truthy), pattern is interpreted as a plain
--                    string, not a Lua pattern
-- 
-- Returns: iterator
--
-- Usage:
-- for substr in gsplit(text, pattern, plain) do
--   doSomething(substr)
-- end
function utils.gsplit(text, pattern, plain)
  local splitStart, length = 1, #text
  return function ()
    if splitStart then
      local sepStart, sepEnd = string.find(text, pattern, splitStart, plain)
      local ret
      if not sepStart then
        ret = string.sub(text, splitStart)
        splitStart = nil
      elseif sepEnd < sepStart then
        -- Empty separator!
        ret = string.sub(text, splitStart, sepStart)
        if sepStart < length then
          splitStart = sepStart + 1
        else
          splitStart = nil
        end
      else
        ret = sepStart > splitStart and string.sub(text, splitStart, sepStart - 1) or ''
        splitStart = sepEnd + 1
      end
      return ret
    end
  end
end

-- split: split a string into substrings separated by a pattern.
-- 
-- Parameters:
-- text (string)    - the string to iterate over
-- pattern (string) - the separator pattern
-- plain (boolean)  - if true (or truthy), pattern is interpreted as a plain
--                    string, not a Lua pattern
-- 
-- Returns: table (a sequence table containing the substrings)
function utils.split(text, pattern, plain)
  local ret = {}
  for match in utils.gsplit(text, pattern, plain) do
    table.insert(ret, match)
  end
  return ret
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