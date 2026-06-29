local success = true
local drawChar1
local didWork
local screen = _G.screen
if files.exists("bios:/font.lua") then
	local fontFile = files.open("bios:/font.lua","r")
	local fontDat = fontFile.read("a")
	fontFile.close()
	local fontProg = load(fontDat,"font")
	if fontProg then
		didWork, drawChar1 = pcall(fontProg)
		if not didWork then
			success = false
		end
	else
		success = false
	end
else 
	success = false
end

--stop boot process if it doesnt load the font
if not success then
	chip.crash("font failed to load")
end

local sizeX,sizeY = screen.getSize()
local termSizeX, termSizeY = math.floor((sizeX-1)/5)*5, math.floor((sizeY-1)/6)*6
local topX, topY = (sizeX/2)-(termSizeX/2), (sizeY/2)-(termSizeY/2)
local function drawChar(x,y,c,r,g,b)
	screen.fill(topX+((x-1)*5),topY+((y-1)*6),topX+((x-1)*5)+5,topY+((y-1)*6)+6,0,0,0)
	drawChar1(topX+((x-1)*5)+1,topY+((y-1)*6)+1,c,r,g,b)
end

local cx = 1
local cy = 1

function _G.write(...)
    local args = {...}
	local color = nil
	if type(args[#args]) == "table" and args[#args].r and args[#args].g and args[#args].b then
		color = args[#args]
		args[#args] = nil
	end 
    local str = ""
    for _,i in ipairs(args) do
		str = str.." "..tostring(i)
	end
	for indx = 1,str:len() do
		local char = str:sub(indx,indx)
		if char == "\n" then
			cx = 1
			cy = cy + 1
			if cy > termSizeY/6 then
				cy = cy-1
				local copy_layer = screen.copy(topX,topY+6,termSizeX-6,sizeY)
				screen.fill(0,0,0)
				screen.drawLayer(topX,topY,copy_layer)
			end
		elseif char == "\t" then
			cx = cx + 3
			if cx > termSizeX/5 then
				cx = 1
				cy = cy + 1
				if cy > termSizeY/6 then
					cy = cy-1
					local copy_layer = screen.copy(topX,topY+6,termSizeX-6,sizeY)
					screen.fill(0,0,0)
					screen.drawLayer(topX,topY,copy_layer)
				end
			end
		else
			if cx and cy and char then
				if not color then
				drawChar(cx,cy,char,255,255,255)
				else
					drawChar(cx,cy,char,color.r,color.g,color.b)
				end
			end
			cx = cx + 1
			if cx > termSizeX/5 then
				cx = 1
				cy = cy + 1
				if cy > termSizeY/6 then
					cy = cy-1
					local copy_layer = screen.copy(topX,topY+6,termSizeX-6,sizeY)
					screen.fill(0,0,0)
					screen.drawLayer(topX,topY,copy_layer)
				end
			end
		end
	end
	screen.draw()
end
_G.debugPrint = _G.print
function _G.print(...)
    local args = {...}
    args[#args+1] = "\n"
	write(table.unpack(args))
end

function _G.printerror(...)
    local args = {...}
    args[#args+1] = "\n"
	args[#args+1] = {r=255,g=0,b=0}
	write(table.unpack(args))
end

--loop to keep the thread alive to the computer doesnt shut down
local success = true
local drawChar1
local didWork
if files.exists("system:/boot.lua") then
	print("found system:/boot.lua")
	local bootFile = files.open("system:/boot.lua","r")
	local bootData = bootFile.read("a")
	bootFile.close()
	print("loading system:/boot.lua...")
	local fontProg = load(bootData,"boot")
	if fontProg then
		didWork, drawChar1 = pcall(fontProg)
		if not didWork then
			success = false
		end
	else
		success = false
	end
else 
	success = false
end
if not success then
	if drawChar1 then
		printerror("failed to load OS: \n",drawChar1)
	else
		printerror("failed to load OS system:/boot.lua not found")
	end
	while true do
		
	end
end