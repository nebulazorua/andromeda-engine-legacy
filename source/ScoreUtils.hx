package;

import flixel.math.FlxMath;
import Options;
import haxe.Json;
import haxe.format.JsonParser;
import haxe.macro.Type;
import states.*;

class ScoreUtils
{
	public static var ghostTapping:Bool=false;
	public static var botPlay:Bool=false;
	public static var wifeZeroPoint:Float = 65;

	public static var malewifeMissWeight:Float = -5.5;
	public static var malewifeMineWeight:Float = -7;
	public static var a1 = 0.254829592;
	public static var a2 = -0.284496736;
	public static var a3 = 1.421413741;
	public static var a4 = -1.453152027;
	public static var a5 = 1.061405429;
	public static var p = 0.3275911;

	public static var gradeConditions:Map<Int,String> = [
		100 => "☆☆☆☆",
		99 => "☆☆☆",
		98 => "☆☆",
		96 => "☆",
		94 => "S+",
		92 => "S",
		89 => "S-",
		86 => "A+",
		83 => "A",
		80 => "A-",
		76=>  "B+",
		72=> "B",
		68=>  "B-",
		64=> "C+",
		60=> "C",
		55=> "C-",
		50=> "D+",
		45 => "D",
	];

	// https://github.com/etternagame/etterna/blob/0a7bd768cffd6f39a3d84d76964097e43011ce33/src/RageUtil/Utils/RageUtil.h
	// I DONT KNOW WHAT ANY OF THIS DOES
	// THANK YOU ETTERNA
	// FUCK YOU HOODA
	// JK ILY HOODA
	// (PLATONICALLY)
	public static function werwerwerwerf(x:Float):Float
	{
		var sign = 1;
		if (x < 0)sign = -1;
		x = Math.abs(x);
		var t = 1 / (1+p*x);
		var y = 1 - (((((a5*t+a4)*t)+a3)*t+a2)*t+a1)*t*Math.exp(-x*x);
		return sign*y;
	}

	public static function malewife(noteDiff:Float,timeScale:Float=1):Float{ // https://github.com/etternagame/etterna/blob/0a7bd768cffd6f39a3d84d76964097e43011ce33/src/RageUtil/Utils/RageUtil.h
		var jPow:Float = 0.75;
		var maxPoints:Float = 2.0;
		var ridic:Float = 5*timeScale;
		var shit_weight:Float = Conductor.safeZoneOffset; // should I use this?? idfk man
		var absDiff = Math.abs(noteDiff);
		var zero:Float = wifeZeroPoint * Math.pow(timeScale,jPow);
		var dev:Float = 22.7 * Math.pow(timeScale,jPow);

		if(absDiff<=ridic){
			return maxPoints;
		} else if(absDiff<=zero){
			return maxPoints*werwerwerwerf((zero-absDiff)/dev);
		}else if(absDiff<=shit_weight){
			return (absDiff-zero)*malewifeMissWeight/(shit_weight-zero);
		}
		return malewifeMissWeight;
	}

	public static function GetMaxAccuracy(noteCounters:Map<String,Int>):Float{ // ITG-like system
		var points:Float = 0;
		var topJudge = PlayState.judgeMan.getHighestAccJudgement();
		for(i in 0...noteCounters.get("taps")){
			points += PlayState.judgeMan.getJudgementAccuracy(topJudge);
		}
		return points;
	}


	public static function AccuracyToGrade(accuracy:Float):String {
		var accuracy = accuracy*100;
    var grade = "D";
		var highest:Float=0;
		for(gradeAcc in gradeConditions.keys()){
			if(accuracy>=gradeAcc && gradeAcc>=highest){
				highest=gradeAcc;
				grade=gradeConditions.get(gradeAcc);
			}
		}

    return grade;
  }
}
