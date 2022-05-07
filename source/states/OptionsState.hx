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
	private var defCat:OptionCategory;

	private var optionText:FlxTypedGroup<Option>;
	private var optionDesc:FlxText;
	private var curSelected:Int = 0;
	public static var category:Dynamic;

	private function createDefault(){
		defCat = new OptionCategory("Default",[
			new OptionCategory("Gameplay",[
				new OptionCategory("Controls",[ // TODO: rewrite
					new ControlOption(controls,Control.LEFT),
					new ControlOption(controls,Control.DOWN),
					new ControlOption(controls,Control.UP),
					new ControlOption(controls,Control.RIGHT),
					new ControlOption(controls,Control.PAUSE),
					new ControlOption(controls,Control.RESET),
				]),
				new ToggleOption("resetKey","Reset key","Toggle pressing the bound key to instantly die"),
				#if !FORCE_LUA_MODCHARTS new ToggleOption("loadModcharts","Load Lua modcharts","Toggles lua modcharts"), #end
				new ToggleOption("ghosttapping","Ghost-tapping","Allows you to press keys while no notes are able to be hit."),
				new ToggleOption("failForMissing","Sudden Death","FC or die"),
				#if !NO_BOTPLAY new ToggleOption("botPlay","BotPlay","Let a bot play for you"), #end
				#if !NO_FREEPLAY_MODS
				new ToggleOption("fixHoldSegCount","Hold Segment Count Fix","Fixes a bug where holds are smaller than they should be.\nMay cause holds to be longer than they should in old charts."),
				new OptionCategory("Freeplay Modifiers",[
					new StepOption("cMod","Speed Constant",0.1,0,10,"","","A constant speed to override the scrollspeed. 0 for chart-dependant speed",true),
					new StepOption("xMod","Speed Mult",0.1,0,2,"","x","A multiplier to a chart's scrollspeed",true),
					new StepOption("mMod","Minimum Speed",0.1,0,10,"","","The minimum scrollspeed a chart can have",true),
					new ToggleOption("noFail","No Fail","You can't blueball, but there's an indicator that you failed and you don't save the score."),
				]),
				#end
				new OptionCategory("Advanced",[
					#if !FORCED_JUDGE new JudgementsOption("judgementWindow","Judgements","The judgement windows to use"),
					new ToggleOption("useEpic","Use Epics","Allows the 'Epic' judgement to be used"),#end
					new ScrollOption("accuracySystem","Accuracy System","How accuracy is determined",0,2,["Basic","SM","Wife3"]),
					//new ToggleOption("attemptToAdjust", "Better Sync", "Attempts to sync the song position to the instrumental better by using the average offset between the\ninstrumental and the visual pos")
				]),
				new StateOption("Calibrate Offset",new SoundOffsetState()),
				// TODO: make a better 'calibrate offset'
			]),
			new OptionCategory("Appearance",[
				new ToggleOption("showComboCounter","Show combo","Shows your combo when you hit a note"),
				new ToggleOption("showRatings","Show judgements","Shows judgements when you hit a note"),
				new ToggleOption("showMS","Show Hit MS","Shows millisecond difference when you hit a note"),
				new ToggleOption("showCounters","Show judgement counters","Whether judgement counters get shown on the side"),
				new ToggleOption("downScroll","Downscroll","Arrows come from the top down instead of the bottom up."),
				new ToggleOption("middleScroll","Centered Notes","Places your notes in the center of the screen and hides the opponent's. \"Middlescroll\""),
				new StepOption("backTrans","BG Darkness",10,0,100,"%","","How dark the background is",true),
				new ScrollOption("staticCam","Camera Focus","Who the camera should focus on",0,OptionUtils.camFocuses.length-1,OptionUtils.camFocuses),
				new ToggleOption("oldMenus","Vanilla Menus","Forces the vanilla menus to be used"),
				new ToggleOption("oldTitle","Vanilla Title Screen","Forces the vanilla title to be used"),
				new ToggleOption("onlyScore","Minimal Information","Only shows your score below the hp bar"),
				new ToggleOption("smoothHPBar","Smooth Healthbar","Makes the HP Bar smoother"),
				new ToggleOption("holdsBehindReceptors","Holds Behinds Receptors","Makes holds layer behind the receptors, similar to other VSRGs"),
				new NoteskinOption("noteSkin","NoteSkin","The noteskin to use"),
				new OptionCategory("Effects",[
					new ToggleOption("raymarcher","Raymarcher Shaders","Lets the camera have pitch and yaw. May cause lag"),
					new ToggleOption("picoCamshake","Train camera shake","Whether the train in week 3's background shakes the camera"),
					new ScrollOption("senpaiShaderStrength","Week 6 shaders","How strong the week 6 shaders are",0,2,["Off","CRT","All"])
				]),
			]),
			new OptionCategory("Preferences",[
				new ToggleOption("useNotesplashes","Show NoteSplashes","Notesplashes showing up on sicks and above."),
				new ToggleOption("camFollowsAnims","Directional Camera","Camera moving depending on a character's animations"),
				new ToggleOption("ratingInHUD","Fixed Judgements","Fixes judgements, milliseconds and combo to the screen"),
				new ToggleOption("ratingOverNotes","Judgements over notes","Places judgements, milliseconds and combo above the playfield"),
				new ToggleOption("smJudges","Simple Judgements","Animates judgements and combo like conventional VSRGs"), // name from forever lmao
				new ToggleOption("menuFlash","Flashing in menus","Whether buttons and the background should flash in menus"),
				new ScrollOption("hitsoundType","Hit sounds","When to play a click sound", 0, 3, ["Off", "All", "Ghost-tapping", "Notes"]),
				new StepOption("hitsoundVol","Hit sound volume",10,0,100,"%","","What volume the hit sound should be",true),
				new ToggleOption("freeplayPreview","Song preview in freeplay","Whether songs get played as you hover over them in Freeplay"),
				new ToggleOption("fastTransitions","Fast Transitions","Makes transitions between states faster"),
				new StateOption("Judgement Position",new JudgeCustomizationState()),
				new OptionCategory("Debug",[
					new ToggleOption("showFPS","Show FPS","Shows your FPS in the top left",function(state:Bool){
						ui.FPSMem.showFPS=state;
					}),
					new ToggleOption("showMem","Show Memory","Shows memory usage in the top left",function(state:Bool){
						ui.FPSMem.showMem=state;
					}),
					new ToggleOption("showMemPeak","Show Memory Peak","Shows peak memory usage in the top left",function(state:Bool){
						ui.FPSMem.showMemPeak=state;
					})
				])
			]),
			new OptionCategory("Performance",[
				new StepOption("fps","FPS Cap",30,30,360,"","","The FPS the game tries to run at",true,function(value:Float,step:Float){
					Main.setFPSCap(Std.int(value));
				}),
				new ToggleOption("recycleComboJudges","Recycling","Instead of making a new sprite for each judgement and combo number, objects are reused when possible.\nMay cause layering issues."),
				new ToggleOption("noChars","Hide characters","Hides characters ingame"),
				new ToggleOption("noStage","Hide background","Hides stage ingame"),
				new ToggleOption("antialiasing","Antialiasing","Toggles the ability for sprites to have antialiasing"),
				new ToggleOption("allowOrderSorting","Sort notes by order","Allows notes to go infront and behind other notes. May cause FPS drops on very high note-density charts."),
				new OptionCategory("Loading",[
					new ToggleOption("shouldCache","Cache on startup","Whether the engine caches stuff when the game starts"),
					new ToggleOption("cacheCharacters","Cache characters","Whether the engine caches characters if it caches on startup"),
					new ToggleOption("cacheSongs","Cache songs","Whether the engine caches songs if it caches on startup"),
					new ToggleOption("cacheSounds","Cache sounds","Whether the engine caches misc sounds if it caches on startup"),
					new ToggleOption("cachePreload","Cache misc images","Whether the engine caches misc images if it caches on startup"),
					new ToggleOption("cacheUsedImages","Persistent Images","Whether images should persist in memory"),
				]),
			])
		]);
	}
	override function create()
	{
		super.create();
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Changing options", null);
		#end
		createDefault();
		category=defCat;
		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menuBGDesat"));

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
			trace("shit");
			if(option.type=='Category'){
				category=option;
				refresh();
			}else if(option.accept()) {
				option.createOptionText(curSelected,optionText);
			}
			changeSelection();
			trace("cum");
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
