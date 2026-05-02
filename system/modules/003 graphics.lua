local defaultFont = loadLibrary("terminalFont")
local screen = _G.screen
_G.screen = nil
local mode = 0


_G.graphics = {term={},bitmap=setmetatable({},{__index = function (_,index) return function (...) if mode == 1 then return screen[index](...) end end end})}

--from https://stackoverflow.com/questions/1426954/split-string-in-lua by Mateen Ulhaq?
local function split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

_G.graphics.modes = {TEXT=0,BITMAP=1}

function _G.graphics.setMode(newmode)
    if newmode == 0 then
        screen.fill(0,0,0)
        screen.draw()
        mode = newmode
        graphics.term.draw()
    elseif newmode == 1 then
        screen.fill(0,0,0)
        screen.draw()
        mode = newmode
    end
end

function _G.graphics.newTerminalWithFont(font)
    local sizeX,sizeY = screen.getSize()
    local termSizeX, termSizeY = math.floor((sizeX-1)/font.sizeX)*font.sizeX, math.floor((sizeY-1)/font.sizeY)*font.sizeY
    local termCharSizeX, termCharSizeY = math.floor((sizeX-1)/font.sizeX), math.floor((sizeY-1)/font.sizeY)
    local topX, topY = (sizeX/2)-(termSizeX/2), (sizeY/2)-(termSizeY/2)
    local function drawChar(x,y,c,fr,fg,fb,br,bg,bb)
	    screen.fill(topX+((x-1)*font.sizeX),topY+((y-1)*font.sizeY),topX+((x-1)*font.sizeX)+font.sizeX,topY+((y-1)*font.sizeY)+font.sizeY,br,bg,bb)
	    font.drawChar(screen,topX+((x-1)*font.sizeX)+1,topY+((y-1)*font.sizeY)+1,c,fr,fg,fb)
    end
    local cursorX = 1
    local cursorY = 1
    local fgColor = {255,255,255}
    local bgColor = {0,0,0}
    local term = {}
    local grid = {}
    function term.setCharAt(x,y,char,_update_override)
        if type(x) ~= "number" then error("expected x to be a number got: "..type(x),2) end
        if type(y) ~= "number" then error("expected y to be a number got: "..type(y),2) end
        if type(char) ~= "string" then error("expected char to be a string got: "..type(char),2) end
        char = char:gsub("\n"," "):gsub("\t"," "):gsub("\r", " ")
        if termCharSizeX < x  or termCharSizeY < y or x <= 0 or y <= 0 then return end
        if not grid[y] then grid[y] = {} end
        if not grid[y][x] then grid[y][x] = {char=" ",bg = bgColor,fg = fgColor} end
        grid[y][x].char = char
        if term.autoDraw ~= false and mode == 0 then
            local tile = grid[y][x]
            drawChar(x,y,tile.char,tile.fg[1],tile.fg[2],tile.fg[3],tile.bg[1],tile.bg[2],tile.bg[3])
            if not _update_override then
                screen.draw()
            end
        end
    end
    function term.setFgAt(x,y,fg,_update_override)
        if type(x) ~= "number" then error("expected x to be a number got: "..type(x),2) end
        if type(y) ~= "number" then error("expected y to be a number got: "..type(y),2) end
        if type(fg) ~= "table" then error("expected fg to be a table got: "..type(fg),2) end
        if #fg ~= 3 then error("expected fg to be a table of length 3 but the table was of length "..tostring(#fg),2) end
        if termCharSizeX < x  or termCharSizeY < y or x <= 0 or y <= 0 then return end
        if not grid[y] then grid[y] = {} end
        if not grid[y][x] then grid[y][x] = {char=" ",bg = bgColor,fg = fgColor} end
        grid[y][x].fg = fg
        if term.autoDraw ~= false and mode == 0 then
            local tile = grid[y][x]
            drawChar(x,y,tile.char,tile.fg[1],tile.fg[2],tile.fg[3],tile.bg[1],tile.bg[2],tile.bg[3])
            if not _update_override then
                screen.draw()
            end
        end
    end
    function term.setBgAt(x,y,bg,_update_override)
        if type(x) ~= "number" then error("expected x to be a number got: "..type(x),2) end
        if type(y) ~= "number" then error("expected y to be a number got: "..type(y),2) end
        if type(bg) ~= "table" then error("expected bg to be a table got: "..type(bg),2) end
        if #bg ~= 3 then error("expected bg to be a table of length 3 but the table was of length "..tostring(#bg),2) end
        if termCharSizeX < x  or termCharSizeY < y or x <= 0 or y <= 0 then return end
        if not grid[y] then grid[y] = {} end
        if not grid[y][x] then grid[y][x] = {char=" ",bg = bgColor,fg = fgColor} end
        grid[y][x].bg = bg
        if term.autoDraw ~= false and mode == 0 then
            local tile = grid[y][x]
            drawChar(x,y,tile.char,tile.fg[1],tile.fg[2],tile.fg[3],tile.bg[1],tile.bg[2],tile.bg[3])
            if not _update_override then
                screen.draw()
            end
        end
    end
    function term.setTileAt(x,y,char,fg,bg,_update_override)
        if type(x) ~= "number" then error("expected x to be a number got: "..type(x),2) end
        if type(y) ~= "number" then error("expected y to be a number got: "..type(y),2) end
        if type(char) ~= "string" then error("expected char to be a string got: "..type(char),2) end
        if type(fg) ~= "table" then error("expected fg to be a table got: "..type(fg),2) end
        if #fg ~= 3 then error("expected fg to be a table of length 3 but the table was of length "..tostring(#fg),2) end
        if type(bg) ~= "table" then error("expected bg to be a table got: "..type(bg),2) end
        if #bg ~= 3 then error("expected bg to be a table of length 3 but the table was of length "..tostring(#bg),2) end
        char = char:gsub("\n"," "):gsub("\t"," "):gsub("\r", " ")
        if termCharSizeX < x  or termCharSizeY < y or x <= 0 or y <= 0 then return end
        if not grid[y] then grid[y] = {} end
        grid[y][x] = {char=char,bg = bg,fg = fg}
        if term.autoDraw ~= false and mode == 0 then
            local tile = grid[y][x]
            drawChar(x,y,tile.char,tile.fg[1],tile.fg[2],tile.fg[3],tile.bg[1],tile.bg[2],tile.bg[3])
            if not _update_override then
                screen.draw()
            end
        end
    end
    function term.getCharAt(x,y)
        if type(x) ~= "number" then error("expected x to be a number got: "..type(x),2) end
        if type(y) ~= "number" then error("expected y to be a number got: "..type(y),2) end
         if termCharSizeX < x  or termCharSizeY < y or x <= 0 or y <= 0 or not grid[y] or not grid[y][x] then return " " end
        return grid[y][x].char
    end
    function term.getFgAt(x,y)
        if type(x) ~= "number" then error("expected x to be a number got: "..type(x),2) end
        if type(y) ~= "number" then error("expected y to be a number got: "..type(y),2) end
         if termCharSizeX < x  or termCharSizeY < y or x <= 0 or y <= 0 or not grid[y] or not grid[y][x] then return fgColor end
        return grid[y][x].fg
    end
    function term.getBgAt(x,y)
        if type(x) ~= "number" then error("expected x to be a number got: "..type(x),2) end
        if type(y) ~= "number" then error("expected y to be a number got: "..type(y),2) end
        if termCharSizeX < x  or termCharSizeY < y or x <= 0 or y <= 0 or not grid[y] or not grid[y][x] then return bgColor end
        return grid[y][x].bg
    end
    function term.getTileAt(x,y)
        if type(x) ~= "number" then error("expected x to be a number got: "..type(x),2) end
        if type(y) ~= "number" then error("expected y to be a number got: "..type(y),2) end
        if termCharSizeX < x  or termCharSizeY < y or x <= 0 or y <= 0 or not grid[y] or not grid[y][x] then return " ",fgColor,bgColor end
        return grid[y][x].char, grid[y][x].fg, grid[y][x].bg
    end

    function term.setFgColor(r,g,b)
        if type(r) ~= "number" then error("expected r to be a number got: "..type(r),2) end
        if type(g) ~= "number" then error("expected g to be a number got: "..type(g),2) end
        if type(b) ~= "number" then error("expected b to be a number got: "..type(b),2) end
        fgColor = {r,g,b}
    end

    function term.setBgColor(r,g,b)
        if type(r) ~= "number" then error("expected r to be a number got: "..type(r),2) end
        if type(g) ~= "number" then error("expected g to be a number got: "..type(g),2) end
        if type(b) ~= "number" then error("expected b to be a number got: "..type(b),2) end
        bgColor = {r,g,b}
    end

    function term.getFgColor()
        return table.unpack(fgColor)
    end

    function term.getBgColor()
        return table.unpack(bgColor)
    end

    function term.write(str)
        if type(str) ~= "string" then error("expected str to be a string got: "..type(str),2) end
        for indx = 1,str:len() do
            local char = str:sub(indx,indx)
            if char == "\t" then
                term.setTileAt(cursorX,cursorY," ",fgColor,bgColor, true)
                term.setTileAt(cursorX+1,cursorY," ",fgColor,bgColor, true)
                term.setTileAt(cursorX+2,cursorY," ",fgColor,bgColor, true)
                cursorX = cursorX+3
            elseif char ~= "\n" or char ~= "\r" then
                term.setTileAt(cursorX,cursorY,char,fgColor,bgColor, true)
                cursorX = cursorX+1
            end
        end
        if term.autoDraw and mode == 0 then
            screen.draw()
        end
    end

    function term.draw()
        if mode ~= 0 then return end
        for y = 1,termCharSizeY do
            for x = 1,termCharSizeX do
                local char,fg,bg = term.getTileAt(x,y)
                drawChar(x,y,char,fg[1],fg[2],fg[3],bg[1],bg[2],bg[3])
            end
        end
        screen.draw()
    end
    function term.scroll(amount)
        if type(amount) ~= "number" then error("expected amount to be a number got: "..type(amount),2) end
        local function newLine()
            local line = {}
            for x = 1,termCharSizeX do
                line[#line+1] = {char=" ",bg = bgColor,fg = fgColor}
            end
        end
        if amount > 0 then
            for y = 1,termCharSizeY do
                grid[y] = grid[y+amount] or newLine()
            end
        elseif amount < 0 then
            for y = termCharSizeY,1,-1 do
                grid[y] = grid[y+amount] or newLine()
            end
        end
        if term.autoDraw ~= false and amount ~= 0 and mode == 0 then
            term.draw()
        end
    end

    function term.setCursorPos(x,y)
        if type(x) ~= "number" then error("expected x to be a number got: "..type(x),2) end
        if type(y) ~= "number" then error("expected y to be a number got: "..type(y),2) end
        cursorX = math.max(math.min(x,termCharSizeX),1)
        cursorY = math.max(math.min(y,termCharSizeY),1)
    end

    function term.getCursorPos()
        return cursorX,cursorY
    end

    function term.clear()
        for y = 1,termCharSizeY do
            for x = 1,termCharSizeX do
                term.setCharAt(x,y," ",true)
            end
        end
        if term.autoDraw ~= false and mode == 0 then
            screen.draw()
        end
    end

    function term.size()
        return termCharSizeX,termCharSizeY
    end
    term.autoDraw = false
    term.clear()
    term.autoDraw = true
    return term
end

graphics.term = graphics.newTerminalWithFont(defaultFont)

function _G.write(...)
    local sx,sy = graphics.term.size()
    local args = {...}
    for k,v in ipairs(args) do args[k] = tostring(v) end
    local str = table.concat(args," ")
    local lines = split(str,"\n")
    local trailing_newline = str:sub(str:len()) == "\n"
    for indx,line in ipairs(lines) do
        while line ~= "" do
            local cx,cy = graphics.term.getCursorPos()
            local toprint = line:sub(1,sx-cx+1)
            graphics.term.write(toprint)
            line = line:sub(sx-cx+2)
            if line == "" then break end
            if cy+1 > sy then
                graphics.term.scroll(1)
                graphics.term.setCursorPos(1,cy)
            else
                graphics.term.setCursorPos(1,cy+1)
            end
        end
        local _,cy = graphics.term.getCursorPos()
        if indx ~= #lines or trailing_newline then
            if cy+1 > sy then
                graphics.term.scroll(1)
                graphics.term.setCursorPos(1,cy)
            else
                graphics.term.setCursorPos(1,cy)
                graphics.term.setCursorPos(1,cy+1)
            end
        end
    end
end

function _G.print(...)
    local args = {...}
    args[#args+1] = "\n"
    write(table.unpack(args))
end

function _G.printerror(...)
    local color = {graphics.term.getFgColor()}
    graphics.term.setFgColor(255,0,0)
    print(...)
    graphics.term.setFgColor(table.unpack(color))
end