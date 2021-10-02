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
import flixel.graphics.FlxGraphic;

#if desktop
import Discord.DiscordClient;
#end
class OptionsState extends MusicBeatState
{

	public static var instance:OptionsState;
	private var defCat:OptionCategory = new OptionCategory("Default",[
		new OptionCategory("Gameplay",[
			new OptionCategory("Controls",[
				new ControlOption(controls,Control.LEFT),
				new ControlOption(controls,Control.DOWN),
				new ControlOption(controls,Control.UP),
				new ControlOption(controls,Control.RIGHT),
				new ControlOption(controls,Control.PAUSE),
				new ControlOption(controls,Control.RESET),
			]),
			new ToggleOption("resetKey","Reset key","Should pressing the bound reset key instantly kill you"),
			#if windows
			new ToggleOption("loadModcharts","Load Lua modcharts","Should modcharts which run using lua load"),
			#end
			new ToggleOption("ghosttapping","Ghost-tapping","Missing when you hit nothing"),
			new ToggleOption("botPlay","BotPlay","Let a bot play for you"),
			new ToggleOption("failForMissing","Sudden Death"),
			new OptionCategory("Advanced",[
			new JudgementsOption("judgementWindow","Judgements","Which judgement window to use"),
				new ToggleOption("pollingInput","Old input","Should inputs get checked every frame"),
				new ToggleOption("useMalewife","Use Wife3","Should accuracy use Wife3"),
				// TODO: CMod and XMod

			]),
			//new StateOption("Calibrate Offset",new SoundOffsetState()),
			// TODO: make a better 'calibrate offset'
		]),
		new OptionCategory("Appearance",[
			//new ToggleOption("camFollowsAnims","Directional Camera","Does the camera follow animations"),
			new ToggleOption("downScroll","Downscroll","Do arrows come from the top coming down"),
			new ToggleOption("middleScroll","Centered Notefield","Are arrows placed in the middle of the screen"),
			new ToggleOption("allowNoteModifiers","Allow note modifiers","Should note modifiers be loaded? (Eg. pixel notes)"),
			new StepOption("backTrans","BG Transparency",10,0,100,"%","","How transparent the background is"),
			new ToggleOption("oldMenus","Old Menus","Use the vanilla menus"),
			new ToggleOption("oldTitle","Old Title Screen","Use the vanilla titlescreen"),
			new ToggleOption("healthBarColors","Healthbar Colours","Should the healthbar colours change with the character"),
			new OptionCategory("Effects",[
				new ToggleOption("picoShaders","Week 3 shaders","Does the windows fading out in week 3 use shaders"),
				new ToggleOption("picoCamshake","Week 3 cam shake","Does the train cause a camera shake in week 3"),
				new ToggleOption("senpaiShaders","Week 6 shaders","Is the CRT effect active in week 6"),
			]),
		]),
		new OptionCategory("Preferences",[
			new ToggleOption("showComboCounter","Show combo","Ratings show your combo when you hit a note"),
			new ToggleOption("showRatings","Show ratings","Ratings show up when you hit a note"),
			new ToggleOption("showMS","Hit MS","Display the milliseconds for when you hit a note"),
			new ToggleOption("showCounters","Show judgement counters","Should there be judgement counters on the left"),
			new ToggleOption("ratingInHUD","Ratings in HUD","Are ratings part of the UI"),
			new ToggleOption("pauseHoldAnims","Holds pause anims", "Do animations get paused on the first frame on holds"),
			new ToggleOption("menuFlash","Flashing in menus","Do the background and buttons flash when selecting them in menus"),
			new ToggleOption("hitSound","Hit sounds","Play a click sound when you hit a note"),
			new ToggleOption("freeplayPreview","Song preview in freeplay","Do songs get played when selecting them in the freeplay menu"),
		]),
		new OptionCategory("Loading",[
			new ToggleOption("shouldCache","Cache on startup","Should the engine cache anything when being loaded"),
			new ToggleOption("cacheCharacters","Cache characters","Should the engine cache characters at startup"),
			new ToggleOption("cacheSongs","Cache songs","Should the engine cache songs at startup"),
			new ToggleOption("cacheSounds","Cache sounds","Should the engine cache misc sounds at startup"),
			new ToggleOption("cachePreload","Cache misc images","Should the engine cache misc images"),
			new ToggleOption("cacheUsedImages","Cache loaded images","Should images be cached when they get loaded ",function(state:Bool){
				FlxGraphic.defaultPersist = state;
			}),
		]),
		/*new OptionCategory("Experimental",[
			new ToggleOption("holdsOneNote","Holds are long notes","Should holds be treated like a single, long note")
		])*/
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
		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menuBG"));

		menuBG.color = 0xFFA271DE;
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
