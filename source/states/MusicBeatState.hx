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

class MusicBeatState extends FlxUIState
{
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
		Cache.Clear();
		if (transIn != null)
			trace('reg ' + transIn.region);

		super.create();
	}

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

		var shit = (Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet;
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
}
