package ui;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import sys.FileSystem;
import flixel.FlxG;
import haxe.Json;
import flash.display.BitmapData;
using StringTools;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;
	public var lossIndex:Int=-1;
	public var neutralIndex:Int=0;
	public var winningIndex:Int=-1;

	public function changeCharacter(char:String){
		var path = 'assets/characters/icons/${char}';
		var charArray:Array<Int> = [];
		var image:Null<FlxGraphicAsset>=null;
		if(FlxG.bitmap.get(path)!=null){
			image = FlxG.bitmap.get(path);
		}else if(FileSystem.exists(path + ".png")){
			image = FlxG.bitmap.add(BitmapData.fromFile(path + ".png"),false,path);
		}else if(FileSystem.exists("assets/characters/icons/face.png")){
			FlxG.log.warn('${char} is not a valid icon name. Using fallback');
			image = FlxG.bitmap.add(BitmapData.fromFile("assets/characters/icons/face.png"),false,path);

		}else{

			FlxG.log.error("Can't find fallback icon and " + char + " is not a valid icon name. Expect a crash lol");
			trace("Can't find fallback icon and " + char + " is not a valid icon name. Expect a crash lol");
			return;
		}
		loadGraphic(image);

		for(w in 0...Math.floor(width/150)){
			charArray.push(w);
		}
		loadGraphic(image,true,150,150);
		switch(charArray.length){
			case 1:

			case 2:
				neutralIndex=0;
				lossIndex=1;
			case 3:
				lossIndex=0;
				neutralIndex=1;
				winningIndex=2;
		}
		if(char=='senpai' || char=='spirit' || char.contains("pixel")){
			antialiasing=false;
		}else{
			antialiasing=true;
		}
		animation.add('icon',charArray,0,false);
		animation.play('icon',true);
		if(animation.curAnim!=null)
			animation.curAnim.curFrame = neutralIndex;

		width=150;
		height=150;
		updateHitbox();
	}
	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		flipX=isPlayer;
		changeCharacter(char);

		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
