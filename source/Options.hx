package;

import Controls;
import Controls.Control;
import Controls.KeyboardScheme;
import flixel.input.keyboard.FlxKey;
import OptionCategory;
import Sys.sleep;
import flixel.FlxG;
import flash.events.KeyboardEvent;
import flixel.util.FlxSave;

class OptionUtils
{
	private static var saveFile:FlxSave = new FlxSave();

	public static var ratingWindowNames:Array<String>=[
		"Vanilla",
		"ITG",
		"Quaver",
		"Judge Four",
		"Modern KE",
		"Dream",
	];
	public static var ratingWindowTypes:Array<Array<Float>> = [ // TODO: make these all properly scale w/ the safeZoneOffset n shit
		[ // Vanilla
			32, // sick
			123, // good
			148, // bad
			Conductor.safeZoneOffset, // shit
		],
		[ // ITG
			41.5, // sick
			83, // good
			124.5, // bad
			Conductor.safeZoneOffset, // shit
		],
		[ // Quaver
			43, // sick
			76, // good
			127, // bad
			Conductor.safeZoneOffset // shit
		],
		[ // Judge 4
			40, // sick
			83, // good
			124.5, // bad
			Conductor.safeZoneOffset, // shit
		],
		[ // Modern KE
			45, // sick
			90, // good
			135, // bad
			Conductor.safeZoneOffset, // shit
		],
		[ // All Sicks
			Conductor.safeZoneOffset,
			0,
			0,
			0
		],
	];
	public static var shit:Array<FlxKey> = [
		ALT,
		BACKSPACE,
		SHIFT,
		TAB,
		CAPSLOCK,
		CONTROL,
		ENTER
	];
	public static function bindSave(?saveName:String="nebbyEngine"){
		saveFile.bind(saveName);
	};
	public static function saveOptions(){
		var fields = Type.getClassFields(Options);
		for(f in fields){
			var shit = Reflect.getProperty(Options,f);
			Reflect.setProperty(saveFile.data,f,shit);
		}
		saveFile.flush();
	};
	public static function loadOptions(){
		var fields = Reflect.fields(saveFile.data);
		for(f in fields){
			Reflect.setProperty(Options,f,Reflect.getProperty(saveFile.data,f));
		}
	}

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
		return Options.controls[getKIdx(control)];
	}
}

class Options
{
	public static var controls:Array<FlxKey> = [FlxKey.A,FlxKey.S,FlxKey.K,FlxKey.L ];
	public static var missForNothing:Bool = true;
	public static var loadModcharts:Bool = true;
	public static var pauseHoldAnims:Bool = true;
	public static var dummy:Bool = false;
	public static var dummyInt:Int = 0;
	public static var ratingWindow:Int = 0;
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

class ScrollOption extends Option
{
	private var names:Array<String>;
	private var property = "dummyInt";
	private var max:Int = -1;
	public function new(property:String,?max:Int=-1,?names:Array<String>){
		super();
		this.property=property;
		this.names=names;
		var value = Reflect.getProperty(Options,property);
		this.max=max;
		if(names!=null){
			name = names[value];
		}else{
			name = Std.string(value);
		}
	};

	public override function left():Bool{
		var value:Int = Std.int(Reflect.getProperty(Options,property)-1);
		trace(value);

		if(value<0)
			value=max;
		if(value>max)
			value=0;

		Reflect.setProperty(Options,property,value);

		if(names!=null){
			name = names[value];
		}else{
			name = Std.string(value);
		}
		return true;
	};
	public override function right():Bool{
		var value:Int = Std.int(Reflect.getProperty(Options,property)+1);
		trace(value);

		if(value<0)
			value=max;
		if(value>max)
			value=0;
			Reflect.setProperty(Options,property,value);

		if(names!=null){
			name = names[value];
		}else{
			name = Std.string(value);
		}
		return true;
	};
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
		key=OptionUtils.getKey(controlType);
		name=OptionUtils.getKey(controlType).toString();
	};

	public override function keyPressed(pressed:FlxKey){
		//FlxKey.fromString(String.fromCharCode(event.charCode));
		for(k in OptionUtils.shit){
			if(pressed==k){
				pressed=-1;
				break;
			};
		};
		if(pressed!=ESCAPE){
			Options.controls[OptionUtils.getKIdx(controlType)]=pressed;
			key=pressed;
			name=OptionUtils.getKey(controlType).toString();
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
