package;

import Controls;
import Controls.Control;
import Controls.KeyboardScheme;
import flixel.input.keyboard.FlxKey;
import OptionCategory;
import Sys.sleep;
import flixel.FlxG;
import flash.events.KeyboardEvent;

class Options
{
	public static var controls:Array<FlxKey> = [FlxKey.A,FlxKey.S,FlxKey.K,FlxKey.L ];
	public static var missForNothing:Bool = true;
	public static var loadModcharts:Bool = true;
	public static var pauseHoldAnims:Bool = true;
	public static var dummy:Bool = false;
	public static var shit:Array<FlxKey> = [
		ALT,
		BACKSPACE,
		SHIFT,
		TAB,
		CAPSLOCK,
		CONTROL,
		ENTER
	];
	public static function getKIdx(control:Control){
		var idx = 0;
		switch (control){
			case Control.LEFT:
				idx = 0;
			case Control.DOWN:
				idx = 1;
			case Control.UP:
				idx = 2;
			case Control.RIGHT:
				idx = 3;
			default:
		}
		return idx;
	}
	public static function getKey(control:Control){
		return controls[getKIdx(control)];
	}
}

class ToggleOption extends Option
{
	private var enabledName = "On";
	private var disabledName = "Off";
	private var property = "dummy";
	public function new(property:String,?disabledName:String,?enabledName:String){
		super();
		this.enabledName=enabledName;
		this.disabledName=disabledName;
		this.property = property;
		name=Reflect.getProperty(Options,property) ? enabledName : disabledName;
	}

	public override function accept():Bool{
		Reflect.setProperty(Options,property,!Reflect.getProperty(Options,property));
		name=Reflect.getProperty(Options,property) ? enabledName : disabledName;

		return true;
	}
}

class ControlOption extends Option
{
	private var controlType:Control = Control.UP;
	private var controls:Controls;
	private var key:FlxKey;
	public var forceUpdate=false;
	public function new(controls:Controls,controlType:Control){
		super();
		this.controlType=controlType;
		this.controls=controls;
		key=Options.getKey(controlType);
		name=Options.getKey(controlType).toString();
	};

	public override function keyPressed(pressed:FlxKey){
		//FlxKey.fromString(String.fromCharCode(event.charCode));
		for(k in Options.shit){
			if(pressed==k){
				pressed=-1;
				break;
			};
		};
		if(pressed!=ESCAPE){
			Options.controls[Options.getKIdx(controlType)]=pressed;
			key=pressed;
			name=Options.getKey(controlType).toString();
		}
		if(pressed!=-1){
			trace("epic style " + pressed.toString() );
			controls.setKeyboardScheme(Custom,true);
			allowMultiKeyInput=false;
			return true;
		}
		return false;
	}

	public override function accept():Bool{
		controls.setKeyboardScheme(None,true);
		allowMultiKeyInput=true;
		//FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);

		return false;
	};
}
