package;

import Song.SwagSong;

/**
 * ...
 * @author
 */

typedef BPMChangeEvent =
{
	var stepTime:Int;
	var songTime:Float;
	var bpm:Int;
	@:optional var stepCrochet:Float;
}

typedef TSChangeEvent =
{
	var stepTime:Int;
	var songTime:Float;
	var lengthInSteps:Int;
	@:optional var section:Int;
}

class Conductor
{
	public static var ROWS_PER_BEAT:Int = 48;
	// its 48 in ITG but idk because FNF doesnt work w/ note rows
	public static var timeSignature:Int = 16;
	public static var ROWS_PER_MEASURE:Int = ROWS_PER_BEAT*4;

	public static var bpm:Int = 100;
	public static var section:Int = 0;
	public static var crochet:Float = ((60 / bpm) * 1000); // beats in milliseconds
	public static var stepCrochet:Float = crochet / 4; // steps in milliseconds
	public static var rawSongPos:Float;
	public static var songPosition:Float;
	public static var songLength:Float;
	public static var lastSongPos:Float = 0;
	public static var offset:Float = 0;
	public static var currentVisPos:Float =0;
	public static var currentTrackPos:Float = 0;


	public static var safeZoneOffset:Float = 166;

	public static var bpmChangeMap:Array<BPMChangeEvent> = [];
	public static var timeSigChangeMap:Array<TSChangeEvent> = [];

	inline public static function beatToNoteRow(beat:Float):Int{
    return Math.round(beat*Conductor.ROWS_PER_BEAT);
  }

  inline public static function noteRowToBeat(row:Float):Float{
    return row/Conductor.ROWS_PER_BEAT;
  }

	public static function timeSinceLastBPMChange(time:Float):Float{
		var lastChange = getBPMFromSeconds(time);
		return time-lastChange.songTime;
	}

	public static function getBeatInMeasure(time:Float):Float{
		var lastBPMChange = getBPMFromSeconds(time);
		return (time-lastBPMChange.songTime) / (lastBPMChange.stepCrochet*4);
	}

	public static function calculate(){
		Conductor.ROWS_PER_MEASURE = ROWS_PER_BEAT*4; // TODO: time signatures n all that shit
	}

	inline public static function calculateCrochet(bpm:Float){
		return (60/bpm)*1000;
	}

	public static function getCrotchetAtTime(time:Float){
		var lastChange = getBPMFromSeconds(time);
		return lastChange.stepCrochet*4;
	}

	public static function getBPMFromSeconds(time:Float){
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: bpm,
			stepCrochet: stepCrochet
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (time >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		return lastChange;
	}

	public static function getBPMFromStep(step:Float){
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: bpm,
			stepCrochet: stepCrochet
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.bpmChangeMap[i].stepTime<=step)
				lastChange = Conductor.bpmChangeMap[i];
		}

		return lastChange;
	}

	public static function getTSFromStep(step:Float){
		var lastChange:TSChangeEvent = {
			stepTime: 0,
			songTime: 0,
			lengthInSteps: timeSignature,
			section: 0
		}
		for (i in 0...Conductor.timeSigChangeMap.length)
		{
			if (Conductor.timeSigChangeMap[i].stepTime<=step)
				lastChange = Conductor.timeSigChangeMap[i];
		}

		return lastChange;
	}

	public static function getTSFromSeconds(time:Float){
		var lastChange:TSChangeEvent = {
			stepTime: 0,
			songTime: 0,
			lengthInSteps: timeSignature,
			section: 0
		}
		for (i in 0...Conductor.timeSigChangeMap.length)
		{
			if (time >= Conductor.timeSigChangeMap[i].songTime)
				lastChange = Conductor.timeSigChangeMap[i];
		}

		return lastChange;
	}

	public static function stepToSeconds(step:Float){
		var lastChange = getBPMFromStep(step);
		return step * lastChange.stepCrochet; // TODO: make less shit and take BPM into account PROPERLY
	}

	public static function beatToSeconds(beat:Float){
		var step = beat * 4;
		var lastChange = getBPMFromStep(step);
		return lastChange.songTime + ((step - lastChange.stepTime) / (lastChange.bpm / 60)/4) * 1000;//step * (lastChange.stepCrochet*4); // TODO: make less shit and take BPM into account PROPERLY
	}


	public static function getStep(time:Float){
		var lastChange = getBPMFromSeconds(time);
		return lastChange.stepTime + (time - lastChange.songTime) / lastChange.stepCrochet;
	}

	public static function getStepRounded(time:Float){
		var lastChange = getBPMFromSeconds(time);
		return lastChange.stepTime + Math.floor(time - lastChange.songTime) / lastChange.stepCrochet;
	}

	public static function getBeat(time:Float){
		return getStep(time)/4;
	}

	public static function getBeatRounded(time:Float):Int{
		return Math.floor(getStepRounded(time)/4);
	}

	public static function getSection(time:Float){
		var lastChange = getTSFromSeconds(time);
		return lastChange.section + (time - lastChange.songTime) / (getBPMFromSeconds(time).stepCrochet * lastChange.lengthInSteps);
	}

	public function new()
	{
	}

	public static function mapBPMChanges(song:SwagSong)
	{
		bpmChangeMap = [];

		var curBPM:Int = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;
		for (i in 0...song.notes.length)
		{
			if(song.notes[i].changeBPM && song.notes[i].bpm != curBPM)
			{
				curBPM = song.notes[i].bpm;
				var event:BPMChangeEvent = {
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM,
					stepCrochet: calculateCrochet(curBPM)/4
				};
				bpmChangeMap.push(event);
			}

			var deltaSteps:Int = song.notes[i].lengthInSteps;
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
		}
		trace("new BPM map BUDDY " + bpmChangeMap);
	}

	public static function changeBPM(newBpm:Int)
	{
		bpm = newBpm;

		crochet = calculateCrochet(bpm);
		stepCrochet = crochet / 4;
	}

	public static function mapTimeSigChanges(song:SwagSong)
	{
		timeSigChangeMap = [];

		var curTS:Int = 16;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;
		for (i in 0...song.notes.length)
		{
			if (song.notes[i].lengthInSteps != curTS && song.notes[i].changeTS)
				{
					curTS = song.notes[i].lengthInSteps;
					var event:TSChangeEvent = {
						stepTime: totalSteps,
						songTime: totalPos,
						lengthInSteps: curTS,
						section: i
					};
					timeSigChangeMap.push(event);
				}

				var deltaSteps:Int = song.notes[i].lengthInSteps;
			
				totalSteps += deltaSteps;
				totalPos = beatToSeconds(totalSteps/4);
		}
		trace('New Time Signature Map ' + timeSigChangeMap);
	}

	public static function changeTimeSignature(newTS:Int)
	{
		timeSignature = newTS;
	}
}
