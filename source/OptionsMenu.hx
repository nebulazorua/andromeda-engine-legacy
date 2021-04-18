package;

import Controls.Control;
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
import Controls.Control;
import Options;
#if desktop
import Discord.DiscordClient;
#end
class OptionsMenu extends MusicBeatState
{
	private var defCat:OptionCategory = new OptionCategory("Default",[
		new OptionCategory("Test",[
			new ControlOption(Control.LEFT),
			new ControlOption(Control.DOWN),
			new ControlOption(Control.UP),
			new ControlOption(Control.RIGHT)
		]),
		new OptionCategory("Cock And Ball Torture",[
			new Option("Cock"),
			new Option("And"),
			new Option("Ball"),
			new Option("Torture"),
			new OptionCategory("Nested Categories",[
				new OptionCategory("Are epic",[
					new Option("Cum")
				])
			])
		])
	]);

	private var optionText:FlxTypedGroup<Alphabet>;
	private var curSelected:Int = 0;
	private var category:Dynamic;

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
		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;
		var rightP = controls.RIGHT_P;

		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			if(category!=defCat){
				category.curSelected=0;
				category=category.parent;
				refresh();
			}else{
				FlxG.switchState(new MainMenuState());
			}
		}
		var option = category.options[curSelected];
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

		super.update(elapsed);

	}

}
