package;

import flixel.math.FlxMath;
import Options;
import haxe.Json;
import haxe.format.JsonParser;
import haxe.macro.Type;

class ScoreUtils
{
	public static var gradeArray:Array<String> = ["☆☆☆☆","☆☆☆","☆☆","☆","S+","S","S-","A+","A","A-","B+","B","B-","C+","C","C-","D"];
	public static var ghostTapping:Bool=false;
	public static var botPlay:Bool=false;

	public static var malewifeMissWeight:Float = -5.5;
	public static var malewifeMineWeight:Float = -7;
	public static var a1 = 0.254829592;
	public static var a2 = -0.284496736;
	public static var a3 = 1.421413741;
	public static var a4 = -1.453152027;
	public static var a5 = 1.061405429;
	public static var p = 0.3275911;

	public static var accuracyConditions:Array<Float>=[
		1.0, // Quad star
		.99, // Trip star
		.98, // Doub star
		.96, // Single star
		.94, // S+
		.92, // S
		.89, // S-
		.86, // A+
		.83, // A
		.8, // A-
		.76, // B+
		.72, // B
		.68, // B-
		.64, // C+
		.6, // C
		.55, // C-
	];

	// https://github.com/etternagame/etterna/blob/0a7bd768cffd6f39a3d84d76964097e43011ce33/src/RageUtil/Utils/RageUtil.h
	// I DONT KNOW WHAT ANY OF THIS DOES
	// THANK YOU ETTERNA
	// FUCK YOU HOODA
	// JK ILY HOODA
	// (PLATONICALLY)
	public static function werwerwerwerf(x:Float):Float{

		var sign:Int = 1;
		if(x<0)sign=-1;

		var sex = Math.abs(x);
		var t = 1/(1+p*sex);
		var y = 1-(((((a5*t+a4)*t)+a3)*t+a2)*t+a1)*t*Math.exp(-sex * sex);

		return sign*y;
	}

	public static function malewife(noteDiff:Float,timeScale:Float=1):Float{ // https://github.com/etternagame/etterna/blob/0a7bd768cffd6f39a3d84d76964097e43011ce33/src/RageUtil/Utils/RageUtil.h
		var jPow:Float = 0.75;
		var maxPoints:Float = 2.0;
		var ridic:Float = 5*timeScale;
		var shit_weight:Float = 180*timeScale;

		var absDiff = Math.abs(noteDiff);
		if(absDiff<=ridic){
			return maxPoints;
		}

		var zero:Float = 65 * Math.pow(timeScale,jPow);
		var dev:Float = 22.7 * Math.pow(timeScale,jPow);

		if(absDiff<=zero){
			return maxPoints*werwerwerwerf((zero-absDiff)/dev);
		}
		if(absDiff<=shit_weight){
			return (absDiff-zero)*malewifeMissWeight/(shit_weight-zero);
		}
		return malewifeMissWeight;
	}

	public static function AccuracyToGrade(accuracy:Float):String {
    var grade = gradeArray[gradeArray.length-1];
    for(i in 0...accuracyConditions.length){
      if(accuracy >= accuracyConditions[i]){
        grade = gradeArray[i];
        break;
      }
    }

    return grade;
  }
}
