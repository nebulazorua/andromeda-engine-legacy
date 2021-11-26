package states;
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
import ui.*;
using StringTools;

#if desktop
import Discord.DiscordClient;
#end
class OptionsState extends MusicBeatState
{

	public static var instance:OptionsState;
	private var defCat:OptionCategory = new OptionCategory("Default",[
		new OptionCategory("Gameplay",[
			new OptionCategory("Controls",[ // TODO: rewrite
				new ControlOption(controls,Control.LEFT),
				new ControlOption(controls,Control.DOWN),
				new ControlOption(controls,Control.UP),
				new ControlOption(controls,Control.RIGHT),
				new ControlOption(controls,Control.PAUSE),
				new ControlOption(controls,Control.RESET),
			]),
			new ToggleOption("resetKey","Reset key","Whether the reset button should be triggered or not"),
			new ToggleOption("loadModcharts","Load Lua modcharts","Whether the engine loads lua-based modcharts"),
			new ToggleOption("ghosttapping","Ghost-tapping","Whether you miss when you hit nothing"),
			new ToggleOption("failForMissing","Sudden Death","FC or die"),
			new ToggleOption("botPlay","BotPlay","Let a bot play for you"),
			new OptionCategory("Freeplay Modifiers",[
				new StepOption("cMod","Speed Constant",0.1,0,10,"","","A constant speed to override the scrollspeed. 0 for default speed",true),
				new StepOption("xMod","Speed Mult",0.1,0,2,"","x","A multiplier to a chart's scrollspeed",true),
				new StepOption("mMod","Minimum Speed",0.1,0,10,"","x","The minimum scrollspeed a chart can have",true),
				new ToggleOption("noFail","No Fail","You can't blueball, but there's an indicator that you failed and you don't save the score."),
			]),
			new OptionCategory("Advanced",[
				new JudgementsOption("judgementWindow","Judgements","Which judgement window to use"),
				new ToggleOption("useEpic","Use Epics","Whether epics should be used"),
				new ToggleOption("pollingInput","Old input","Whether to check input every frame, or on key press."),
				new ScrollOption("accuracySystem","Accuracy System","How accuracy is determined",0,2,["Basic","ITG","Wife3"])
			]),
			new StateOption("Calibrate Offset",new SoundOffsetState()),
			// TODO: make a better 'calibrate offset'
		]),
		new OptionCategory("Appearance",[
			new ToggleOption("useNotesplashes","Show NoteSplashes","Whether notesplashes show up on sicks and above"),
			new ToggleOption("camFollowsAnims","Directional Camera","Whether the camera moves depending on a character's animations"),
			new ToggleOption("downScroll","Downscroll","Arrows come from the top down instead of the bottom up."),
			new ToggleOption("middleScroll","Centered Notes","Places your notes in the center of the screen and hides the opponent's."),
			new NoteskinOption("noteSkin","NoteSkin","Which noteskin to use"),
			new ToggleOption("allowNoteModifiers","Allow note modifiers","Whether note modifiers (e.g pixel notes in week 6) get used"),
			new StepOption("backTrans","BG Darkness",10,0,100,"%","","How dark the background is",true),
			new ScrollOption("staticCam","Camera Focus","Who the camera should focus on",0,OptionUtils.camFocuses.length-1,OptionUtils.camFocuses),
			new ToggleOption("oldMenus","Vanilla Menus","Vanilla menus, pretty self explanatory."),
			new ToggleOption("oldTitle","Vanilla Title Screen","Vanilla title screen, pretty self explanatory"),
			new ToggleOption("healthBarColors","Healthbar Colours","Whether the healthbar colour changes with the character"),
			new OptionCategory("Effects",[
				new ToggleOption("picoCamshake","Train camera shake","Whether the train in week 3's background shakes the camera"),
				//new ToggleOption("senpaiShaders","Week 6 shaders","Is the CRT effect active in week 6"),
				new ScrollOption("senpaiShaderStrength","Week 6 shaders","How strong the week 6 shaders are",0,2,["Off","CRT","All"])
			]),
		]),
		new OptionCategory("Preferences",[
			new ToggleOption("showComboCounter","Show combo","Whether to show your combo when you hit a note"),
			new ToggleOption("showRatings","Show judgements","Whether to show judgements when you hit a note"),
			new ToggleOption("showMS","Show Hit MS","Whether to display the millisecond difference when you hit a note"),
			new ToggleOption("showCounters","Show judgement counters","Whether judgement counters get shown on the side"),
			new ToggleOption("ratingInHUD","Fixed Judgements","Places judgements, milliseconds and combo in the HUD"),
			new ToggleOption("pauseHoldAnims","Holds pause anims", "Whether to pause animations on their first frame"),
			new ToggleOption("menuFlash","Flashing in menus","Whether buttons and the background should flash in menus"),
			new ToggleOption("hitSound","Hit sounds","Play a click sound when you hit a note"),
			new ToggleOption("ghosttapSounds","Ghost-tap hit sounds","Play a click sound when you ghost-tap"),
			new StepOption("hitsoundVol","Hit sound volume",10,0,100,"%","","Hitsound volume",true),
			new ToggleOption("freeplayPreview","Song preview in freeplay","Whether songs get played as you hover over them in Freeplay"),
			new ToggleOption("persistentCombo","Combo doesnt fade","Combo stays on screen instead of fading out"),
		]),
		new OptionCategory("Performance",[
			new StepOption("fps","FPS Cap",30,30,360,"","","The FPS the game tries to run at",true,function(value:Float,step:Float){
				Main.setFPSCap(Std.int(value));
			}),
			new ToggleOption("noChars","Hide characters","Hides characters ingame"),
			new ToggleOption("noStage","Hide background","Hides stage ingame"),
			new ToggleOption("allowOrderSorting","Sort notes by order","Allows notes to go infront and behind other notes. May cause FPS drops on very high note-density charts."),
			new OptionCategory("Loading",[
				new ToggleOption("shouldCache","Cache on startup","Whether the engine caches stuff when the game starts"),
				new ToggleOption("cacheCharacters","Cache characters","Whether the engine caches characters if it caches on startup"),
				new ToggleOption("cacheSongs","Cache songs","Whether the engine caches songs if it caches on startup"),
				new ToggleOption("cacheSounds","Cache sounds","Whether the engine caches misc sounds if it caches on startup"),
				new ToggleOption("cachePreload","Cache misc images","Whether the engine caches misc images if it caches on startup"),
				new ToggleOption("cacheUsedImages","Persistent Images","Whether images should persist in memory",function(state:Bool){
					FlxGraphic.defaultPersist = state;
				}),
			]),
		])
	]);

	private var optionText:FlxTypedGroup<Option>;
	private var optionDesc:FlxText;
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

		optionDesc = new FlxText(5, FlxG.height-48,0,"",20);
		optionDesc.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		optionDesc.textField.background=true;
		optionDesc.textField.backgroundColor = FlxColor.BLACK;
		refresh();
		optionDesc.visible=false;
		add(optionDesc);

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
				if(item.description!=null && item.description.replace(" ","")!=''){
					optionDesc.visible=true;
					optionDesc.text = item.description;
				}else{
					optionDesc.visible=false;
				}
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
