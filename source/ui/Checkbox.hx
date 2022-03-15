package ui;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.input.mouse.FlxMouseEventManager;
class Checkbox extends FlxSprite
{
	public var state:Bool=false;
	public var tracker:FlxSprite;
	public var callback:Bool->Void;
	public var canClick:Bool=true;

	public var trackOffX:Float = -60;
	public var trackOffY = 75;
//setPosition(tracker.x - 60, tracker.y + 75);

	public function new(state:Bool){
		super();
		this.state=state;
		frames = Paths.getSparrowAtlas("checkbox");
		animation.addByIndices("unselected","confirm",[0],"",36,false);
		animation.addByPrefix("selecting","confirm",36,false);
		var reversedindices = []; // man i hate haxe I DONT WANNA DO A TABI CODE :(((
			// PROBABLY A BETTER WAY TO DO THIS
			// I DONT CARE IM BAD AT CODE
		var max = animation.getByName("selecting").frames.copy();
		max.reverse();
		for(i in max){
			reversedindices.push(i-2);
		}
		animation.addByIndices("unselecting","confirm",reversedindices,"",36,false);
		animation.addByIndices("selected","confirm",[animation.getByName("selecting").frames.length-2],"",36,false);
		antialiasing=true;
		if(state)
			animation.play("selected");
		else
			animation.play("unselected");

		setGraphicSize(Std.int(width*.3) );
		updateHitbox();
	}

	public function changeState(newState:Bool,playAnim=true){
		state=newState;
		if(callback!=null)callback(state);
		if(playAnim){
			if(state){
				animation.play("selecting",true,false,animation.curAnim.name=='unselecting'?animation.curAnim.frames.length-animation.curAnim.curFrame:0);
			}else{
				animation.play("unselecting",true,false,animation.curAnim.name=='selecting'?animation.curAnim.frames.length-animation.curAnim.curFrame:0);
			}
		}else{
			if(state){
				animation.play("selected",true);
			}else{
				animation.play("unselected",true);
			}
		}
	}

	override function update(elapsed:Float){
		super.update(elapsed);
		if(tracker!=null){
			/*
			x = tracker.x - 140;
			y = tracker.y - 45;
			*/
			setPosition(tracker.x + trackOffX, tracker.y + trackOffY);
		}

		if(canClick){
			if(FlxG.mouse.justPressed && FlxG.mouse.overlaps(this)){
				changeState(!state);
			}
		}
		if(animation.curAnim!=null){
			if(animation.curAnim.finished && (animation.curAnim.name=="selecting" || animation.curAnim.name=="unselecting")){
				if(state){
					animation.play("selected",true);
				}else{
					animation.play("unselected",true);
				}
			}
		}

	}
}
