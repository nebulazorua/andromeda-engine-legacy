function createBG()
print(getfenv(2))
setfenv(0,getfenv(2)); -- so its in the env of the requirer
local bg = newSprite(-500,-170,true);
bg:loadGraphic("background/garStagebgAlt");
bg.scrollFactorX = .7;
bg.scrollFactorY = .7;
bg.active = false;
bg.antialiasing = true;
print'bg'

local smoke = newSprite(0,-290,true);
smoke:setFrames("background/garSmoke")
smoke.alpha=.3;
smoke:setScale(1.7);
smoke:addAnimByPrefix("garsmoke","smokey",13)
smoke:playAnim("garsmoke")
smoke.scrollFactorX = .7;
smoke.scrollFactorY = .7;
print'smoke'

local alley = newSprite(-500,-200,true)
alley:loadGraphic("background/garStagealt");
alley.antialiasing=true;
alley.scrollFactorX = .9;
alley.scrollFactorY = .9;
alley.active=false;
print'alley'

local corpse = newSprite(-230,540,true)
corpse:loadGraphic"background/gardead"
corpse.antialiasing=true
corpse.scrollFactorX=.9
corpse.scrollFactorY=.9
corpse.active=false;
print'corpse'

local smoke2 = newSprite(0,0);
smoke2:setFrames("background/garSmoke")
smoke2:setScale(1.6);
smoke2:addAnimByPrefix("garsmoke","smokey",13)
smoke2:playAnim("garsmoke")
smoke2.scrollFactorX = 1.1;
smoke2.scrollFactorY = 1.1;
print'smoke2'

iconP2:loadGraphic("icons",true,150,150)
iconP2:addAnim("garcellodead",{0,1},0,false,false);
iconP2:playAnim("garcellodead");

defaultCamZoom = .9
end

return createBG;