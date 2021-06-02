local function require(module)
	local file = debug.getinfo(1).source
	local directory = file:sub(2,#file-12)
	-- TODO: _FILEDIRECTORY
	return require(directory .. module)
end

require("background").create()
local tween = require("tween")

local tightSteps={262,902,1862}
local strums = {
	leftPlrNote,
	downPlrNote,
	upPlrNote,
	rightPlrNote,
	leftDadNote,
	downDadNote,
	upDadNote,
	rightDadNote,
}
local hideStrums = true;
local zoom = false;

function isStepTight(step)
	for i = 1,#tightSteps do
		if(tightSteps[i]==step)then
			return true
		end
	end
	return false
end

	
local whitebg = newSprite('WhiteBG',200,500,true)
local blackbg = newSprite('BlackFade',200,500,true)
local whitefade = newSprite('WhiteBG',200,500,false)
local blackfade = newSprite('BlackFade',200,500, false)
local fading = newSprite('Fading',40,443,true)
local smoke = newSprite('smoke',20,443,false)

whitebg.alpha = 0
whitebg:setScale(4)


blackbg.alpha = 1
blackbg:setScale(4)

fading.alpha = 0
fading:setScale(2)

blackfade.alpha = 0
blackfade:setScale(4)

whitefade.alpha = 0
whitefade:setScale(4)

smoke.alpha = 0
smoke:setScale(2)

bf.alpha = 0
gf.alpha = 0
dad.alpha = 0
dad.y = -600

HUDCam.y = 1000
HUDCam.x = 0

local swayingsmall = false
local swayingmed = false
local swayingbig = false
local swayingepic = false
local DAFINALE = false;
local garcellomilfuwu = false;

local tweens = {}

function update(elapsed)
	local currentBeat = (songPosition / 1000)*(bpm/60)
	if(hideStrums)then
		for i = 1,#strums do
			strums[i].alpha=0
		end
	end
	for i = 1,#tweens do
		tweens[i]:update(elapsed)
	end
	if(zoom)then
		gameCam.zoom=2;
	end
	smoke.x = smoke.x+3*math.sin(currentBeat)

	for i=1,#strums do
		if(swayingsmall or swayingmed)then
			strums[i].xOffset = 32*math.sin((currentBeat + i))
			strums[i].yOffset = 10*math.cos((currentBeat + i))+10
		end
		if(swayingbig)then
			strums[i].xOffset = 32*math.sin((currentBeat + i))
			strums[i].yOffset = 28*math.cos((currentBeat + i))+10
		end
		if(swayingepic)then
			strums[i].xOffset = 32*math.sin((currentBeat + i*.5)*math.pi)
			strums[i].yOffset = 28*math.cos((currentBeat + i*.5)*math.pi)+10
		end
	end

	if(DAFINALE)then
		HUDCam.angle = 5 * math.cos(currentBeat)
	end
end

function beatHit()
	if(garcellomilfuwu)then
		gameCam.zoom = 1;
	end
end

local lastTightMan=0;

function dadNoteHit()
	dad.disabledDance=false;
end

function stepHit(step)
	--[[
		if(curStep == 2176)
		 	{
				remove(dad);
				dad = new Character(dad.x, dad.y, 'garcelloghosty');
				add(dad);
			}
			if(curStep == 2392)
			{
				dad.animation.play('coolguy');
			}

	]]
	if(isStepTight(step))then
		lastTightMan=step;
		dad.disabledDance=true;
		dad:playAnim"tightass"
	elseif(step>=lastTightMan+20)then
		dad.disabledDance=false;
	end
	if(step==16)then
		hide=false
		table.insert(tweens,tween.new(0.6,gf,{alpha=1},'linear'))
		HUDCam.y = 0
		HUDCam.x = 0
	end
	if(step==48)then
		table.insert(tweens,tween.new(0.6,bf,{alpha=1},'linear'))
		for i=1,4 do
			--tweenFadeIn(i,1, 0.6)
			table.insert(tweens,tween.new(0.6,strums[i],{alpha=1},'inCirc'))
		end
	end
	if(step==80)then
		table.insert(tweens,tween.new(1.5,dad,{alpha=1},'linear'))
		table.insert(tweens,tween.new(2,dad,{y=100},'linear'))
		garcellomilfuwu=true;
		for i=5,8 do
			table.insert(tweens,tween.new(0.6,strums[i],{alpha=1},'inCirc'))
		end
	end
	if(step==112)then
		table.insert(tweens,tween.new(2,dad,{y=100},'linear'))
		table.insert(tweens,tween.new(0.6,blackbg,{alpha=0},'outCirc'))
	end
	if(step==144)then
		garcellomilfuwu=false;
	end
end