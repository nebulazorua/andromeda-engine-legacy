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
import flixel.FlxState;
import flixel.FlxSprite;
import ui.*;
import flixel.group.FlxGroup.FlxTypedGroup;
class OptionUtils
{
	private static var saveFile:FlxSave = new FlxSave();
	public static var noteSkins:Array<String>=[];

	public static var camFocuses:Array<String> = [
		"Default",
		"BF",
		"Dad",
		"Center",
	];

	public static var shit:Array<FlxKey> = [
		ALT,
		SHIFT,
		TAB,
		CAPSLOCK,
		CONTROL,
		ENTER
	];
	public static var options:Options = new Options();

	public static function bindSave(?saveName:String="andromedaEngineOptions"){
		saveFile.bind(saveName);
	};
	public static function saveOptions(options:Options){
		var fields = Reflect.fields(options);
		for(f in fields){
			var shit = Reflect.field(options,f);
			trace(f,shit);
			Reflect.setField(saveFile.data,f,shit);
		}
		saveFile.flush();
	};
	public static function loadOptions(options:Options){
		var fields = Reflect.fields(saveFile.data);
		for(f in fields){
			trace(f,Reflect.getProperty(options,f));
			if(Reflect.getProperty(options,f)!=null)
				Reflect.setField(options,f,Reflect.field(saveFile.data,f));
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
			case Control.RESET:
				idx = 4;
			case Control.PAUSE:
				idx = 5;
			default:
		}
		return idx;
	}
	public static function getKey(control:Control){
		return options.controls[getKIdx(control)];
	}
}

class Options
{
	public var dummy:Bool = false;
	public var dummyInt:Int = 0;

	// gameplay
	public var controls:Array<FlxKey> = [FlxKey.A,FlxKey.S,FlxKey.K,FlxKey.L,FlxKey.R,FlxKey.ENTER];
	public var ghosttapping:Bool = false;
	public var failForMissing:Bool = false;
	public var accuracySystem:Int = 0;
	public var resetKey:Bool = true;
	public var cMod:Float = 0;
	public var xMod:Float = 1;
	public var mMod:Float = 1;
	public var fixHoldSegCount:Bool = true;
	public var judgementWindow:String = 'ITG';
	public var noteOffset:Int = 0;
	public var botPlay:Bool = false;
	public var loadModcharts:Bool = true;
	public var noFail:Bool = false;
	public var useEpic:Bool = true;
	public var attemptToAdjust:Bool = false;
	// appearance
	public var useNotesplashes:Bool = true;
	public var backTrans:Float = 0;
	public var downScroll:Bool = false;
	public var middleScroll:Bool = false;
	public var picoCamshake:Bool = true;
	public var senpaiShaderStrength:Int = 2;
	public var oldMenus:Bool = false;
	public var oldTitle:Bool = false;
	public var camFollowsAnims:Bool = false;
	public var showCounters:Bool = true;
	public var staticCam:Int = 0;
	public var noteSkin:String = 'default';
	public var smJudges:Bool = false;
	public var judgeX:Float = 0;
	public var judgeY:Float = 0;
	public var holdsBehindReceptors:Bool = false;
	public var fastTransitions:Bool = false;

	// performance
	public var fps:Int = 120;
	public var noChars:Bool = false;
	public var noStage:Bool = false;
	public var allowOrderSorting:Bool = true;
	public var recycleComboJudges:Bool = false;
	public var antialiasing:Bool = true;
	public var shouldCache:Bool = false;
	public var cacheCharacters:Bool = false;
	public var cacheSongs:Bool = false;
	public var cacheSounds:Bool = false;
	public var cachePreload:Bool = false;
	public var cacheUsedImages:Bool = false;
	public var raymarcher:Bool = true;
	// preference
	public var hitsoundType:Int = 0;
	public var showMem:Bool = true;
	public var showMemPeak:Bool = true;
	public var showFPS:Bool = false;
	public var showMS:Bool = false;
	public var onlyScore:Bool = false;
	public var smoothHPBar:Bool = false;
	public var showComboCounter:Bool = true;
	public var showRatings:Bool = true;
	public var hitsoundVol:Float = 50;
	public var ratingInHUD:Bool = false;
	public var ratingOverNotes:Bool = false;
	public var menuFlash:Bool = true;
	public var freeplayPreview:Bool = false;

	// charter
	public var bfHitsounds:Bool=false;
	public var dadHitsounds:Bool=false;
	public var sectionPreview:Bool=true;
	public var chartingBotplay:Bool=false;
	public var chartingDetails:Bool=true;
	public var chartingNoModshart:Bool = false;

	public function loadOptions(){
		OptionUtils.loadOptions(this);
	}

	public function clone(){
		var optionClone = new Options();
		for(f in Reflect.fields(this)){
			Reflect.setField(optionClone,f,Reflect.field(this,f));
		}
		return optionClone;
	}

	public function saveOptions(){
		OptionUtils.saveOptions(this);
	}

	public function new(){
	}
}
class StateOption extends Option
{
	private var state:FlxState;
	public function new(name:String,state:FlxState){
		super();
		this.state=state;
		this.name=name;
	}
	public override function accept(){
		FlxG.switchState(state);
		return false;
	}
}

class OptionCheckbox extends FlxSprite
{
	public var state:Bool=false;
	public var tracker:FlxSprite;
	public function new(state:Bool){
		super();
		this.state=state;
		frames = Paths.getSparrowAtlas("checkbox");
		updateHitbox();
		animation.addByIndices("unselected","confirm",[0],"",36,false);
		animation.addByPrefix("selecting","confirm",36,false);
		var reversedindices = []; // man i hate haxe I DONT WANNA DO A TABI CODE :(((
			// PROBABLY A BETTER WAY TO DO THIS
			// I DONT CARE IM BAD AT CODE
		var max = animation.getByName("selecting").frames.copy();
		max.reverse();
		for(i in max){
			reversedindices.push(i-2);
		}
		animation.addByIndices("unselecting","confirm",reversedindices,"",36,false);
		animation.addByIndices("selected","confirm",[animation.getByName("selecting").frames.length-2],"",36,false);
		antialiasing=true;
		setGraphicSize(Std.int(width*.6) );
		updateHitbox();
		if(state)
			animation.play("selected");
		else
			animation.play("unselected");

	}

	public function changeState(state:Bool){
		this.state=state;
		if(state){
			animation.play("selecting",true,false,animation.curAnim.name=='unselecting'?animation.curAnim.frames.length-animation.curAnim.curFrame:0);
		}else{
			animation.play("unselecting",true,false,animation.curAnim.name=='selecting'?animation.curAnim.frames.length-animation.curAnim.curFrame:0);
		}
	}

	override function update(elapsed:Float){
		super.update(elapsed);
		if(tracker!=null){
			x = tracker.x - 140;
			y = tracker.y - 45;
		}
		if(animation.curAnim!=null){

			if(animation.curAnim.finished && (animation.curAnim.name=="selecting" || animation.curAnim.name=="unselecting")){
				if(state){
					trace("SELECTED");
					animation.play("selected",true);
				}else{
					trace("UNSELECTED");
					animation.play("unselected",true);
				}
			}

			switch(animation.curAnim.name){
				case 'selecting' | 'unselecting':
					//offset.x=18;
					//offset.y=70;
					offset.x=0;
					offset.y=0;
				case 'unselected':
					//offset.x=0;
					//offset.y=0;
					offset.x=0;
					offset.y=0;
				case 'selected':
					//offset.x=10;
					//offset.y=49.7;
					offset.x=0;
					offset.y=0;
			}
		}

	}
}

class ToggleOption extends Option
{
	private var property = "dummy";
	private var checkbox:OptionCheckbox;
	private var callback:Bool->Void;

	public function new(property:String,?name:String,?description:String='',?callback:Bool->Void){
		super();
		this.property = property;
		this.name = name;
		this.callback=callback;
		this.description=description;
		checkbox = new OptionCheckbox(Reflect.field(OptionUtils.options,property));
		add(checkbox);
	}

	public override function createOptionText(curSelected:Int,optionText:FlxTypedGroup<Option>):Dynamic{
    remove(text);
    text = new Alphabet(0, (70 * curSelected) + 30, name, true, false);
    text.movementType = "list";
    text.isMenuItem = true;
		text.offsetX = 145;
		text.gotoTargetPosition();
		checkbox.tracker = text;
    add(text);
    return text;
  }

	public override function accept():Bool{
		Reflect.setField(OptionUtils.options,property,!Reflect.field(OptionUtils.options,property));
		checkbox.changeState(Reflect.field(OptionUtils.options,property));
		if(callback!=null){
			callback(Reflect.field(OptionUtils.options,property) );
		}
		return false;
	}
}

//StepOption("backTrans","Background Transparency",10,0,100,"%", "", "How transparent the background is")
class StepOption extends Option
{
	private var names:Array<String>;
	private var property = "dummyInt";
	private var max:Float = -1;
	private var min:Float = 0;
	private var step:Float = 1;
	private var label:String = '';
	private var leftArrow:FlxSprite;
	private var rightArrow:FlxSprite;
	private var labelAlphabet:Alphabet;
	private var callback:Float->Float->Void;
	private var suffix:String='';
	private var prefix:String='';
	private var truncFloat:Bool = false;

	public function new(property:String,label:String,?step:Float=1,?min:Float=0,?max:Float=100,?suffix:String='',?prefix:String='',?desc:String='',?truncateFloat=false, ?callback:Float->Float->Void){
		super();
		this.property=property;
		this.label=label;
		this.description=desc;
		this.step=step;
		this.suffix=suffix;
		this.prefix=prefix;
		this.callback=callback;
		var value = Reflect.field(OptionUtils.options,property);
		leftArrow = new FlxSprite(0,0);
		leftArrow.frames = Paths.getSparrowAtlas("arrows");
		leftArrow.setGraphicSize(Std.int(leftArrow.width*.7));
		leftArrow.updateHitbox();
		leftArrow.animation.addByPrefix("pressed","arrow push left",24,false);
		leftArrow.animation.addByPrefix("static","arrow left",24,false);
		leftArrow.animation.play("static");

		rightArrow = new FlxSprite(0,0);
		rightArrow.frames = Paths.getSparrowAtlas("arrows");
		rightArrow.setGraphicSize(Std.int(rightArrow.width*.7));
		rightArrow.updateHitbox();
		rightArrow.animation.addByPrefix("pressed","arrow push right",24,false);
		rightArrow.animation.addByPrefix("static","arrow right",24,false);
		rightArrow.animation.play("static");

		add(rightArrow);
		add(leftArrow);
		this.max=max;
		this.min=min;

		truncFloat=truncateFloat;
		if(truncFloat)
			value=CoolUtil.truncateFloat(value,2);

		name = '${prefix}${Std.string(value)}${suffix}';
	};

	override function update(elapsed:Float){
		labelAlphabet.targetY = text.targetY;
		labelAlphabet.alpha = text.alpha;
		leftArrow.alpha = text.alpha;
		rightArrow.alpha = text.alpha;

		super.update(elapsed);
		//sprTracker.x + sprTracker.width + 10
		if(PlayerSettings.player1.controls.LEFT && isSelected){
			leftArrow.animation.play("pressed");
			leftArrow.offset.x = 0;
			leftArrow.offset.y = -3;
		}else{
			leftArrow.animation.play("static");
			leftArrow.offset.x = 0;
			leftArrow.offset.y = 0;
		}

		if(PlayerSettings.player1.controls.RIGHT && isSelected){
			rightArrow.animation.play("pressed");
			rightArrow.offset.x = 0;
			rightArrow.offset.y = -3;
		}else{
			rightArrow.animation.play("static");
			rightArrow.offset.x = 0;
			rightArrow.offset.y = 0;
		}
		rightArrow.x = text.x+text.width+10;
		leftArrow.x = text.x-60;
		leftArrow.y = text.y-10;
		rightArrow.y = text.y-10;
	}

	public override function createOptionText(curSelected:Int,optionText:FlxTypedGroup<Option>):Dynamic{
    remove(text);
		remove(labelAlphabet);
		labelAlphabet = new Alphabet(0, (70 * curSelected) + 30, label, true, false);
		labelAlphabet.movementType = "list";
		labelAlphabet.isMenuItem = true;
		labelAlphabet.offsetX = 60;

    text = new Alphabet(0, (70 * curSelected) + 30, name, true, false);
    text.movementType = "list";
    text.isMenuItem = true;
		text.offsetX = labelAlphabet.width + 120;

		labelAlphabet.targetY = text.targetY;
		labelAlphabet.gotoTargetPosition();
		text.gotoTargetPosition();
		add(labelAlphabet);
    add(text);
    return text;
  }

	public override function left():Bool{
		var value:Float = Reflect.field(OptionUtils.options,property)-step;

		if(value<min)
			value=max;

		if(value>max)
			value=min;

		Reflect.setField(OptionUtils.options,property,value);

		if(truncFloat)
			value=CoolUtil.truncateFloat(value,2);
		name = '${prefix}${Std.string(value)}${suffix}';
		if(callback!=null)
			callback(value,-step);

		return true;
	};
	public override function right():Bool{
		var value:Float = Reflect.field(OptionUtils.options,property)+step;

		if(value<min)
			value=max;
		if(value>max)
			value=min;

		Reflect.setField(OptionUtils.options,property,value);

		if(truncFloat)
			value=CoolUtil.truncateFloat(value,2);
		name = '${prefix}${Std.string(value)}${suffix}';
		if(callback!=null)
			callback(value,step);

		return true;
	};
}

class ScrollOption extends Option
{
	private var names:Array<String>;
	private var property = "dummyInt";
	private var max:Int = -1;
	private var min:Int = 0;
	private var label:String = '';
	private var leftArrow:FlxSprite;
	private var rightArrow:FlxSprite;
	private var labelAlphabet:Alphabet;
	private var callback:Int->String->Int->Void;
	// i wish there was a better way to do this ^
	// if there is and you're reading this and know a better way, PR please!

	public function new(property:String,label:String,description:String,?min:Int=0,?max:Int=-1,?names:Array<String>,?callback:Int->String->Int->Void){
		super();
		this.property=property;
		this.label=label;
		this.description=description;
		this.names=names;
		this.callback=callback;
		var value = Reflect.field(OptionUtils.options,property);
		leftArrow = new FlxSprite(0,0);
		leftArrow.frames = Paths.getSparrowAtlas("arrows");
		leftArrow.setGraphicSize(Std.int(leftArrow.width*.7));
		leftArrow.updateHitbox();
		leftArrow.animation.addByPrefix("pressed","arrow push left",24,false);
		leftArrow.animation.addByPrefix("static","arrow left",24,false);
		leftArrow.animation.play("static");

		rightArrow = new FlxSprite(0,0);
		rightArrow.frames = Paths.getSparrowAtlas("arrows");
		rightArrow.setGraphicSize(Std.int(rightArrow.width*.7));
		rightArrow.updateHitbox();
		rightArrow.animation.addByPrefix("pressed","arrow push right",24,false);
		rightArrow.animation.addByPrefix("static","arrow right",24,false);
		rightArrow.animation.play("static");

		add(rightArrow);
		add(leftArrow);
		this.max=max;
		this.min=min;
		if(names!=null){
			name = names[value];
		}else{
			name = Std.string(value);
		}
	};

	override function update(elapsed:Float){
		labelAlphabet.targetY = text.targetY;
		labelAlphabet.alpha = text.alpha;
		leftArrow.alpha = text.alpha;
		rightArrow.alpha = text.alpha;
		super.update(elapsed);
		//sprTracker.x + sprTracker.width + 10
		if(PlayerSettings.player1.controls.LEFT && isSelected){
			leftArrow.animation.play("pressed");
			leftArrow.offset.x = 0;
			leftArrow.offset.y = -3;
		}else{
			leftArrow.animation.play("static");
			leftArrow.offset.x = 0;
			leftArrow.offset.y = 0;
		}

		if(PlayerSettings.player1.controls.RIGHT && isSelected){
			rightArrow.animation.play("pressed");
			rightArrow.offset.x = 0;
			rightArrow.offset.y = -3;
		}else{
			rightArrow.animation.play("static");
			rightArrow.offset.x = 0;
			rightArrow.offset.y = 0;
		}
		rightArrow.x = text.x+text.width+10;
		leftArrow.x = text.x-60;
		leftArrow.y = text.y-10;
		rightArrow.y = text.y-10;
	}

	public override function createOptionText(curSelected:Int,optionText:FlxTypedGroup<Option>):Dynamic{
    remove(text);
		remove(labelAlphabet);
		labelAlphabet = new Alphabet(0, (70 * curSelected) + 30, label, true, false);
		labelAlphabet.movementType = "list";
		labelAlphabet.isMenuItem = true;
		labelAlphabet.offsetX = 60;

    text = new Alphabet(0, (70 * curSelected) + 30, name, true, false);
    text.movementType = "list";
    text.isMenuItem = true;
		text.offsetX = labelAlphabet.width + 120;

		labelAlphabet.targetY = text.targetY;
		labelAlphabet.gotoTargetPosition();
		text.gotoTargetPosition();
		add(labelAlphabet);
    add(text);
    return text;
  }

	public override function left():Bool{
		var value:Int = Std.int(Reflect.field(OptionUtils.options,property)-1);

		if(value<min)
			value=max;

		if(value>max)
			value=min;

		Reflect.setField(OptionUtils.options,property,value);

		if(names!=null){
			name = names[value];
		}else{
			name = Std.string(value);
		}

		if(callback!=null){
			callback(value,name,-1);
		}
		return true;
	};
	public override function right():Bool{
		var value:Int = Std.int(Reflect.field(OptionUtils.options,property)+1);

		if(value<min)
			value=max;
		if(value>max)
			value=min;

		Reflect.setField(OptionUtils.options,property,value);

		if(names!=null){
			name = names[value];
		}else{
			name = Std.string(value);
		}

		if(callback!=null){
			callback(value,name,1);
		}
		return true;
	};
}

class JudgementsOption extends Option
{
	private var names:Array<String>;
	private var property = "dummyInt";
	private var label:String = '';
	private var leftArrow:FlxSprite;
	private var rightArrow:FlxSprite;
	private var labelAlphabet:Alphabet;
	private var judgementNames:Array<String> = [];
	private var curValue:Int = 0;
	public function new(property:String,label:String,description:String){
		super();
		this.property=property;
		this.label=label;
		this.description=description;
		var idx=0;

		var judgementOrder = CoolUtil.coolTextFile(Paths.txt('judgementOrder'));

		for (i in 0...judgementOrder.length)
		{
			var judge = judgementOrder[i];
			judgementNames.push(judge);
			if(Reflect.field(OptionUtils.options,property)==judge){
				curValue=idx;
			}
			idx++;
		}

		for(judgement in Reflect.fields(JudgementManager.rawJudgements)){
			if(!judgementNames.contains(judgement)){
				judgementNames.push(judgement);
				if(Reflect.field(OptionUtils.options,property)==judgement){
					curValue=idx;
				}
				idx++;
			}
		}

		leftArrow = new FlxSprite(0,0);
		leftArrow.frames = Paths.getSparrowAtlas("arrows");
		leftArrow.setGraphicSize(Std.int(leftArrow.width*.7));
		leftArrow.updateHitbox();
		leftArrow.animation.addByPrefix("pressed","arrow push left",24,false);
		leftArrow.animation.addByPrefix("static","arrow left",24,false);
		leftArrow.animation.play("static");

		rightArrow = new FlxSprite(0,0);
		rightArrow.frames = Paths.getSparrowAtlas("arrows");
		rightArrow.setGraphicSize(Std.int(rightArrow.width*.7));
		rightArrow.updateHitbox();
		rightArrow.animation.addByPrefix("pressed","arrow push right",24,false);
		rightArrow.animation.addByPrefix("static","arrow right",24,false);
		rightArrow.animation.play("static");

		add(rightArrow);
		add(leftArrow);

		name = judgementNames[curValue];
	};

	override function update(elapsed:Float){
		labelAlphabet.targetY = text.targetY;
		labelAlphabet.alpha = text.alpha;
		leftArrow.alpha = text.alpha;
		rightArrow.alpha = text.alpha;
		super.update(elapsed);
		//sprTracker.x + sprTracker.width + 10
		if(PlayerSettings.player1.controls.LEFT && isSelected){
			leftArrow.animation.play("pressed");
			leftArrow.offset.x = 0;
			leftArrow.offset.y = -3;
		}else{
			leftArrow.animation.play("static");
			leftArrow.offset.x = 0;
			leftArrow.offset.y = 0;
		}

		if(PlayerSettings.player1.controls.RIGHT && isSelected){
			rightArrow.animation.play("pressed");
			rightArrow.offset.x = 0;
			rightArrow.offset.y = -3;
		}else{
			rightArrow.animation.play("static");
			rightArrow.offset.x = 0;
			rightArrow.offset.y = 0;
		}
		rightArrow.x = text.x+text.width+10;
		leftArrow.x = text.x-60;
		leftArrow.y = text.y-10;
		rightArrow.y = text.y-10;
	}

	public override function createOptionText(curSelected:Int,optionText:FlxTypedGroup<Option>):Dynamic{
    remove(text);
		remove(labelAlphabet);
		labelAlphabet = new Alphabet(0, (70 * curSelected) + 30, label, true, false);
		labelAlphabet.movementType = "list";
		labelAlphabet.isMenuItem = true;
		labelAlphabet.offsetX = 60;

    text = new Alphabet(0, (70 * curSelected) + 30, name, true, false);
    text.movementType = "list";
    text.isMenuItem = true;
		text.offsetX = labelAlphabet.width + 120;

		labelAlphabet.targetY = text.targetY;
		labelAlphabet.gotoTargetPosition();
		text.gotoTargetPosition();
		add(labelAlphabet);
    add(text);
    return text;
  }

	public override function left():Bool{
		var value:Int = curValue-1;

		if(value<0)
			value=judgementNames.length-1;

		if(value>judgementNames.length-1)
			value=0;

		Reflect.setField(OptionUtils.options,property,judgementNames[value]);

		curValue=value;
		name = judgementNames[value];
		return true;
	};
	public override function right():Bool{
		var value:Int = curValue+1;

		if(value<0)
			value=judgementNames.length-1;

		if(value>judgementNames.length-1)
			value=0;

		Reflect.setField(OptionUtils.options,property,judgementNames[value]);

		curValue=value;
		name = judgementNames[value];
		return true;
	};
}

class NoteskinOption extends Option
{
	private var names:Array<String>;
	private var property = "dummyInt";
	private var label:String = '';
	private var leftArrow:FlxSprite;
	private var rightArrow:FlxSprite;
	private var labelAlphabet:Alphabet;
	private var skinNames:Array<String> = [];
	private var curValue:Int = 0;
	private var defaultDesc:String = '';
	function updateDescription(){
		description = '${defaultDesc}.\nSkin description: ${Note.skinManifest.get(skinNames[curValue]).desc}';
	}
	public function new(property:String,label:String,description:String){
		super();
		this.property=property;
		this.label=label;
		this.defaultDesc=description;
		var idx=0;

		var noteskinOrder = CoolUtil.coolTextFile(Paths.txtImages('skins/noteskinOrder'));

		for (i in 0...noteskinOrder.length)
		{
			var skin = noteskinOrder[i];
			if(OptionUtils.noteSkins.contains(skin) && skin!='fallback')
				skinNames.push(skin);
		}

		for(skin in OptionUtils.noteSkins){
			if(!skinNames.contains(skin) && skin!='fallback'){
				skinNames.push(skin);
			}
		}

		var idx = skinNames.indexOf(Reflect.field(OptionUtils.options,property));
		curValue = idx==-1?0:idx;
		updateDescription();

		leftArrow = new FlxSprite(0,0);
		leftArrow.frames = Paths.getSparrowAtlas("arrows");
		leftArrow.setGraphicSize(Std.int(leftArrow.width*.7));
		leftArrow.updateHitbox();
		leftArrow.animation.addByPrefix("pressed","arrow push left",24,false);
		leftArrow.animation.addByPrefix("static","arrow left",24,false);
		leftArrow.animation.play("static");

		rightArrow = new FlxSprite(0,0);
		rightArrow.frames = Paths.getSparrowAtlas("arrows");
		rightArrow.setGraphicSize(Std.int(rightArrow.width*.7));
		rightArrow.updateHitbox();
		rightArrow.animation.addByPrefix("pressed","arrow push right",24,false);
		rightArrow.animation.addByPrefix("static","arrow right",24,false);
		rightArrow.animation.play("static");

		add(rightArrow);
		add(leftArrow);

		name = Note.skinManifest.get(skinNames[curValue]).name;
	};

	override function update(elapsed:Float){
		labelAlphabet.targetY = text.targetY;
		labelAlphabet.alpha = text.alpha;
		leftArrow.alpha = text.alpha;
		rightArrow.alpha = text.alpha;
		super.update(elapsed);
		//sprTracker.x + sprTracker.width + 10
		if(PlayerSettings.player1.controls.LEFT && isSelected){
			leftArrow.animation.play("pressed");
			leftArrow.offset.x = 0;
			leftArrow.offset.y = -3;
		}else{
			leftArrow.animation.play("static");
			leftArrow.offset.x = 0;
			leftArrow.offset.y = 0;
		}

		if(PlayerSettings.player1.controls.RIGHT && isSelected){
			rightArrow.animation.play("pressed");
			rightArrow.offset.x = 0;
			rightArrow.offset.y = -3;
		}else{
			rightArrow.animation.play("static");
			rightArrow.offset.x = 0;
			rightArrow.offset.y = 0;
		}
		rightArrow.x = text.x+text.width+10;
		leftArrow.x = text.x-60;
		leftArrow.y = text.y-10;
		rightArrow.y = text.y-10;
	}

	public override function createOptionText(curSelected:Int,optionText:FlxTypedGroup<Option>):Dynamic{
    remove(text);
		remove(labelAlphabet);
		labelAlphabet = new Alphabet(0, (70 * curSelected) + 30, label, true, false);
		labelAlphabet.movementType = "list";
		labelAlphabet.isMenuItem = true;
		labelAlphabet.offsetX = 60;

    text = new Alphabet(0, (70 * curSelected) + 30, name, true, false);
    text.movementType = "list";
    text.isMenuItem = true;
		text.offsetX = labelAlphabet.width + 120;

		labelAlphabet.targetY = text.targetY;
		labelAlphabet.gotoTargetPosition();
		text.gotoTargetPosition();
		add(labelAlphabet);
    add(text);
    return text;
  }

	public override function left():Bool{
		var value:Int = curValue-1;

		if(value<0)
			value=skinNames.length-1;

		if(value>skinNames.length-1)
			value=0;

		Reflect.setField(OptionUtils.options,property,skinNames[value]);

		curValue=value;
		name = Note.skinManifest.get(skinNames[value]).name;
		updateDescription();
		return true;
	};
	public override function right():Bool{
		var value:Int = curValue+1;

		if(value<0)
			value=skinNames.length-1;

		if(value>skinNames.length-1)
			value=0;

		Reflect.setField(OptionUtils.options,property,skinNames[value]);

		curValue=value;
		name = Note.skinManifest.get(skinNames[value]).name;
		updateDescription();
		return true;
	};
}

class CountOption extends Option
{
	private var prefix:String='';
	private var suffix:String='';
	private var property = "dummyInt";
	private var max:Int = -1;
	private var min:Int = 0;
	public function new(property:String,?min:Int=0,?max:Int=-1,?prefix:String='',?suffix:String=''){
		super();
		this.property=property;
		this.min=min;
		this.max=max;
		var value = Reflect.field(OptionUtils.options,property);
		this.prefix=prefix;
		this.suffix=suffix;

		name = prefix + " " + Std.string(value) + " " + suffix;
	};

	public override function left():Bool{
		var value:Int = Std.int(Reflect.field(OptionUtils.options,property)-1);

		if(value<min)
			value=max;
		if(value>max)
			value=min;

		Reflect.setField(OptionUtils.options,property,value);
		name = prefix + " " + Std.string(value) + " " + suffix;
		return true;
	};
	public override function right():Bool{
		var value:Int = Std.int(Reflect.field(OptionUtils.options,property)+1);



		if(value<min)
			value=max;
		if(value>max)
			value=min;

		Reflect.setField(OptionUtils.options,property,value);

		name = prefix + " " + Std.string(value) + " " + suffix;
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
		name='${controlType} : ${OptionUtils.getKey(controlType).toString()}';
	};

	public override function keyPressed(pressed:FlxKey){
		//FlxKey.fromString(String.fromCharCode(event.charCode));
		for(k in OptionUtils.shit){
			if(pressed==k){
				pressed=-1;
				break;
			};
		};
		if(pressed!=BACKSPACE){
			OptionUtils.options.controls[OptionUtils.getKIdx(controlType)]=pressed;
			key=pressed;
		}
		name='${controlType} : ${OptionUtils.getKey(controlType).toString()}';
		if(pressed!=-1){
			trace("epic style " + pressed.toString() );
			controls.setKeyboardScheme(Custom,true);
			allowMultiKeyInput=false;
			return true;
		}
		return true;
	}

	public override function createOptionText(curSelected:Int,optionText:FlxTypedGroup<Option>):Dynamic{
    remove(text);
    text = new Alphabet(0, (70 * curSelected) + 30, name, false, false);
    text.movementType = "list";
		text.offsetX = 50;
    text.isMenuItem = true;
		text.gotoTargetPosition();
    add(text);
    return text;
  }

	public override function accept():Bool{
		controls.setKeyboardScheme(None,true);
		allowMultiKeyInput=true;
		//FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		name = "<Press any key to rebind>";
		return true;
	};
}
