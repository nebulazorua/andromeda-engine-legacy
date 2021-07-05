package;
import Controls;
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
	public static var instance:OptionsMenu;
	private var defCat:OptionCategory = new OptionCategory("Default",[
		new OptionCategory("Gameplay",[
			new OptionCategory("Controls",[
				new ControlOption(controls,Control.LEFT),
				new ControlOption(controls,Control.DOWN),
				new ControlOption(controls,Control.UP),
				new ControlOption(controls,Control.RIGHT),
				new ControlOption(controls,Control.RESET),
			]),
			new OptionCategory("Modifiers",[
				new ToggleOption("failForMissing","Sudden Death"),
			]),
			new ScrollOption("ratingWindow",0,OptionUtils.ratingWindowNames.length-1,OptionUtils.ratingWindowNames),
			new ToggleOption("ghosttapping","Ghost-tapping"),
			new StateOption("Calibrate Offset",new SoundOffsetState()),
		]),
		new OptionCategory("Modification",[
			new ToggleOption("loadModcharts","Load Lua modcharts"),
		]),
		new OptionCategory("Preferences",[
			new ToggleOption("pauseHoldAnims","Holds pause anims"),
			//new ScrollOption("holdBehaviour",0,1,["Holds pause anims","Holds repeat anims"]),
			new ToggleOption("showMS","Hit MS"),
			new ToggleOption("ratingInHUD","Ratings in HUD"),
			new ToggleOption("downScroll","Downscroll"),
			new ToggleOption("middleScroll","Middlescroll"),
			new ToggleOption("menuFlash","Flashing in menus"),
			new ToggleOption("newInput","New Input"),
			new OptionCategory("Effects",[
				new ToggleOption("picoShaders","Week 3 shaders"),
				new ToggleOption("picoCamshake","Week 3 cam shake"),
				new ToggleOption("senpaiShaders","Week 6 shaders"),
			])
		])
	]);

	private var optionText:FlxTypedGroup<Option>;
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

		optionText = new FlxTypedGroup<Option>();
		add(optionText);

		refresh();

		super.create();
	}

	function refresh(){
		curSelected = category.curSelected;
		optionText.clear();
		for (i in 0...category.options.length)
		{
			optionText.add(category.options[i]);
			var text = category.options[i].createOptionText(curSelected,optionText);
			text.targetY = i;
			text.gotoTargetPosition();
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
			item.text.targetY = i-curSelected;
			item.text.alpha = 0.6;
			var wasSelected = item.isSelected;
			item.isSelected=item.text.targetY==0;
			if (item.isSelected)
			{
				item.text.alpha = 1;
				item.selected();
			}else if(wasSelected){
				item.deselected();
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
				trace("save options");
			  OptionUtils.saveOptions(OptionUtils.options);
			}
		}
		if(option.type!="Category"){
			if(leftP){
				if(option.left()) {
					option.createOptionText(curSelected,optionText);
					changeSelection();
				}
			}
			if(rightP){
				if(option.right()) {
					option.createOptionText(curSelected,optionText);
					changeSelection();
				}
			}
		}

		if(option.allowMultiKeyInput){
			var pressed = FlxG.keys.firstJustPressed();
			var released = FlxG.keys.firstJustReleased();
			if(pressed!=-1){
				if(option.keyPressed(pressed)){
					option.createOptionText(curSelected,optionText);
					changeSelection();
				}
			}
			if(released!=-1){
				if(option.keyReleased(released)){
					option.createOptionText(curSelected,optionText);
					changeSelection();
				}
			}
		}

		if(accepted){
			if(option.type=='Category'){
				category=option;
				refresh();
			}else if(option.accept()) {
				option.createOptionText(curSelected,optionText);
			}
			changeSelection();
		}



		if(option.forceupdate){
			option.forceupdate=false;
			//optionText.remove(optionText.members[curSelected]);
			option.createOptionText(curSelected,optionText);
			changeSelection();
		}
		super.update(elapsed);

	}

}
