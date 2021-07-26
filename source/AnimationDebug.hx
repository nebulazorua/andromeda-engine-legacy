package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIGroup;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import openfl.net.FileReference;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
using StringTools;
/**
	*DEBUG MODE
 */
class AnimationDebug extends FlxState
{
	var UI_box:FlxUITabMenu;
	var bf:Boyfriend;
	var dad:Character;
	var char:Character;
	var textAnim:FlxText;
	var dumbTexts:FlxTypedGroup<FlxText>;
	var layeringbullshit:FlxTypedGroup<FlxSprite>;
	var animList:Array<String> = [];
	var curAnim:Int = 0;
	var isDad:Bool = true;
	var daAnim:String = 'spooky';
	var camFollow:FlxObject;
	var camHUD:FlxCamera;
	var camGame:FlxCamera;
	var player:FlxUICheckBox;
	var _file:FileReference;
	var ghostBF:Character;
	private function saveLevel()
	{
		var data:String = '';
		for(anim in animList){
			if(anim!="dischargeScared")
				data+=anim+" "+char.animOffsets.get(anim)[0] + " "+char.animOffsets.get(anim)[1]+"\n";
		}

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), char.curCharacter + "Offsets.txt");
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}

	public function new(daAnim:String = 'spooky')
	{
		super();
		this.daAnim = daAnim;
	}

	override function create()
	{
		FlxG.mouse.visible = true;
		FlxG.sound.music.stop();
		var gridBG:FlxSprite = FlxGridOverlay.create(10, 10);
		gridBG.scrollFactor.set(0, 0);
		add(gridBG);

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camGame = new FlxCamera();

		FlxG.cameras.add(camGame);
		FlxG.cameras.add(camHUD);
		FlxCamera.defaultCameras = [camGame];

		layeringbullshit = new FlxTypedGroup<FlxSprite>();
		add(layeringbullshit);

		UI_box = new FlxUITabMenu(null,[{name:"Character",label:"Character"}],false);
		UI_box.cameras = [camHUD];
		UI_box.resize(300, 200);
		UI_box.x = (FlxG.width / 2) + 250;
		UI_box.y = 20;
		add(UI_box);

		var characterTab = new FlxUI(null, UI_box);
		characterTab.name = "Character";

		var characters:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));

		var cumfart = new FlxUIDropDownMenu(50, 50, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			daAnim=characters[Std.parseInt(character)];
			displayCharacter(daAnim);
		});
		cumfart.selectedLabel = daAnim;

		player = new FlxUICheckBox(175, 50, null, null, "flipX", 100);
		player.checked = false;
		player.callback = function()
		{
			char.flipX=player.checked;
		};

		var saveButton:FlxButton = new FlxButton(100, 125, "Save", function()
		{
			saveLevel();
		});

		characterTab.add(cumfart);
		characterTab.add(player);
		characterTab.add(saveButton);
		UI_box.addGroup(characterTab);
		dumbTexts = new FlxTypedGroup<FlxText>();
		dumbTexts.cameras = [camHUD];
		add(dumbTexts);

		textAnim = new FlxText(300, 16);
		textAnim.size = 26;
		textAnim.scrollFactor.set();
		add(textAnim);

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);
		camGame.follow(camFollow);

		displayCharacter(daAnim);

		super.create();
	}

	function displayCharacter(daAnim:String){
		dumbTexts.forEach(function(text:FlxText)
		{
			dumbTexts.remove(text,true);
		});
		dumbTexts.clear();

		animList=[];

		if (daAnim == 'bf')
			isDad = false;
		else
			isDad = true;

		if(dad!=null)
			layeringbullshit.remove(dad);

		if(bf!=null)
			layeringbullshit.remove(bf);

		if(ghostBF!=null)
			layeringbullshit.remove(ghostBF);

		ghostBF = new Character(0, 0, daAnim);
		ghostBF.alpha = .5;
		ghostBF.screenCenter();
		ghostBF.debugMode = true;

		layeringbullshit.add(ghostBF);

		if (isDad)
		{

			dad = new Character(0, 0, daAnim);
			dad.screenCenter();
			dad.debugMode = true;
			layeringbullshit.add(dad);

			char = dad;
			dad.flipX = player.checked;
		}
		else
		{
			bf = new Boyfriend(0, 0);
			bf.screenCenter();
			bf.debugMode = true;
			layeringbullshit.add(bf);

			char = bf;
			bf.flipX = player.checked;
		}

		genBoyOffsets();

	}

	function genBoyOffsets(pushList:Bool = true):Void
	{
		var daLoop:Int = 0;

		for (anim in char.offsetNames)
		{
			var offsets = char.animOffsets.get(anim);
			var text:FlxText = new FlxText(10, 20 + (18 * daLoop), 0, anim + ": " + offsets, 15);
			text.scrollFactor.set();
			text.color = FlxColor.BLUE;
			dumbTexts.add(text);

			if (pushList)
				animList.push(anim);

			daLoop++;
		}
	}

	function updateTexts():Void
	{
		dumbTexts.forEach(function(text:FlxText)
		{
			text.kill();
			dumbTexts.remove(text, true);
		});
		dumbTexts.clear();

	}

	override function update(elapsed:Float)
	{
		textAnim.text = char.animation.curAnim.name;
		ghostBF.flipX = char.flipX;

		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.mouse.visible = false;
			LoadingState.loadAndSwitchState(new PlayState());
		}

		if (FlxG.keys.justPressed.E)
			camGame.zoom += 0.25;
		if (FlxG.keys.justPressed.Q)
			camGame.zoom -= 0.25;

		if (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L)
		{
			if (FlxG.keys.pressed.I)
				camFollow.velocity.y = -90;
			else if (FlxG.keys.pressed.K)
				camFollow.velocity.y = 90;
			else
				camFollow.velocity.y = 0;

			if (FlxG.keys.pressed.J)
				camFollow.velocity.x = -90;
			else if (FlxG.keys.pressed.L)
				camFollow.velocity.x = 90;
			else
				camFollow.velocity.x = 0;
		}
		else
		{
			camFollow.velocity.set();
		}

		if (FlxG.keys.justPressed.W)
		{
			curAnim -= 1;
		}

		if (FlxG.keys.justPressed.S)
		{
			curAnim += 1;
		}

		if (curAnim < 0)
			curAnim = animList.length - 1;

		if (curAnim >= animList.length)
			curAnim = 0;

		if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.W || FlxG.keys.justPressed.SPACE)
		{
			char.playAnim(animList[curAnim]);
			ghostBF.playAnim(animList[0]);
			updateTexts();
			genBoyOffsets(false);
		}

		var upP = FlxG.keys.anyJustPressed([UP]);
		var rightP = FlxG.keys.anyJustPressed([RIGHT]);
		var downP = FlxG.keys.anyJustPressed([DOWN]);
		var leftP = FlxG.keys.anyJustPressed([LEFT]);

		var holdShift = FlxG.keys.pressed.SHIFT;
		var multiplier = 1;
		if (holdShift)
			multiplier = 10;

		if (upP || rightP || downP || leftP)
		{
			updateTexts();
			if (upP)
				char.animOffsets.get(animList[curAnim])[1] += 1 * multiplier;
			if (downP)
				char.animOffsets.get(animList[curAnim])[1] -= 1 * multiplier;
			if (leftP)
				char.animOffsets.get(animList[curAnim])[0] += 1 * multiplier;
			if (rightP)
				char.animOffsets.get(animList[curAnim])[0] -= 1 * multiplier;

			updateTexts();
			genBoyOffsets(false);
			char.playAnim(animList[curAnim]);
			ghostBF.playAnim(animList[0]);
		}

		super.update(elapsed);
	}
}
