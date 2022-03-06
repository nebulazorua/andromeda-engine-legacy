package states;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import Options;
import ui.*;
import flixel.input.keyboard.FlxKey;
import flixel.FlxState;
import haxe.Timer;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;

class MusicBeatState extends FlxUIState
{
	public static var lastState:FlxState;
	public static var currentState:FlxState;

	public static var times:Array<Float> = [];
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	public var curStep:Int = 0;
	public var curBeat:Int = 0;
	public var curDecStep:Float=0;
	public var curDecBeat:Float=0;
	public var canChangeVolume:Bool=true;

	public var volumeDownKeys:Array<FlxKey> = [MINUS, NUMPADMINUS];
	public var volumeUpKeys:Array<FlxKey> = [PLUS, NUMPADPLUS];

	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create()
	{
		//trace(Type.getClassName(Type.getClass(lastState)), Type.getClassName(Type.getClass(this)));
		//if(Type.getClassName(Type.getClass(lastState))!=Type.getClassName(Type.getClass(this))){
			trace("clearing cache");
			Cache.wipe();
		//}
		super.create();
	}

	var lastUpdate:Float = 0;

	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();


		#if FLX_KEYBOARD
		if(canChangeVolume){
			if (FlxG.keys.anyJustReleased(volumeUpKeys))
				FlxG.sound.changeVolume(0.1);
			else if (FlxG.keys.anyJustReleased(volumeDownKeys))
				FlxG.sound.changeVolume(-0.1);
		}
		#end

		/*if(OptionUtils.options.antialiasing==false){
			for(obj in members){
				if((obj is FlxSprite)){
					var sprite:FlxSprite=obj;
					if(sprite.antialiasing)
						sprite.antialiasing=false;
				}
			}
		}*/
		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep/4;
	}

	private function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		var shit = (Conductor.songPosition - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//do literally nothing dumbass
	}

	override function switchTo(next:FlxState){
		MusicBeatState.lastState=FlxG.state;
		trace("i want " + Type.typeof(next) + " and am in " + Type.typeof(FlxG.state));
		trace("last state is " + Type.typeof(MusicBeatState.lastState));
		return super.switchTo(next);
	}

	override function add(obj:FlxBasic){
    if(OptionUtils.options.antialiasing==false){
      if((obj is FlxSprite)){
        var sprite:FlxSprite = cast obj;
        sprite.antialiasing=false;
      }else if((obj is FlxTypedGroup)){
        var group:FlxTypedGroup<FlxSprite> = cast obj;
        for(o in group.members){
          if((o is FlxSprite)){
            var sprite:FlxSprite = cast o;
            sprite.antialiasing=false;
          }
        }
      }
    }
    return super.add(obj);
  }

}
