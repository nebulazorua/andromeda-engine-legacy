package;

import lime.utils.Assets;
import sys.thread.Thread;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

using StringTools;

class CoolUtil
{
	public static var difficultyArray:Array<String> = ['EASY', "NORMAL", "HARD"];

	public static function lazyPlaySound(sound,volume:Float=1,looped=false,?group,autodestroy=true,?onComplete){
		Thread.create(()->{
			FlxG.sound.play(sound,volume,looped,group,autodestroy,onComplete);
		});
	}

	inline public static function scale(x:Float,l1:Float,h1:Float,l2:Float,h2:Float):Float
		return ((x - l1) * (h2 - l2) / (h1 - l1) + l2);

	public static function getDominantColour(sprite:FlxSprite):FlxColor{
		var counter:Map<Int,Int>=[];
		for(x in 0...sprite.frameWidth){
			for(y in 0...sprite.frameHeight){
				var colour = sprite.pixels.getPixel32(x,y);
				if(colour!=0){
					if(counter.exists(colour)){
						counter.set(colour,counter.get(colour)+1);
					}else{
						counter.set(colour,1);
					}
				}
			}
		}

		counter.set(FlxColor.BLACK,0);
		var highest:Int = 0;
		var domColour:Int=0;
		for(colour in counter.keys()){
			var amount = counter.get(colour);
			if(amount>=highest){
				highest=amount;
				domColour=colour;
			}
		}

		return domColour;
	}

	public static function truncateFloat( number : Float, precision : Int): Float {
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round( num ) / Math.pow(10, precision);
		return num;
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
