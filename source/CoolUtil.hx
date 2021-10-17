package;

import lime.utils.Assets;
import sys.thread.Thread;
import flixel.FlxG;

using StringTools;

class CoolUtil
{
	public static var difficultyArray:Array<String> = ['EASY', "NORMAL", "HARD"];

	public static function lazyPlaySound(sound,volume:Float=1,looped=false,?group,autodestroy=true,?onComplete){
		Thread.create(()->{
			FlxG.sound.play(sound,volume,looped,group,autodestroy,onComplete);
		});
	}
	public static function difficultyString(?difficulty:Int):String
	{
		if(difficulty==null)
			difficulty=PlayState.storyDifficulty;

		return difficultyArray[difficulty];
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function coolTextFile2(data:String):Array<String>
	{
		var daList:Array<String> = data.trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function numberArray(max:Int, ?min = 0, ?reverse=false):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			if(reverse){
				dumbArray.push(max-i);
			}else{
				dumbArray.push(i);
			}

		}
		return dumbArray;
	}
}
