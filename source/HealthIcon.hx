package;

import flixel.FlxSprite;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public function changeCharacter(char:String){
		loadGraphic(Paths.image('iconGrid'), true, 150, 150);

		animation.add('bf', [0, 1], 0, false);
		animation.add('bf-car', [0, 1], 0, false);
		animation.add('bf-christmas', [0, 1], 0, false);
		animation.add('spooky', [2, 3], 0, false);
		animation.add('pico', [4, 5], 0, false);
		animation.add('mom', [6, 7], 0, false);
		animation.add('mom-car', [6, 7], 0, false);
		animation.add('tankman', [8, 9], 0, false);
		animation.add('face', [10, 11], 0, false);
		animation.add('dad', [12, 13], 0, false);
		animation.add('bf-old', [14, 15], 0, false);
		animation.add('gf', [16], 0, false);
		animation.add('lizzy', [16], 0, false);
		animation.add('parents-christmas', [17], 0, false);
		animation.add('monster', [19, 20], 0, false);
		animation.add('monster-christmas', [19, 20], 0, false);
		animation.add('bf-pixel', [21, 21], 0, false);
		animation.add('senpai', [22, 22], 0, false);
		animation.add('senpai-angry', [22, 22], 0, false);
		animation.add('spirit', [23, 23], 0, false);
		animation.add('bf-neb', [24,25], 0, false);
		if(animation.getByName(char)!=null)
			animation.play(char);
		else
			animation.play("face");
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
