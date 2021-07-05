local receptors = {
	leftPlrNote;
	downPlrNote;
	upPlrNote;
	rightPlrNote;
}

local dadreceptors = {
	leftDadNote;
	downDadNote;
	upDadNote;
	rightDadNote;
}

function create()
    print("create")
end

function beatHit(beat)
    print(beat)
    dad.y = dad.y + 5
end

local counter = 0;

local startX = (window.boundsWidth-window.width)/2
local startY = (window.boundsHeight-window.height)/2
local shakeDuration = 0

function dadNoteHit()
	shakeDuration = 0.1;
	for i = 1,#dadreceptors do
		dadreceptors[i].alpha = dadreceptors[i].alpha + .025
	end
end

function update(elapsed)
	counter = counter + elapsed*3;
	for i = 1,#receptors do
		if(i==1 or i==3)then
			receptors[i].yOffset = math.sin(counter*4)*10
		else
			receptors[i].yOffset = -math.sin(counter*4)*10
		end
		if(i==1)then
			receptors[i].xOffset = math.abs(math.sin(counter*2)*32)
		elseif(i==4)then
			receptors[i].xOffset = -math.abs(math.sin(counter*2)*32)
		end
	end
	if(shakeDuration > 0)then
		shakeDuration = shakeDuration - elapsed;
		window.x = startX+math.random(-15,15)
		window.y = startY+math.random(-15,15)
	else
		window.x = startX
		window.y = startY
	end

	bf.alpha = bf.alpha - .001
end