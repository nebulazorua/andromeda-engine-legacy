package;

import Controls.Control;
import flixel.input.keyboard.FlxKey;
import OptionCategory;

class Options
{
	public static var controls:Array<FlxKey> = [FlxKey.A,FlxKey.S,FlxKey.K,FlxKey.L ];

	public static function getKey(control:Control){
		var returnedControl:FlxKey = controls[0];

		switch (control){
			case Control.LEFT:
				returnedControl= controls[0];
			case Control.DOWN:
				returnedControl= controls[1];
			case Control.UP:
				returnedControl= controls[2];
			case Control.RIGHT:
				returnedControl= controls[3];
			default:

		}
		return returnedControl;
	}
}

class ControlOption extends Option
{
	private var controlType:Control = Control.UP;
	public function new(controlType:Control){
		super();
		this.controlType=controlType;
		name=Options.getKey(controlType).toString();
	};

	public override function accept():Bool{
		trace("COCK JOKE");
		return false;
	};
}
