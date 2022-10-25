local settings = {
    shiftCameraOnNote = true,
    shiftCameraPixels = 32,
    smoothCamera = true,
    smoothZoom = true,
    smoothIntensity = .65, -- too much smooth or below 0 = camera wont move lmao
    showNoteCombo = true, -- disable this if its annoying lmao
    noteComboX = 311,
    noteComboY = 223
}

-----------------------------------------------------------------------
--
-----------------------------------------------------------------------

-- formulas from http://www.robertpenner.com/easing
easing = {
    -- linear
    linear = function(t, b, c, d)
        return c * t / d + b
    end,

    -- quad
    inQuad = function(t, b, c, d)
        return c * math.pow(t / d, 2) + b
    end,
    outQuad = function(t, b, c, d)
        t = t / d
        return -c * t * (t - 2) + b
    end,
    inOutQuad = function(t, b, c, d)
        t = t / d * 2
        if t < 1 then
            return c / 2 * math.pow(t, 2) + b
        end
        return -c / 2 * ((t - 1) * (t - 3) - 1) + b
    end,
    outInQuad = function(t, b, c, d)
        if t < d / 2 then
            return outQuad(t * 2, b, c / 2, d)
        end
        return inQuad((t * 2) - d, b + c / 2, c / 2, d)
    end,

    -- cubic
    inCubic = function(t, b, c, d)
        return c * math.pow(t / d, 3) + b
    end,
    outCubic = function(t, b, c, d)
        return c * (math.pow(t / d - 1, 3) + 1) + b
    end,
    inOutCubic = function(t, b, c, d)
        t = t / d * 2
        if t < 1 then
            return c / 2 * t * t * t + b
        end
        t = t - 2
        return c / 2 * (t * t * t + 2) + b
    end,
    outInCubic = function(t, b, c, d)
        if t < d / 2 then
            return outCubic(t * 2, b, c / 2, d)
        end
        return inCubic((t * 2) - d, b + c / 2, c / 2, d)
    end,

    -- quint
    inQuint = function(t, b, c, d)
        return c * math.pow(t / d, 5) + b
    end,
    outQuint = function(t, b, c, d)
        return c * (math.pow(t / d - 1, 5) + 1) + b
    end,
    inOutQuint = function(t, b, c, d)
        t = t / d * 2
        if t < 1 then
            return c / 2 * math.pow(t, 5) + b
        end
        return c / 2 * (math.pow(t - 2, 5) + 2) + b
    end,
    outInQuint = function(t, b, c, d)
        if t < d / 2 then
            return outQuint(t * 2, b, c / 2, d)
        end
        return inQuint((t * 2) - d, b + c / 2, c / 2, d)
    end,

    -- elastics
    outElastic = function(t, b, c, d, a, p)
        a = a or 3
        p = p or 1
        if t == 0 then
            return b
        end
        t = t / d
        if t == 1 then
            return b + c
        end
        if not p then
            p = d * 0.3
        end
        local s
        if not a or a < math.abs(c) then
            a = c
            s = p / 4
        else
            s = p / (2 * math.pi) * math.asin(c / a)
        end
        return a * math.pow(2, -10 * t) * math.sin((t * d - s) * (2 * math.pi) / p) + c + b
    end
}

--[[ TWEENNUMBER ]] --
local time = 0
local os = os
function os.clock()
    return time
end

tweenReqs = {}

function tnTick()
    local clock = os.clock()
    -- print(songPos, #tweenReqs)
    if #tweenReqs > 0 then
        for i, v in next, tweenReqs do
            if clock > v[5] + v[6] then
                v[1][v[2]] = v[7](v[6], v[3], v[4] - v[3], v[6])
                table.remove(tweenReqs, i)
                if v[9] then
                    v[9]()
                end
            else
                v[1][v[2]] = v[7](clock - v[5], v[3], v[4] - v[3], v[6])
                -- if (v[8]) then
                --	v[8] = false
                --	v[1][v[2]] = v[7](0,v[3],v[4]-v[3],v[6])
                -- end
            end
        end
    end
end

function tweenNumber(maps, varName, startVar, endVar, time, startTime, easeF, onComplete)
    local clock = os.clock()
    maps = maps or getfenv()

    if #tweenReqs > 0 then
        for i2, v2 in next, tweenReqs do
            if v2[2] == varName and v2[1] == maps then
                v2[1][v2[2]] = v2[7](v2[6], v2[3], v2[4] - v2[3], v2[6])
                table.remove(tweenReqs, i2)
                if v2[9] then
                    v2[9]()
                end
                break
            end
        end
    end

    -- print("Created TweenNumber: "..tostring(varName), startVar, endVar, time, startTime, type(onComplete) == "function")
    local t = {maps, varName, startVar, endVar, startTime or clock, time, easeF or easing.linear, true, onComplete}

    table.insert(tweenReqs, t)
    t[1][t[2]] = t[7](0, t[3], t[4] - t[3], t[6])

    return function()
        maps[varName] = t[7](v[6], t[3], t[4] - t[3], t[6])
        table.remove(tweenReqs, table.find(tweenReqs, t))
        if onComplete then
            onComplete()
        end
        return nil
    end
end

function math.clamp(x, min, max)
    return math.max(min, math.min(x, max))
end
function math.lerp(from, to, i)
    return from + (to - from) * i
end

function math.truncate(x, precision, round)
    if (precision == 0) then
        return math.floor(x)
    end

    precision = type(precision) == "number" and precision or 2

    x = x * math.pow(10, precision);
    return (round and math.floor(x + .5) or math.floor(x)) / math.pow(10, precision)
end

function math.snap(x, snap, next, round)
    snap = type(snap) == "number" and snap or 1
    next = type(ntext) == "number" and next or 0
    round = type(round) == "number" and round or .5

    return math.floor((x / snap) + round) * snap + (next * snap)
end

function toHexString(red, green, blue, prefix)
    if (prefix == nil) then
        prefix = true
    end

    return (prefix and "0x" or "") .. (string.format("%02X%02X%02X", red, green, blue))
end

function centerOrigin(obj)
    setProperty(obj .. ".origin.x", getProperty(obj .. ".frameWidth") * .5)
    setProperty(obj .. ".origin.y", getProperty(obj .. ".frameHeight") * .5)
end

function getObjectRealClip(spr)
    if (type(spr) ~= "string" or type(getProperty(spr .. ".frame.frame.x")) ~= "number") then
        return
    end

    return getProperty(spr .. ".frame.frame.x"), getProperty(spr .. ".frame.frame.y"),
        getProperty(spr .. ".frame.frame.width"), getProperty(spr .. ".frame.frame.height")
end

function getObjectClip(spr)
    if (type(spr) ~= "string" or type(getProperty(spr .. ".frame.frame.x")) ~= "number") then
        return
    end

    return getProperty(spr .. "._frame.frame.x"), getProperty(spr .. "._frame.frame.y"),
        getProperty(spr .. "._frame.frame.width"), getProperty(spr .. "._frame.frame.height")
end

function setObjectClip(spr, x, y, width, height, offsetX, offsetY, offsetWidth, offsetHeight)
    -- Check and Fix Arguments
    if (type(spr) ~= "string" or type(getProperty(spr .. ".frame.frame.x")) ~= "number") then
        return
    end
    x = (type(x) == "number" and x or getProperty(spr .. ".frame.frame.x")) +
            (type(offsetX) == "number" and offsetX or 0)
    y = (type(y) == "number" and y or getProperty(spr .. ".frame.frame.y")) +
            (type(offsetY) == "number" and offsetY or 0)
    width = type(width) == "number" and width >= 0 and width or getProperty(spr .. ".frame.frame.width") +
                (type(offsetWidth) == "number" and offsetWidth or 0)
    height = type(height) == "number" and height >= 0 and height or getProperty(spr .. ".frame.frame.height") +
                 (type(offsetHeight) == "number" and offsetHeight or 0)

    -- ClipRect
    setProperty(spr .. "._frame.frame.x", x)
    setProperty(spr .. "._frame.frame.y", y)
    setProperty(spr .. "._frame.frame.width", width)
    setProperty(spr .. "._frame.frame.height", height)

    return x, y, width, height
end

--[[
function getObjectRealFrameOffset(spr)
	if (type(spr) ~= "string" or type(getProperty(spr .. ".frame.offset.x")) ~= "number") then return end
	
	return 
		getProperty(spr .. ".frame.offset.x"),
		getProperty(spr .. ".frame.offset.y")
end

function getObjectFrameOffset(spr)
	if (type(spr) ~= "string" or type(getProperty(spr .. ".frame.offset.x")) ~= "number") then return end
	
	return 
		getProperty(spr .. "._frame.offset.x"),
		getProperty(spr .. "._frame.offset.y")
end

function setObjectFrameOffset(spr, x, y, offsetX, offsetY)
	-- Check and Fix Arguments
	if (type(spr) ~= "string" or type(getProperty(spr .. ".frame.offset.x")) ~= "number") then return end
	x = (type(x) == "number" and x or getProperty(spr .. ".frame.offset.x")) + (type(offsetX) == "number" and offsetX or 0)
	y = (type(y) == "number" and y or getProperty(spr .. ".frame.offset.y")) + (type(offsetY) == "number" and offsetY or 0)
	
	-- Frame Offset
	setProperty(spr .. "._frame.offset.x", x)
	setProperty(spr .. "._frame.offset.y", y)
	
	return x, y
end
]]

local function getCamString(cam)
    return type(cam) ~= "string" and "default" or
               (cam:lower():find("hud") and "camHUD" or cam:lower():find("other") and "camOther" or "default")
end

local function getCamProperty(cam, p)
    if (p == nil) then
        p = cam;
        cam = nil
    end
    local str = getCamString(cam)

    if (str == "default") then
        return p == "scroll.x" and getProperty("camFollowPos.x") or p == "scroll.y" and getProperty("camFollowPos.y") or
                   getPropertyFromClass("flixel.FlxG", "camera." .. p)
    end

    return getProperty(str .. "." .. p)
end

local function setCamProperty(cam, p, v)
    if (v == nil) then
        v = p;
        p = cam;
        cam = nil
    end
    local str = getCamString(cam)

    if (str == "default") then
        return p == "scroll.x" and setProperty("camFollowPos.x", v) or p == "scroll.y" and
                   setProperty("camFollowPos.y", v) or setPropertyFromClass("flixel.FlxG", "camera." .. p, v)
    end

    return getProperty(str .. "." .. p, v)
end

local realCamScX = 0
local realCamScY = 0
local realCamAngle = 0
local realCamZoom = 1

local camScX = 0
local camScY = 0
local camAngle = 0
local camZoom = 1

-- local prevComboOffset

--[[
function onDestroy()
	setPropertyFromClass("ClientPrefs", "comboOffset", prevComboOffset)
end
--]]

function getCurrentTime() -- returns the song pos in seconds, rounded
    return math.floor((getSongPosition() / 1000) + 0.1)
end

function getSongLength() -- returns the song length in seconds, rounded
    return math.floor((songLength / 1000) + 0.1)
end

-- setPropertyFromClass("ClientPrefs", "comboOffset", {605, -307, 717, -248})

local bfShift = {
    x = 0,
    y = 0
}
local dadShift = {
    x = 0,
    y = 0
}

function shiftCamNote(t, dir)
    if (settings.shiftCameraOnNote) then
        local x = dir == 0 and -1 or (dir == 3 and 1) or 0
        local y = dir == 1 and 1 or (dir == 2 and -1) or 0
        tweenNumber(t, "x", x, 0, (stepCrochet / 1000) * 3.14, nil, easing.outCubic)
        tweenNumber(t, "y", y, 0, (stepCrochet / 1000) * 3.14, nil, easing.outCubic)
    end
end

function opponentNoteHit(id, dir)
    shiftCamNote(dadShift, dir)
end

function goodNoteHit(id, dir, typ, sus)
    shiftCamNote(bfShift, dir)
end

function noteMiss(id, dir)
    shiftCamNote(bfShift, dir)
end

function noteMissPress(key)
    shiftCamNote(bfShift, key)
end

local isDead = false
function onGameOverStart()
    isDead = true
end

local gDt = 0
function onStepHit()
    if (isDead or getProperty("isDead")) then
        return
    end

    if (math.fmod(curStep, 16) == 0 and getProperty("camZooming") and getCamProperty("zoom") < 1.35 and
        getPropertyFromClass("ClientPrefs", "camZooms")) then
        camZoom = camZoom + .015
    end

    local thing = curBpm <= 140 and math.snap(((-curBpm + 140) / 2.5), 8) + 8 or 8

end

function onTimerCompleted(t)
    if (t == "ntCombo") then
        dontPlayCombo = false
        removeLuaSprite("ntCombo", false)
    elseif (t == "timeSecondLoop") then

        local songSeconds = getCurrentTime()

        local curMinutes = tostring(math.floor(songSeconds / 60))
        local curSeconds = tostring(songSeconds - curMinutes * 60)

        if string.len(curSeconds) == 1 then
            curSeconds = "0" .. curSeconds
        end

        setTextString("currentTime", curMinutes .. ":" .. curSeconds)

    end
end

local prevFollowXAdd = 0
local prevFollowYAdd = 0
function onUpdate(dt)
    gDt = dt
    time = time + dt

    if (settings.smoothCamera) then
        setCamProperty("scroll.x", getCamProperty("scroll.x") - (camScX - realCamScX))
        setCamProperty("scroll.y", getCamProperty("scroll.y") - (camScY - realCamScY))
        setCamProperty("angle", getCamProperty("angle") - (camAngle - realCamAngle))
        setCamProperty("zoom", getCamProperty("zoom") - (camZoom - realCamZoom))
    end

    if (isDead or getProperty("isDead")) then
        return
    end

    local pix = settings.shiftCameraPixels
    local pix2 = settings.shiftCameraPixels * .3

    local followXAdd = (bfShift.x * (mustHitSection and pix or pix2)) + (dadShift.x * (mustHitSection and pix2 or pix))
    local followYAdd = (bfShift.y * (mustHitSection and pix or pix2)) + (dadShift.y * (mustHitSection and pix2 or pix))

    setProperty("camFollow.x", getProperty("camFollow.x") - prevFollowXAdd)
    setProperty("camFollow.y", getProperty("camFollow.y") - prevFollowYAdd)
    if (settings.shiftCameraOnNote) then
        setProperty("camFollow.x", getProperty("camFollow.x") + followXAdd)
        setProperty("camFollow.y", getProperty("camFollow.y") + followYAdd)
        prevFollowXAdd = followXAdd
        prevFollowYAdd = followYAdd
    else
        prevFollowXAdd = 0
        prevFollowYAdd = 0
    end
end

function onMoveCamera()
    prevFollowXAdd = 0
    prevFollowYAdd = 0
end

local prevScoreTxt = "Score: "
local prevMissesTxt = "Misses: "
local prevRatingTxt = "Rating: "
local prevHealthTxt = "50%"

-- local camStrength = 0
function onUpdatePost(dt)
    local isDead = isDead or getProperty("isDead")

    realCamScX = getCamProperty("scroll.x")
    realCamScY = getCamProperty("scroll.y")
    realCamAngle = getCamProperty("angle")
    realCamZoom = getCamProperty("zoom")

    local camSpeed = isDead and 1 or getProperty("cameraSpeed")

    if (settings.smoothCamera) then
        --[[local x = camScX - realCamScX
		local y = camScY - realCamScY
		local distance = math.sqrt((x * x) + (y * y))
		print(distance)
		
		camStrength = math.clamp(math.lerp(camStrength, 0, 0), 0, 2.4)]]

        local smooth = ((1 / settings.smoothIntensity) + 1)

        local l = math.clamp(dt * 2.4 * smooth * camSpeed, 0, 1)

        camScX = math.lerp(camScX, realCamScX, l)
        camScY = math.lerp(camScY, realCamScY, l)
        camAngle = realCamAngle -- math.lerp(camAngle, realCamAngle, math.clamp(dt * 2.4 * smooth, 0, 1))
        camZoom = settings.smoothZoom and math.lerp(camZoom, realCamZoom, math.clamp(dt * 3.125 * smooth, 0, 1)) or
                      realCamZoom

        setCamProperty("scroll.x", camScX)
        setCamProperty("scroll.y", camScY)
        setCamProperty("angle", camAngle)
        setCamProperty("zoom", camZoom)
    end

    tnTick()

    if (isDead) then
        return
    end

end
-- Thanks to Raltyro <3
