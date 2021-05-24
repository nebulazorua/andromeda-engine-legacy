package;

import Controls.Control;
import Controls.KeyboardScheme;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.addons.transition.FlxTransitionableState;
import Options;
#if desktop
import Discord.DiscordClient;
#end
class OptionsMenu extends MusicBeatState
{
	private var defCat:OptionCategory = new OptionCategory("Default",[
		new OptionCategory("Input",[
			new OptionCategory("Controls",[
				new ControlOption(controls,Control.LEFT),
				new ControlOption(controls,Control.DOWN),
				new ControlOption(controls,Control.UP),
				new ControlOption(controls,Control.RIGHT)
			]),
			new ToggleOption("missForNothing","Kade missing","Vanilla missing"),
		]),
		new OptionCategory("Gameplay",[
			new ToggleOption("loadModcharts","Don't load Lua modcharts","Load Lua modcharts"),
			new ToggleOption("pauseHoldAnims","Vanilla holds","Holds pause on first frame")
		])
	]);

	private var optionText:FlxTypedGroup<Alphabet>;
	private var curSelected:Int = 0;
	public static var category:Dynamic;

	override function create()
	{

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Changing options", null);
		#end
		category=defCat;
		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menuDesat"));

		menuBG.color = 0xFFa271de;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		optionText = new FlxTypedGroup<Alphabet>();
		add(optionText);

		refresh();

		super.create();
	}

	function refresh(){
		curSelected = category.curSelected;
		optionText.clear();
		for (i in 0...category.options.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, category.options[i].name, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			optionText.add(songText);
		}

		changeSelection(0);
	}

	function changeSelection(?diff:Int=0){
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		curSelected += diff;

		if (curSelected < 0)
			curSelected = Std.int(category.options.length) - 1;
		if (curSelected >= Std.int(category.options.length))
			curSelected = 0;


		for (i in 0...optionText.length)
		{
			var item = optionText.members[i];
			item.targetY = i-curSelected;
			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}

		category.curSelected = curSelected;
	}

	override function update(elapsed:Float)
	{
		var upP = false;
		var downP = false;
		var leftP = false;
		var rightP = false;
		var accepted = false;
		var back = false;
		if(controls.keyboardScheme!=None){
			upP = controls.UP_P;
			downP = controls.DOWN_P;
			leftP = controls.LEFT_P;
			rightP = controls.RIGHT_P;

			accepted = controls.ACCEPT;
			back = controls.BACK;
		}

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		var option = category.options[curSelected];

		if (back)
		{
			if(category!=defCat){
				category.curSelected=0;
				category=category.parent;
				refresh();
			}else{
				FlxG.switchState(new MainMenuState());
			}
		}
		if(option.type!="Category"){
			if(leftP){
				if(option.left()) {
					optionText.remove(optionText.members[curSelected]);
					var songText:Alphabet = new Alphabet(0, (70 * curSelected) + 30, option.name, true, false);
					songText.isMenuItem = true;
					optionText.add(songText);
					changeSelection();
				}
			}
			if(rightP){
				if(option.right()) {
					optionText.remove(optionText.members[curSelected]);
					var songText:Alphabet = new Alphabet(0, (70 * curSelected) + 30, option.name, true, false);
					songText.isMenuItem = true;
					optionText.add(songText);
					changeSelection();
				}
			}
		}

		if(option.allowMultiKeyInput){
			var pressed = FlxG.keys.firstJustPressed();
			var released = FlxG.keys.firstJustReleased();
			if(pressed!=-1){
				if(option.keyPressed(pressed)){
					optionText.remove(optionText.members[curSelected]);
					var songText:Alphabet = new Alphabet(0, (70 * curSelected) + 30, option.name, true, false);
					songText.isMenuItem = true;
					optionText.add(songText);
					changeSelection();
				}
			}
			if(released!=-1){
				if(option.keyReleased(released)){
					optionText.remove(optionText.members[curSelected]);
					var songText:Alphabet = new Alphabet(0, (70 * curSelected) + 30, option.name, true, false);
					songText.isMenuItem = true;
					optionText.add(songText);
					changeSelection();
				}
			}
		}

		if(accepted){
			if(option.type=='Category'){
				category=option;
				refresh();
			}else if(option.accept()) {
				optionText.remove(optionText.members[curSelected]);
				var songText:Alphabet = new Alphabet(0, (70 * curSelected) + 30, option.name, true, false);
				songText.isMenuItem = true;

				optionText.add(songText);
			}
			changeSelection();
		}



		if(option.forceupdate){
			option.forceupdate=false;
			optionText.remove(optionText.members[curSelected]);
			var songText:Alphabet = new Alphabet(0, (70 * curSelected) + 30, option.name, true, false);
			songText.isMenuItem = true;

			optionText.add(songText);
			changeSelection();
		}
		super.update(elapsed);

	}

}
