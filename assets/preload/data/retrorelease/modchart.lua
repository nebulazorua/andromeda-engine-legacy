local function require(module)
    local file = debug.getinfo(1).source
    local directory = file:sub(2,#file-12)
    -- TODO: _FILEDIRECTORY
    return getfenv().require(directory .. module)
end
local function newSpriteLG(graphic,x,y,behind)
	local sprite = newSprite(x,y,behind)
	sprite:loadGraphic(graphic)
	return sprite
end

require("background")()
local tween = require("tween")

dad:changeCharacter("garcelloghosty") -- CACHE IT
dad:changeCharacter("garcellodead")

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


local whitebg = newSpriteLG('WhiteBG',200,500,true)
local blackbg = newSpriteLG('BlackFade',200,500,true)
local whitefade = newSpriteLG('WhiteBG',200,500,false)
local blackfade = newSpriteLG('BlackFade',200,500, false)
local fullSmoke = newSpriteLG('smoke',20,443,false)

smoke2.alpha = 0

whitebg.alpha = 0
whitebg:setScale(4)

blackbg.alpha = 1
blackbg:setScale(4)

blackfade.alpha = 0
blackfade:setScale(4)

whitefade.alpha = 0
whitefade:setScale(4)

fullSmoke.alpha = 0
fullSmoke:setScale(2)

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
local fadeCounter=0;

function update(elapsed)
	local currentBeat = (songPosition / 1000)*(bpm/60)
	if(hideStrums)then
		for i = 1,#strums do
			strums[i].alpha=0
		end
	end
	local tweening={}
	for i = #tweens,1,-1 do
		local done = tweens[i]:update(elapsed);
		if(done)then
			table.remove(tweens,i)
		end
	end
	if(zoom)then
		gameCam.zoom=2;
	end
	fullSmoke.x = fullSmoke.x+3*math.sin(currentBeat)

	if(swayingsmall or swayingmed or swayingbig or swayingepic)then
		for i=1,#strums do
			if(swayingsmall)then
				strums[i].xOffset = 32*math.sin(currentBeat)
				strums[i].yOffset = 10*math.cos(currentBeat)+10
			end
			if(swayingmed)then
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
	end

	if(DAFINALE)then
		HUDCam.angle = 5 * math.cos(currentBeat)
	end
	if(curStep>=2390)then
		fadeCounter=fadeCounter+elapsed
	end
	if(curStep>=2390 and fadeCounter>=0.1)then
		fadeCounter=0;
		dad.alpha=dad.alpha-0.05;
		iconP2.alpha=iconP2.alpha-0.05;
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
	if(isStepTight(step))then
		lastTightMan=step;
		dad.disabledDance=true;
		dad:playAnim"tightass"
	elseif(step==lastTightMan+10)then
		dad.disabledDance=false;
	end
	if(step==16)then
		hideStrums=false
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
		table.insert(tweens,tween.new(0.6,smoke2,{alpha=1},'inCirc'))
	end
	if(step==144)then
		garcellomilfuwu=false;
	end
	if(step == 262)then
		table.insert(tweens,tween.new(0.01,blackbg,{alpha=1},'inCirc'))
		table.insert(tweens,tween.new(0.01,smoke2,{alpha=0},'outCirc'))
		table.insert(tweens,tween.new(0.01,whitefade,{alpha=1},'inCirc'))
		zoom = true
		for i=5,8 do
			table.insert(tweens,tween.new(0.2,strums[i],{alpha=0},'outCirc'))
		end
	end
	if(step==263)then
		table.insert(tweens,tween.new(0.2,whitefade,{alpha=0},'outCirc'))
	end
	if(step==272)then
		zoom=false;
		garcellomilfuwu=true;
		table.insert(tweens,tween.new(0.01,blackbg,{alpha=0},'outCirc'))
		table.insert(tweens,tween.new(0.01,smoke2,{alpha=1},'inCirc'))
		table.insert(tweens,tween.new(0.01,whitefade,{alpha=1},'inCirc'))
		swayingsmall=true;
		for i=1,#strums do
			table.insert(tweens,tween.new(0.01,strums[i],{alpha=1},'inCirc'))
		end
	end
	if(step==273)then
		table.insert(tweens,tween.new(0.7,whitefade,{alpha=0},'outCirc'))
	end
	if(step==528 or step==656)then
		garcellomilfuwu=not garcellomilfuwu;
	end
	if(step==902)then
		table.insert(tweens,tween.new(0.1,blackbg,{alpha=1},'inCirc'))
		table.insert(tweens,tween.new(0.1,smoke2,{alpha=0},'outCirc'))
		garcellomilfuwu=false;
		for i=1,#strums do
			table.insert(tweens,tween.new(0.1,strums[i],{alpha=0},'outCirc'))
		end
	end
	if(step==912)then
		garcellomilfuwu=true
		swayingsmall=false
		swayingmed=true;
		table.insert(tweens,tween.new(0.01,blackbg,{alpha=0},'outCirc'))
		table.insert(tweens,tween.new(0.01,smoke2,{alpha=1},'inCirc'))
		table.insert(tweens,tween.new(0.01,whitefade,{alpha=1},'inCirc'))
		for i=1,#strums do
			table.insert(tweens,tween.new(0.01,strums[i],{alpha=1},'inCirc'))
		end
	end
	if(step==913)then
		table.insert(tweens,tween.new(0.2,whitefade,{alpha=0},'outCirc'))
	end
	if(step==1184)then
		garcellomilfuwu=false
	end
	if(step==1200)then
		table.insert(tweens,tween.new(0.6,blackfade,{alpha=1},'inCirc'))
		table.insert(tweens,tween.new(0.6,dad,{alpha=0},'outCirc'))
		for i=1,#strums do
			table.insert(tweens,tween.new(0.5,strums[i],{alpha=0},'outCirc'))
		end
	end
	if(step==1216)then
		table.insert(tweens,tween.new(0.01,bf,{alpha=0},'outCirc'))
		table.insert(tweens,tween.new(0.01,gf,{alpha=0},'outCirc'))
		table.insert(tweens,tween.new(0.01,blackbg,{alpha=1},'inCirc'))
		zoom=true
	end
	if(step==1228)then
		table.insert(tweens,tween.new(0.01,blackfade,{alpha=0},'outCirc'))
		table.insert(tweens,tween.new(0.01,dad,{alpha=1},'inCirc'))
		for i=1,4 do
			table.insert(tweens,tween.new(0.01,strums[i],{alpha=1},'inCirc'))
		end
	end
	if(step==1232)then
		garcellomilfuwu=true
		swayingmedium=false;
		swayingbig=true;
		table.insert(tweens,tween.new(0.01,blackbg,{alpha=0},'outCirc'))
		table.insert(tweens,tween.new(0.01,bf,{alpha=1},'inCirc'))
		table.insert(tweens,tween.new(0.01,gf,{alpha=1},'inCirc'))
		table.insert(tweens,tween.new(0.01,whitefade,{alpha=1},'inCirc'))
		table.insert(tweens,tween.new(0.01,fullSmoke,{alpha=1},'inCirc'))
		for i=5,8 do
			table.insert(tweens,tween.new(0.01,strums[i],{alpha=1},'inCirc'))
		end
		zoom=false
	end
	if(step==1233)then
		table.insert(tweens,tween.new(0.4,whitefade,{alpha=0},'outCirc'))
	end
	if(step==1488 or step==1616)then
		garcellomilfuwu = not garcellomilfuwu
	end
	if(step==1862)then
		table.insert(tweens,tween.new(0.1,fullSmoke,{alpha=0},'outCirc'))
		table.insert(tweens,tween.new(0.1,smoke2,{alpha=0},'outCirc'))
		table.insert(tweens,tween.new(0.1,blackbg,{alpha=1},'inCirc'))
		garcellomilfuwu=false
		for i=1,#strums do
			table.insert(tweens,tween.new(0.01,strums[i],{alpha=0},'outCirc'))
		end
	end
	if(step==1872)then
		table.insert(tweens,tween.new(0.01,blackbg,{alpha=0},'outCirc'))
		table.insert(tweens,tween.new(0.01,whitefade,{alpha=1},'inCirc'))
		table.insert(tweens,tween.new(0.01,fullSmoke,{alpha=1},'inCirc'))
		table.insert(tweens,tween.new(0.01,smoke2,{alpha=1},'inCirc'))
		garcellomilfuwu=true
		swayingsmall=false
		swayingmed=false
		swayingbig=false
		swayingepic=true

		for i=1,#strums do
			table.insert(tweens,tween.new(0.01,strums[i],{alpha=1},'inCirc'))
		end
	end
	if(step==1873)then
		table.insert(tweens,tween.new(0.4,whitefade,{alpha=0},'outCirc'))
	end
	if(step==2016)then
		DAFINALE=true
	end
	if(step==2144)then
		DAFINALE=false
		table.insert(tweens,tween.new(1,HUDCam,{angle=0},'outQuad'))
		swayingepic=false
		garcellomilfuwu=false;
		table.insert(tweens,tween.new(7,smoke2,{alpha=0},'outCirc'))
		table.insert(tweens,tween.new(2,fullSmoke,{alpha=0},'outCirc'))
		for i=1,#strums do
			table.insert(tweens,tween.new(1,strums[i],{xOffset=0,yOffset=0},'outQuad'))
		end
	end
	if(step==2160)then
		table.insert(tweens,tween.new(7,fadingAlley,{alpha=1},'inCirc'))
		table.insert(tweens,tween.new(7,fadingBg,{alpha=1},'inCirc'))
		table.insert(tweens,tween.new(7,smoke,{alpha=0},'outCirc'))
		table.insert(tweens,tween.new(7,smoke2,{alpha=0},'outCirc'))
	end
	if(step==2176)then
		dad:changeCharacter"garcelloghosty"
		iconP2:playAnim("garcelloghosty");
	end
	if(step==2392)then
		dad.disabledDance=true;
		dad:playAnim("farewell",true)
		print("goodbye")
		table.insert(tweens,tween.new(1.5,leftDadNote,{xOffset=-100,yOffset=178,angle=-60,alpha=0},'linear'))
		table.insert(tweens,tween.new(1.5,downDadNote,{yOffset=212,alpha=0},'linear'))
		table.insert(tweens,tween.new(1.5,upDadNote,{xOffset=50,yOffset=310,angle=30,alpha=0},'linear'))
		table.insert(tweens,tween.new(1.5,rightDadNote,{xOffset=100,yOffset=482,angle=60,alpha=0},'linear'))
	end
	if(step==2432)then
		table.insert(tweens,tween.new(2,blackfade,{alpha=1},'inCirc'))
		for i = 1,4 do
			table.insert(tweens,tween.new(2,strums[i],{alpha=0},'outCirc'))
		end
	end
end