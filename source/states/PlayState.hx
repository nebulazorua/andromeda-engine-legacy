package states;

#if desktop
import Discord.DiscordClient;
#end

import modchart.*;
import Options;
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.util.FlxSpriteUtil;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import ui.*;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxTimer;
import haxe.Json;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import LuaClass;
import flash.display.BitmapData;
import flash.display.Bitmap;
import Shaders;
import haxe.Exception;
import openfl.utils.Assets;
import ModChart;
import flash.events.KeyboardEvent;
import Controls;
import Controls.Control;
import openfl.media.Sound;
import openfl.display.GraphicsShader;
import sys.io.File;
#if cpp
import vm.lua.LuaVM;
import vm.lua.Exception;
import Sys;
import sys.FileSystem;
import llua.Convert;
import llua.Lua;
import llua.State;
import llua.LuaL;
#end

import EngineData.WeekData;
import EngineData.SongData;

using StringTools;
using flixel.util.FlxSpriteUtil;

class PlayState extends MusicBeatState
{
	public static var noteCounter:Map<String,Int> = [];
	public static var inst:FlxSound;

	public static var songData:SongData;
	public static var currentPState:PlayState;
	public static var weekData:WeekData;
	public static var inCharter:Bool=false;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public var scrollSpeed:Float = 1;
	public var dontSync:Bool=false;
	public var currentTrackPos:Float = 0;
	public var currentVisPos:Float = 0;
	var halloweenLevel:Bool = false;
	public var stage:Stage;

	private var vocals:FlxSound;

	public var dad:Character;
	public var opponent:Character;
	public var gf:Character;
	public var boyfriend:Boyfriend;
	public static var judgeMan:JudgementManager;
	public static var startPos:Float = 0;
	public static var charterPos:Float = 0;

	private var shownAccuracy:Float = 0;

	private var renderedNotes:FlxTypedGroup<Note>;
	private var noteSplashes:FlxTypedGroup<NoteSplash>;
	private var playerNotes:Array<Note> = [];
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;
	public var currentOptions:Options;

	private static var prevCamFollow:FlxObject;
	private var lastHitDadNote:Note;
	public var strumLineNotes:FlxTypedGroup<Receptor>;
	public var playerStrums:FlxTypedGroup<Receptor>;
	public var dadStrums:FlxTypedGroup<Receptor>;
	public var playerStrumLines:FlxTypedGroup<FlxSprite>;
	public var refNotes:FlxTypedGroup<FlxSprite>;
	public var opponentRefNotes:FlxTypedGroup<FlxSprite>;
	public var refReceptors:FlxTypedGroup<FlxSprite>;
	public var opponentRefReceptors:FlxTypedGroup<FlxSprite>;
	public var opponentStrumLines:FlxTypedGroup<FlxSprite>;
	public var center:FlxPoint;

	// gonna do this some day
	private var opponentNotefield:Notefield;
	private var playerNotefield:Notefield;

	public var luaSprites:Map<String, Dynamic>;
	public var luaObjects:Map<String, Dynamic>;
	public var unnamedLuaSprites:Int=0;
	public var unnamedLuaShaders:Int=0;
	public var dadLua:LuaCharacter;
	public var gfLua:LuaCharacter;
	public var bfLua:LuaCharacter;
	public var gameCam3D:RaymarchEffect;
	public var hudCam3D:RaymarchEffect;
	public var noteCam3D:RaymarchEffect;

	public static var noteModifier:String='base';
	public static var uiModifier:String='base';
	var pressedKeys:Array<Bool> = [false,false,false,false];

	private var camZooming:Bool = true;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var previousHealth:Float = 1;
	private var combo:Int = 0;
	private var highestCombo:Int = 0;
	private var healthBar:Healthbar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	public var camHUD:FlxCamera;
	public var camNotes:FlxCamera;
	public var camReceptor:FlxCamera;
	public var camSus:FlxCamera;
	public var pauseHUD:FlxCamera;
	public var camRating:FlxCamera;
	public var camGame:FlxCamera;
	public var modchart:ModChart;
	public var botplayPressTimes:Array<Float> = [0,0,0,0];
	public var botplayHoldTimes:Array<Float> = [0,0,0,0];
	public var botplayHoldMaxTimes:Array<Float> = [0,0,0,0];

	public var upscrollOffset:Float = 0;
	public var downscrollOffset:Float = 0;

	public var modManager:ModManager;

	public var opponents:Array<Character> = [];
	public var opponentIdx:Int = 0;

	var judgeBin:FlxTypedGroup<JudgeSprite>;
	var comboBin:FlxTypedGroup<ComboSprite>;
	var accuracyName:String = 'Accuracy';

	var bindData:Array<FlxKey>;
	var lua:LuaVM;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var lightFadeShader:BuildingEffect;
	var vcrDistortionHUD:VCRDistortionEffect;
	var vcrDistortionGame:VCRDistortionEffect;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();
	var turn:String='';
	var focus:String='';

	var talking:Bool = true;
	var songScore:Int = 0;
	var botplayScore:Int = 0;
	var scoreTxt:FlxText;
	var highComboTxt:FlxText;
	var ratingCountersUI:FlxSpriteGroup;
	var botplayTxt:FlxText;

	var presetTxt:FlxText;

	var accuracy:Float = 1;
	var hitNotes:Float = 0;
	var totalNotes:Float = 0;

	var counters:Map<String,FlxText> = [];

	var grade:String = "N/A";
	var luaModchartExists = false;
	var noteLanes:Array<Array<Note>> = [];
	var susNoteLanes:Array<Array<Note>> = [];
	var died:Bool = false;
	var canScore:Bool = true;
	var comboSprites:Array<FlxSprite>=[];

	var velocityMarkers:Array<Float>=[];

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	var inCutscene:Bool = false;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var songLength:Float = 0;
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	function setupLuaSystem(){
		if(luaModchartExists){
			lua = new LuaVM();
			lua.setGlobalVar("storyDifficulty",storyDifficulty);
			lua.setGlobalVar("chartName",songData.chartName);
			lua.setGlobalVar("songName",SONG.song);
			lua.setGlobalVar("displayName",songData.displayName);
			lua.setGlobalVar("curBeat",0);
			lua.setGlobalVar("curStep",0);
			lua.setGlobalVar("curDecBeat",0);
			lua.setGlobalVar("curDecStep",0);
			lua.setGlobalVar("songPosition",Conductor.songPosition);
			lua.setGlobalVar("bpm",Conductor.bpm);
			lua.setGlobalVar("XY","XY");
			lua.setGlobalVar("X","X");
			lua.setGlobalVar("Y","Y");
			lua.setGlobalVar("width",FlxG.width);
			lua.setGlobalVar("height",FlxG.height);

			Lua_helper.add_callback(lua.state,"log", function(string:String){
				FlxG.log.add(string);
			});

			Lua_helper.add_callback(lua.state,"playSound", function(sound:String,volume:Float=1,looped:Bool=false){
				FlxG.sound.play(sound,volume,looped);
			});

			Lua_helper.add_callback(lua.state,"setVar", function(variable:String,val:Any){
				Reflect.setField(this,variable,val);
			});

			Lua_helper.add_callback(lua.state,"getVar", function(variable:String){
				return Reflect.field(this,variable);
			});

			Lua_helper.add_callback(lua.state,"setJudge", function(variable:String,val:Any){
				judgeMan.judgementCounter.set(variable,val);
			});

			Lua_helper.add_callback(lua.state,"getJudge", function(variable:String){
				return judgeMan.judgementCounter.get(variable);
			});

			Lua_helper.add_callback(lua.state,"setOption", function(variable:String,val:Any){
				Reflect.setField(currentOptions,variable,val);
			});

			Lua_helper.add_callback(lua.state,"getOption", function(variable:String){
				return Reflect.field(currentOptions,variable);
			});

			Lua_helper.add_callback(lua.state,"compensateFPS", function(num:Float){ // prob need new name? idk
				return Main.adjustFPS(num);
			});

			Lua_helper.add_callback(lua.state,"newOpponent", function(x:Float, y:Float, ?character:String = "bf", ?spriteName:String){
				var char = new Character(x,y,character,false,!currentOptions.noChars);
				var name = "UnnamedOpponent"+unnamedLuaSprites;

				if(spriteName!=null)
					name=spriteName;
				else
					unnamedLuaSprites++;

				var lSprite = new LuaCharacter(char,name,spriteName!=null);
				var classIdx = Lua.gettop(lua.state)+1;
				lSprite.Register(lua.state);
				Lua.pushvalue(lua.state,classIdx);
				opponents.push(char);
				stage.layers.get("dad").add(char);
			});

			Lua_helper.add_callback(lua.state,"newSprite", function(?x:Int=0,?y:Int=0,?drawBehind:Bool=false,?spriteName:String){
				var sprite = new FlxSprite(x,y);
				var name = "UnnamedSprite"+unnamedLuaSprites;

				if(spriteName!=null)
					name=spriteName;
				else
					unnamedLuaSprites++;

				var lSprite = new LuaSprite(sprite,name,spriteName!=null);
				var classIdx = Lua.gettop(lua.state)+1;
				lSprite.Register(lua.state);
				Lua.pushvalue(lua.state,classIdx);
				if(drawBehind){
					stage.add(sprite);
				}else{
					add(sprite);
				};
			});

			var dirs = ["left","down","up","right"];
			for(dir in 0...playerStrums.length){
				var receptor = playerStrums.members[dir];
				new LuaReceptor(receptor, '${dirs[dir]}PlrNote').Register(lua.state);
			}
			for(dir in 0...dadStrums.length){
				var receptor = dadStrums.members[dir];
				new LuaReceptor(receptor, '${dirs[dir]}DadNote').Register(lua.state);
			}

			var luaModchart = new LuaModchart(modchart);

			bfLua = new LuaCharacter(boyfriend,"bf",true);
			gfLua = new LuaCharacter(gf,"gf",true);
			dadLua = new LuaCharacter(dad,"dad",true);

			var bfIcon = new LuaSprite(healthBar.iconP1,"iconP1",true);
			var dadIcon = new LuaSprite(healthBar.iconP2,"iconP2",true);

			var window = new LuaWindow();

			var luaGameCam = new LuaCam(FlxG.camera,"gameCam");
			var luaHUDCam = new LuaCam(camHUD,"HUDCam");
			var luaNotesCam = new LuaCam(camNotes,"notesCam");
			var luaSustainCam = new LuaCam(camSus,"holdCam");
			var luaReceptorCam = new LuaCam(camReceptor,"receptorCam");
			// TODO: a flat 'camera' object which'll affect the properties of every camera

			new LuaModMgr(modManager).Register(lua.state);

			for(i in [luaModchart,window,bfLua,gfLua,dadLua,bfIcon,dadIcon,luaGameCam,luaHUDCam,luaNotesCam,luaSustainCam,luaReceptorCam])
				i.Register(lua.state);


			lua.errorHandler = function(error:String){
				FlxG.log.advanced(error, EngineData.LUAERROR, true);
			}

			// this catches compile errors
			try {
				lua.runFile(Paths.modchart(songData.chartName.toLowerCase()));
			}catch (e:Exception){
				FlxG.log.advanced(e, EngineData.LUAERROR, true);
			};
		}
	}

	override public function create()
	{
		super.create();

		modchart = new ModChart(this);
		unnamedLuaSprites=0;
		currentPState=this;
		currentOptions = OptionUtils.options.clone();
		#if !debug
		if(isStoryMode){
			currentOptions.noFail=false;
		}
		#end
		#if NO_BOTPLAY
			currentOptions.botPlay=false;
		#end
		#if NO_FREEPLAY_MODS
			currentOptions.mMod=0;
			currentOptions.cMod=0;
			currentOptions.xMod=1;
			currentOptions.noFail=false;
		#end


		ScoreUtils.ghostTapping = currentOptions.ghosttapping;
		ScoreUtils.botPlay = currentOptions.botPlay;
		#if FORCED_JUDGE
		judgeMan = new JudgementManager(new JudgementManager.JudgementData(EngineData.defaultJudgementData));
		#else
		judgeMan = new JudgementManager(JudgementManager.getDataByName(currentOptions.judgementWindow));
		#end
		Conductor.safeZoneOffset = judgeMan.getHighestWindow();
		Conductor.calculate();
		ScoreUtils.wifeZeroPoint = judgeMan.getWifeZero();

		bindData = [
			OptionUtils.getKey(Control.LEFT),
			OptionUtils.getKey(Control.DOWN),
			OptionUtils.getKey(Control.UP),
			OptionUtils.getKey(Control.RIGHT),
		];

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		//lua = new LuaVM();
		#if cpp
			luaModchartExists = FileSystem.exists(Paths.modchart(songData.chartName.toLowerCase()));
		#end

		trace(luaModchartExists);
		judgeBin = new FlxTypedGroup<JudgeSprite>();
		comboBin = new FlxTypedGroup<ComboSprite>();
		//judgeBin.add(new JudgeSprite());

		grade = "N/A";
		hitNotes=0;
		totalNotes=0;
		accuracy=1;

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FNFCamera();
		camRating = new FNFCamera();
		camHUD = new FNFCamera();
		camNotes = new FNFCamera();
		camSus = new FNFCamera();
		camReceptor = new FNFCamera();
		camHUD.bgColor.alpha = 0;
		camNotes.bgColor.alpha = 0;
		camRating.bgColor.alpha = 0;
		camSus.bgColor.alpha = 0;
		camReceptor.bgColor.alpha = 0;
		pauseHUD = new FNFCamera();
		pauseHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		if(!currentOptions.ratingInHUD)
			FlxG.cameras.add(camRating);
		FlxG.cameras.add(camReceptor);
		if(currentOptions.ratingInHUD)
			FlxG.cameras.add(camRating);
		FlxG.cameras.add(camSus);
		FlxG.cameras.add(camNotes);

		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(pauseHUD);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		var speed = SONG.speed;
		if(!isStoryMode){
			var mMod = currentOptions.mMod<.1?speed:currentOptions.mMod;
			speed = currentOptions.cMod<.1?speed:currentOptions.cMod;
			speed *= currentOptions.xMod;
			if(speed<mMod){
				speed=mMod;
			}
		}

		SONG.initialSpeed = speed*.45;

		SONG.sliderVelocities.sort((a,b)->Std.int(a.startTime-b.startTime));
		mapVelocityChanges();

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);



		switch (songData.chartName.toLowerCase())
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
			case 'bopeebo':
				dialogue = [
					'HEY!',
					"You think you can just sing\nwith my daughter like that?",
					"If you want to date her...",
					"You're going to have to go \nthrough ME first!"
				];
			case 'fresh':
				dialogue = ["Not too shabby boy.", ""];
			case 'dadbattle':
				dialogue = [
					"gah you think you're hot stuff?",
					"If you can beat me here...",
					"Only then I will even CONSIDER letting you\ndate my daughter!"
				];
			default:
				try {
					dialogue = CoolUtil.coolTextFile2(File.getContent(Paths.dialogue(songData.chartName.toLowerCase() + "/dialogue")));
				} catch(e){
					trace("epic style " + e.message);
				}
		}

		#if desktop
		// Making difficulty text for Discord Rich Presence.
		switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "Easy";
			case 1:
				storyDifficultyText = "Normal";
			case 2:
				storyDifficultyText = "Hard";
		}

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek+ " ";
		}
		else
		{
			detailsText = "Freeplay"+ " ";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText + songData.displayName + " (" + storyDifficultyText + ")", iconRPC);
		#end
		try{
			vcrDistortionHUD = new VCRDistortionEffect();
			vcrDistortionGame = new VCRDistortionEffect();
		}catch(e:Any){
			trace(e);
		}

		noteModifier='base';
		uiModifier='base';
		curStage=SONG.stage==null?Stage.songStageMap.get(songData.chartName.toLowerCase()):SONG.stage;

		if(curStage==null){
			curStage='stage';
		}


		if(SONG.stage==null)
			SONG.stage = curStage;

		if(currentOptions.noStage)
			curStage='blank';

		stage = new Stage(curStage,currentOptions);
		switch(curStage){
			case 'school' | 'schoolEvil':
			noteModifier='pixel';
			uiModifier='pixel';
			if(currentOptions.senpaiShaderStrength>0){ // they're on
				if(vcrDistortionHUD!=null){
					if(currentOptions.senpaiShaderStrength>=2){ // sempai shader strength
						switch(songData.chartName.toLowerCase()){
							case 'roses':
								vcrDistortionHUD.setVignetteMoving(false);
								vcrDistortionGame.setVignette(false);
								vcrDistortionGame.setGlitchModifier(.025);
								vcrDistortionHUD.setGlitchModifier(.025);
							case 'thorns':
								vcrDistortionGame.setGlitchModifier(.2);
								vcrDistortionHUD.setGlitchModifier(.2);
							case _: // default
								vcrDistortionHUD.setVignetteMoving(false);
								vcrDistortionGame.setVignette(false);
								vcrDistortionHUD.setDistortion(false);
								vcrDistortionGame.setDistortion(false);
						}
					}else{
						vcrDistortionHUD.setVignetteMoving(false);
						vcrDistortionGame.setVignette(false);
						vcrDistortionHUD.setDistortion(false);
						vcrDistortionGame.setDistortion(false);
					}
					vcrDistortionGame.setNoise(false);
					vcrDistortionHUD.setNoise(true);

					modchart.addCamEffect(vcrDistortionGame);
					modchart.addHudEffect(vcrDistortionHUD);
					modchart.addNoteEffect(vcrDistortionHUD);
				}
			}
		}

		/*ameCam3D = new RaymarchEffect();
		hudCam3D = new RaymarchEffect();
		noteCam3D = new RaymarchEffect();

		modchart.addCamEffect(gameCam3D);
		modchart.addHudEffect(hudCam3D);
		modchart.addNoteEffect(noteCam3D);*/


		if(SONG.noteModifier!=null)
			noteModifier=SONG.noteModifier;

		add(stage);

		FlxG.mouse.visible = false;


		var gfVersion:String = stage.gfVersion;

		if(!currentOptions.allowNoteModifiers){
			noteModifier='base';
		}
		if(SONG.player1=='bf-neb')
			gfVersion = 'lizzy';


		gf = new Character(400, 130, gfVersion, false, !currentOptions.noChars);
		gf.scrollFactor.set(1,1);
		stage.gf=gf;

		dad = new Character(100, 100, SONG.player2, false, !currentOptions.noChars);
		stage.dad=dad;
		boyfriend = new Boyfriend(770, 450, SONG.player1, !currentOptions.noChars);
		stage.boyfriend=boyfriend;

		stage.setPlayerPositions(boyfriend,dad,gf);

		defaultCamZoom=stage.defaultCamZoom;
		if(boyfriend.curCharacter=='spirit' && !currentOptions.noChars){
			var evilTrail = new FlxTrail(boyfriend, null, 4, 24, 0.3, 0.069);
			add(evilTrail);
		}
		if(dad.curCharacter=='spirit' && !currentOptions.noChars){
			var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
			add(evilTrail);
		}
		if(SONG.player1=='bf-neb')
			boyfriend.y -= 75;

		add(gf);
		add(stage.layers.get("gf"));
		add(dad);
		add(stage.layers.get("dad"));
		add(boyfriend);
		add(stage.layers.get("boyfriend"));
		add(stage.foreground);

		add(stage.overlay);
		stage.overlay.cameras = [camHUD];

		opponents.push(dad);
		switch(currentOptions.staticCam){
			case 1:
				focus='bf';
			case 2:
				focus='dad';
		}

		if(currentOptions.noChars){
			remove(gf);
			remove(dad);
			remove(boyfriend);
		}

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.rawSongPos = -5000 + startPos + currentOptions.noteOffset;
		Conductor.songPosition=Conductor.rawSongPos;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<Receptor>();
		add(strumLineNotes);

		playerStrumLines = new FlxTypedGroup<FlxSprite>();
		opponentStrumLines = new FlxTypedGroup<FlxSprite>();
		luaSprites = new Map<String, FlxSprite>();
		luaObjects = new Map<String, FlxBasic>();
		refNotes = new FlxTypedGroup<FlxSprite>();
		opponentRefNotes = new FlxTypedGroup<FlxSprite>();
		refReceptors = new FlxTypedGroup<FlxSprite>();
		opponentRefReceptors = new FlxTypedGroup<FlxSprite>();
		playerStrums = new FlxTypedGroup<Receptor>();
		dadStrums = new FlxTypedGroup<Receptor>();

		noteSplashes = new FlxTypedGroup<NoteSplash>();
		//var recyclableSplash = new NoteSplash(100,100);
		//recyclableSplash.alpha=0;
		//noteSplashes.add(recyclableSplash);

		add(noteSplashes);
		//add(judgeBin);

		// startCountdown();

		generateSong();

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(stage.centerX==-1?stage.camPos.x:stage.centerX,stage.centerY==-1?stage.camPos.y:stage.centerY);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, Main.adjustFPS(.03));
		camRating.follow(camFollow,LOCKON,Main.adjustFPS(.03));
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		healthBar = new Healthbar(0,FlxG.height*.9,boyfriend.iconName,dad.iconName,this,'health',0,2);
		healthBar.smooth = currentOptions.smoothHPBar;
		healthBar.scrollFactor.set();
		healthBar.screenCenter(X);
		if(currentOptions.healthBarColors)
			healthBar.setColors(dad.iconColor,boyfriend.iconColor);

		if(currentOptions.downScroll){
			healthBar.y = FlxG.height*.1;
		}


		scoreTxt = new FlxText(healthBar.bg.x + healthBar.bg.width / 2 - 150, healthBar.bg.y + 25, 0, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();

		botplayTxt = new FlxText(0, 80, 0, "[BOTPLAY]", 30);
		botplayTxt.visible = ScoreUtils.botPlay;
		botplayTxt.cameras = [camHUD];
		botplayTxt.screenCenter(X);
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		botplayTxt.scrollFactor.set();

		add(botplayTxt);

		if(currentOptions.downScroll){
			botplayTxt.y = FlxG.height-80;
		}

		ratingCountersUI = new FlxSpriteGroup();
		/*presetTxt = new FlxText(0, FlxG.height/2-80, 0, "", 20);
		presetTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		presetTxt.scrollFactor.set();
		presetTxt.visible=false;*/

		highComboTxt = new FlxText(0, FlxG.height/2-60, 0, "", 20);
		highComboTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		highComboTxt.scrollFactor.set();
		var counterIdx:Int = 0;
		ratingCountersUI.add(highComboTxt);
		for(judge in judgeMan.getJudgements()){
			var offset = -40+(counterIdx*20);

			var txt = new FlxText(0, (FlxG.height/2)+offset, 0, "", 20);
			txt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
			txt.scrollFactor.set();
			ratingCountersUI.add(txt);
			counters.set(judge,txt);
			counterIdx++;
		}
		ratingCountersUI.visible = currentOptions.showCounters;

		highComboTxt.text = "Highest Combo: " + highestCombo;

		add(healthBar);
		add(scoreTxt);
		add(ratingCountersUI);
		updateJudgementCounters();

		strumLineNotes.cameras = [camReceptor];
		renderedNotes.cameras = [camNotes];
		//judgeBin.cameras = [camRating];
		noteSplashes.cameras = [camReceptor];
		healthBar.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		ratingCountersUI.cameras = [camHUD];
		doof.cameras = [camHUD];


		var centerP = new FlxSprite(0,0);
		centerP.screenCenter(XY);

		center = FlxPoint.get(centerP.x,centerP.y);

		upscrollOffset = -center.y+50;
		downscrollOffset = center.y-150;

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;
		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		var removing:Array<Note>=[];
		for(note in unspawnNotes){
			if(note.strumTime<startPos){
				removing.push(note);
			}
		}
		for(note in removing){
			unspawnNotes.remove(note);
			destroyNote(note);
		}

		if(currentOptions.backTrans>0){
			var overlay = new FlxSprite(0,0).makeGraphic(Std.int(FlxG.width*2),Std.int(FlxG.width*2),FlxColor.BLACK);
			overlay.screenCenter(XY);
			overlay.alpha = currentOptions.backTrans/100;
			overlay.scrollFactor.set();
			add(overlay);
		}
		if (isStoryMode)
		{
			switch (curSong.toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);
				default:
					startCountdown();
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				default:
					startCountdown();
			}
		}

	}

	function AnimWithoutModifiers(a:String){
		var reg1 = new EReg(".+Hold","i");
		var reg2 = new EReg(".+Repeat","i");
		trace(reg1.replace(reg2.replace(a,""),""));
		return reg1.replace(reg2.replace(a,""),"");
	}

	public function swapCharacterByLuaName(spriteName:String,newCharacter:String){
		var sprite = luaSprites[spriteName];
		if(sprite!=null){
			var newSprite:Character;
			var spriteX = sprite.x;
			var spriteY = sprite.y;
			var currAnim:String = "idle";
			if(sprite.animation.curAnim!=null)
				currAnim=sprite.animation.curAnim.name;
			trace(currAnim);
			remove(sprite);
			// TODO: Make this BETTER!!!
			if(spriteName=="bf"){
				boyfriend = new Boyfriend(spriteX,spriteY,newCharacter,boyfriend.hasSprite);
				newSprite = boyfriend;
				bfLua.sprite = boyfriend;
				//iconP1.changeCharacter(newCharacter);
			}else if(spriteName=="dad"){
				var index = opponents.indexOf(dad);
				if(index>=0)opponents.remove(dad);
				dad = new Character(spriteX,spriteY,newCharacter, dad.isPlayer ,dad.hasSprite);
				newSprite = dad;
				dadLua.sprite = dad;
				if(index>=0)opponents.insert(index,dad);

				//iconP2.changeCharacter(newCharacter);
			}else if(spriteName=="gf"){
				gf = new Character(spriteX,spriteY,newCharacter, gf.isPlayer ,gf.hasSprite);
				newSprite = gf;
				gfLua.sprite = gf;
			}else{
				newSprite = new Character(spriteX,spriteY,newCharacter);
			}
			healthBar.setIcons(boyfriend.iconName,dad.iconName);
			if(currentOptions.healthBarColors)
				healthBar.setColors(dad.iconColor,boyfriend.iconColor);

			luaSprites[spriteName]=newSprite;
			add(newSprite);
			if(currAnim!="idle" && !currAnim.startsWith("dance")){
				newSprite.playAnim(currAnim,true);
			}else if(currAnim=='idle' || currAnim.startsWith("dance")){
				newSprite.dance();
			}


		}
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (songData.chartName.toLowerCase() == 'roses' || songData.chartName.toLowerCase() == 'thorns')
		{
			remove(black);

			if (songData.chartName.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (songData.chartName.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	function startCountdown():Void
	{
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN,keyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP,keyRelease);

		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);

		modManager = new ModManager(this);
		modManager.registerModifiers();


		if(!modManager.exists("reverse")){
			var y = upscrollOffset;
			if(scrollSpeed<0)
				y = downscrollOffset;

			trace(y);

			for(babyArrow in strumLineNotes.members){
				babyArrow.desiredY+=y;
			}
		}

		talking = false;
		startedCountdown = true;
		Conductor.rawSongPos = startPos;
		Conductor.rawSongPos -= Conductor.crochet * 5;
		Conductor.songPosition=Conductor.rawSongPos;

		if(startPos>0)canScore=false;

		#if FORCE_LUA_MODCHARTS
		setupLuaSystem();
		#else
		if(currentOptions.loadModcharts)
			setupLuaSystem();
		#end

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			boyfriend.dance();
			for(opp in opponents){
				if(opp!=dad)opp.dance();
			}

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == uiModifier)
				{
					introAlts = introAssets.get(value);
					if(value=='pixel')altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3${altSuffix}'), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.cameras=[camHUD];
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (altSuffix=='-pixel')
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2${altSuffix}'), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (altSuffix=='-pixel')
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.cameras=[camHUD];
					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1${altSuffix}'), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (altSuffix=='-pixel')
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.cameras=[camHUD];

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo${altSuffix}'), 0.6);
				case 4:
			}

			swagCounter += 1;
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{

		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		inst.play();
		vocals.play();
		inst.time = startPos;
		vocals.time = startPos;
		Conductor.rawSongPos = startPos;
		if(FlxG.sound.music!=null){
			FlxG.sound.music.stop();
		}

		#if desktop
		// Song duration in a float, useful for the time left feature
		songLength = inst.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText + songData.displayName + " (" + storyDifficultyText + ")", grade + " | Acc: " + truncateFloat(accuracy*100,2) + "%", iconRPC, true, songLength);
		#end
	}

	var debugNum:Int = 0;

	private function destroyNote(daNote:Note){
		daNote.active = false;
		daNote.visible = false;

		daNote.kill();

		renderedNotes.remove(daNote,true);
		if(daNote.mustPress){
			playerNotes.remove(daNote);
		}
		daNote.destroy();
	}

	private function generateSong():Void
	{
		// FlxG.log.add(ChartParser.parse());

		//noteSkinJson(key:String, ?library:String='skins', ?skin:String='default', modifier:String='base', ?useOpenFLAssetSystem:Bool=true):FlxGraphicAsset{
		noteCounter.clear();
		noteCounter.set("holdTails",0);
		noteCounter.set("taps",0);

		// STUPID AMERICANS I WANNA NAME THE FILE BEHAVIOUR BUT I CANT
		// DUMB FUCKING AMERICANS CANT JUST ADD A 'U' >:(

		Note.noteBehaviour = Json.parse(Paths.noteSkinText("behaviorData.json",'skins',currentOptions.noteSkin,noteModifier));

		var dynamicColouring:Null<Bool> = Note.noteBehaviour.receptorAutoColor;
		if(dynamicColouring==null)dynamicColouring=false;
		Receptor.dynamicColouring=dynamicColouring;



		var songData = SONG;
		Conductor.changeBPM(SONG.bpm);

		curSong = SONG.song;

		if (SONG.needsVoices){
			vocals = new FlxSound().loadEmbedded(CoolUtil.getSound('${Paths.voices(SONG.song)}'));
			//vocals = new FlxSound().loadEmbedded(Paths.voices(SONG.song));
		}else
			vocals = new FlxSound();

		inst = new FlxSound().loadEmbedded(CoolUtil.getSound('${Paths.inst(SONG.song)}'));
		//inst = new FlxSound().loadEmbedded(Paths.inst(SONG.song));
		inst.looped=false;

		inst.time = startPos;
		vocals.time = startPos;

		if(currentOptions.noteOffset==0)
			inst.onComplete = endSong;
		else
			inst.onComplete = function(){
				dontSync=true;
			};

		Conductor.songLength = inst.length;


		vocals.looped=false;

		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(inst);

		renderedNotes = new FlxTypedGroup<Note>();
		add(renderedNotes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = SONG.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		/*for(idx in 0...4){ // TODO: 6K OR 7K MODE!!
			if(idx==4)break;
			noteLanes[idx]=[];
			susNoteLanes[idx]=[];

		}*/
		scrollSpeed = 1;//(currentOptions.downScroll?-1:1);
		var setupSplashes:Array<String>=[];
		var loadingSplash = new NoteSplash(0,0);
		loadingSplash.visible=false;

		var lastBFNotes:Array<Note> = [null,null,null,null];
		var lastDadNotes:Array<Note> = [null,null,null,null];
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);
			section.sectionNotes.sort((a,b)->Std.int(a[0]-b[0]));

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				var gottaHitNote:Bool = section.mustHitSection;
				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}


				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, currentOptions.noteSkin, noteModifier, EngineData.noteTypes[songNotes[3]], oldNote, false, getPosFromTime(daStrumTime));
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);
				swagNote.cameras = [camNotes];
				if(!setupSplashes.contains(swagNote.graphicType) && gottaHitNote){
					loadingSplash.setup(swagNote);
					setupSplashes.push(swagNote.graphicType);
				}

				if(gottaHitNote){
					var lastBFNote = lastBFNotes[swagNote.noteData];
					if(lastBFNote!=null){
						if(Math.abs(swagNote.strumTime-lastBFNote.strumTime)<=6 ){
							swagNote.kill();
							continue;
						}
					}
					lastBFNotes[swagNote.noteData]=swagNote;
				}else{
					swagNote.causesMiss=false;
					var lastDadNote = lastDadNotes[swagNote.noteData];
					if(lastDadNote!=null){
						if(Math.abs(swagNote.strumTime-lastDadNote.strumTime)<=6 ){
							swagNote.kill();
							continue;
						}
					}
					lastDadNotes[swagNote.noteData]=swagNote;
				}
				if(!swagNote.canHold)swagNote.sustainLength=0;
				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;

				unspawnNotes.push(swagNote);

				if(Math.floor(susLength)>0){
					for (susNote in 0...Math.floor(susLength))
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
						var sussy = daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet;
						var sustainNote:Note = new Note(sussy, daNoteData, currentOptions.noteSkin, noteModifier, EngineData.noteTypes[songNotes[3]], oldNote, true, getPosFromTime(sussy));
						sustainNote.cameras = [camSus];
						sustainNote.scrollFactor.set();
						unspawnNotes.push(sustainNote);

						sustainNote.mustPress = gottaHitNote;
						if(!gottaHitNote)sustainNote.causesMiss=false;

						if (sustainNote.mustPress)
						{
							if(sustainNote.noteType=='default'){
								noteCounter.set("holdTails",noteCounter.get("holdTails")+1);
							}else{
								if(!noteCounter.exists(sustainNote.noteType + "holdTail") )
									noteCounter.set(sustainNote.noteType + "holdTail",0);

								noteCounter.set(sustainNote.noteType + "holdTail",noteCounter.get(sustainNote.noteType + "holdTail")+1);
							}
							sustainNote.x += FlxG.width / 2; // general offset
							sustainNote.defaultX = sustainNote.x;
						}
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					if(swagNote.noteType=='default'){
						noteCounter.set("taps",noteCounter.get("taps")+1);
					}else{
						if(!noteCounter.exists(swagNote.noteType) )
							noteCounter.set(swagNote.noteType,0);

						noteCounter.set(swagNote.noteType,noteCounter.get(swagNote.noteType)+1);
					}
					swagNote.x += FlxG.width / 2; // general offset
					swagNote.defaultX = swagNote.x;
				}
				else {}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);
		shownAccuracy = 100;
		if(currentOptions.accuracySystem==1){ // ITG
			totalNotes = ScoreUtils.GetMaxAccuracy(noteCounter);
			accuracyName = 'Grade Points';
			shownAccuracy = 0;
		}



		generatedMusic = true;

		updateAccuracy();
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByStrum(wat:Int, Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.DESCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByOrder(wat:Int, Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.zIndex, Obj2.zIndex);
	}

	// ADAPTED FROM QUAVER!!!
	// https://github.com/Quaver/Quaver
	// https://github.com/Quaver/Quaver
	// https://github.com/Quaver/Quaver
	function mapVelocityChanges(){
		if(SONG.sliderVelocities.length==0)
			return;

		var pos:Float = SONG.sliderVelocities[0].startTime*(SONG.initialSpeed);
		velocityMarkers.push(pos);
		for(i in 1...SONG.sliderVelocities.length){
			pos+=(SONG.sliderVelocities[i].startTime-SONG.sliderVelocities[i-1].startTime)*(SONG.initialSpeed*SONG.sliderVelocities[i-1].multiplier);
			velocityMarkers.push(pos);
		}
	};
	// https://github.com/Quaver/Quaver
	// https://github.com/Quaver/Quaver
	// https://github.com/Quaver/Quaver
	// ADAPTED FROM QUAVER!!!

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			var dirs = ["left","down","up","right"];
			var clrs = ["purple","blue","green","red"];

			var babyArrow:Receptor = new Receptor(0, center.y, i, currentOptions.noteSkin, noteModifier, Note.noteBehaviour);
			if(player==1)
				noteSplashes.add(babyArrow.noteSplash);


			if(currentOptions.middleScroll && player==0)
				babyArrow.visible=false;

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.ID = i;
			var newStrumLine:FlxSprite = new FlxSprite(0, center.y).makeGraphic(10, 10);
			newStrumLine.scrollFactor.set();

			var newNoteRef:FlxSprite = new FlxSprite(0,-1000).makeGraphic(10, 10);
			newNoteRef.scrollFactor.set();

			var newRecepRef:FlxSprite = new FlxSprite(0,-1000).makeGraphic(10, 10);
			newRecepRef.scrollFactor.set();

			if (player == 1)
			{
				playerStrums.add(babyArrow);
				playerStrumLines.add(newStrumLine);
				refNotes.add(newNoteRef);
				refReceptors.add(newRecepRef);
			}else{
				dadStrums.add(babyArrow);
				opponentStrumLines.add(newStrumLine);
				opponentRefNotes.add(newNoteRef);
				opponentRefReceptors.add(newRecepRef);
			}

			babyArrow.playAnim('static');
			babyArrow.screenCenter(X);
			babyArrow.x -= Note.swagWidth;
			babyArrow.x -= 54;
			babyArrow.x += Note.swagWidth*i;
			if(!currentOptions.middleScroll){
				switch(player){
					case 0:
						babyArrow.x -= FlxG.width/2 - Note.swagWidth*2 - 100;
					case 1:
						babyArrow.x += FlxG.width/2 - Note.swagWidth*2 - 100;
					}
			}

			newStrumLine.x = babyArrow.x;

			babyArrow.defaultX = babyArrow.x;
			babyArrow.defaultY = babyArrow.y;

			babyArrow.desiredX = babyArrow.x;
			babyArrow.desiredY = babyArrow.y;
			babyArrow.point = FlxPoint.get(0,0);

			if (!isStoryMode)
			{
				babyArrow.desiredY -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow,{desiredY: babyArrow.desiredY + 10, alpha:1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	function updateAccuracy():Void
	{
		if(hitNotes==0 && totalNotes==0)
			accuracy = 1;
		else
			accuracy = hitNotes / totalNotes;

		var fcType = ' ';
		if(judgeMan.judgementCounter.get("miss")>0){
			fcType='';
		}else{
			if(judgeMan.judgementCounter.get("bad")+judgeMan.judgementCounter.get("shit")>=noteCounter.get("taps")/2)
				fcType = ' (WTFC)';
			else if(judgeMan.judgementCounter.get("bad")>0 || judgeMan.judgementCounter.get("shit")>0)
				fcType += '(FC)';
			else if(judgeMan.judgementCounter.get("good")>0)
				fcType += '(GFC)';
			else if(judgeMan.judgementCounter.get("sick")>0)
				fcType += '(SFC)';
			else if(judgeMan.judgementCounter.get("epic")>0)
				fcType += '(EFC)';
		}


		grade = died?"F":ScoreUtils.AccuracyToGrade(accuracy) + fcType;
	}
	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (inst != null)
			{
				inst.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (inst != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText + songData.displayName + " (" + storyDifficultyText + ")", grade + " | Acc: " + truncateFloat(accuracy*100,2) + "%", iconRPC, true, songLength- Conductor.rawSongPos);
			}
			else
			{
				DiscordClient.changePresence(detailsText + songData.displayName + " (" + storyDifficultyText + ")", grade + " | Acc: " + truncateFloat(accuracy*100,2) + "%", iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.rawSongPos > 0.0)
			{
				DiscordClient.changePresence(detailsText + songData.displayName + " (" + storyDifficultyText + ")", grade + " | Acc: " + truncateFloat(accuracy*100,2) + "%", iconRPC, true, songLength-Conductor.rawSongPos);
			}
			else
			{
				DiscordClient.changePresence(detailsText + songData.displayName + " (" + storyDifficultyText + ")", grade + " | Acc: " + truncateFloat(accuracy*100,2) + "%", iconRPC);
			}
		}
		#end

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText + songData.displayName + " (" + storyDifficultyText + ")", grade + " | Acc: " + truncateFloat(accuracy*100,2) + "%", iconRPC);
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if(!dontSync){
			vocals.pause();

			inst.play();
			Conductor.rawSongPos = inst.time;
			vocals.time = Conductor.rawSongPos;
			Conductor.songPosition=Conductor.rawSongPos+currentOptions.noteOffset;
			vocals.play();
		}
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	function truncateFloat( number : Float, precision : Int): Float {
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round( num ) / Math.pow(10, precision);
		return num;
	}
	//public float GetSpritePosition(long offset, float initialPos) => HitPosition + ((initialPos - offset) * (ScrollDirection.Equals(ScrollDirection.Down) ? -HitObjectManagerKeys.speed : HitObjectManagerKeys.speed) / HitObjectManagerKeys.TrackRounding);
	// ADAPTED FROM QUAVER!!!
	// COOL GUYS FOR OPEN SOURCING
	// https://github.com/Quaver/Quaver
	// https://github.com/Quaver/Quaver
	// https://github.com/Quaver/Quaver
	function getPosFromTime(strumTime:Float):Float{
		var idx:Int = 0;
		while(idx<SONG.sliderVelocities.length){
			if(strumTime<SONG.sliderVelocities[idx].startTime)
				break;
			idx++;
		}
		return getPosFromTimeSV(strumTime,idx);
	}

	public static function getFNFSpeed(strumTime:Float):Float{
		return (getSVFromTime(strumTime)*(currentPState.scrollSpeed*(1/.45) ));
	}

	public static function getScale(strumTime:Float):Float{
		return Conductor.stepCrochet/100*1.5*PlayState.getFNFSpeed(strumTime);
	}

	public static function getSVFromTime(strumTime:Float):Float{
		var idx:Int = 0;
		while(idx<SONG.sliderVelocities.length){
			if(strumTime<SONG.sliderVelocities[idx].startTime)
				break;
			idx++;
		}
		idx--;
		if(idx<=0)
			return SONG.initialSpeed;
		return SONG.initialSpeed*SONG.sliderVelocities[idx].multiplier;
	}

	function getPosFromTimeSV(strumTime:Float,?svIdx:Int=0):Float{
		if(svIdx==0)
			return strumTime*SONG.initialSpeed;

		svIdx--;
		var curPos = velocityMarkers[svIdx];
		curPos += ((strumTime-SONG.sliderVelocities[svIdx].startTime)*(SONG.initialSpeed*SONG.sliderVelocities[svIdx].multiplier));
		return curPos;
	}

	function updatePositions(){
		Conductor.currentVisPos = Conductor.songPosition;
		Conductor.currentTrackPos = getPosFromTime(Conductor.currentVisPos);
	}

	public function getXPosition(note:Note, ?followReceptor=true):Float{
		var hitPos = playerStrums.members[note.noteData];

		if(!note.mustPress){
			hitPos = dadStrums.members[note.noteData];
		}
		var offset = note.manualXOffset;
		var desiredX = hitPos.desiredX;
		if(followReceptor)desiredX+=hitPos.point.x;

		return desiredX + offset;
	}

	public function getYPosition(note:Note, ?mult, ?followReceptor=true):Float{
		var hitPos = playerStrums.members[note.noteData];
		if(mult==null)mult=scrollSpeed;

		if(!note.mustPress){
			hitPos = dadStrums.members[note.noteData];
		}

		var desiredY = hitPos.desiredY;
		if(followReceptor)desiredY+=hitPos.point.y;

		return desiredY + ((note.initialPos-Conductor.currentTrackPos) * mult) - note.manualYOffset;
	}

	// ADAPTED FROM QUAVER!!!
	// COOL GUYS FOR OPEN SOURCING
	// https://github.com/Quaver/Quaver
	// https://github.com/Quaver/Quaver
	// https://github.com/Quaver/Quaver

	function updateScoreText(){
		if(currentOptions.onlyScore){
			if(botplayScore!=0){
				if(songScore==0)
					scoreTxt.text = 'Bot Score: ${botplayScore}';
				else
					scoreTxt.text = 'Score: ${songScore} | Bot Score: ${botplayScore}';
			}else{
				scoreTxt.text = 'Score: ${songScore}';
			}
		}else{
			if(botplayScore!=0){
				if(songScore==0)
					scoreTxt.text = 'Bot Score: ${botplayScore} | ${accuracyName}: ${shownAccuracy}% | ${grade}';
				else
					scoreTxt.text = 'Score: ${songScore} | Bot Score: ${botplayScore} | ${accuracyName}: ${shownAccuracy}% | ${grade}';
			}else{
				scoreTxt.text = 'Score: ${songScore} | ${accuracyName}: ${shownAccuracy}% | ${grade}';
			}
		}
	}
	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end
		updatePositions();
		if(vcrDistortionHUD!=null){
			vcrDistortionHUD.update(elapsed);
			vcrDistortionGame.update(elapsed);
		}
		modManager.update(elapsed);
		opponent = opponents.length>0?opponents[opponentIdx]:dad;

		modchart.update(elapsed);

		healthBar.visible = ScoreUtils.botPlay?false:modchart.hudVisible;
		scoreTxt.visible = modchart.hudVisible;
		if(presetTxt!=null)
			presetTxt.visible = ScoreUtils.botPlay?false:modchart.hudVisible;


		shownAccuracy = truncateFloat(FlxMath.lerp(shownAccuracy,accuracy*100, Main.adjustFPS(0.2)),2);

		if(Math.abs((accuracy*100)-shownAccuracy) <= 0.1)
			shownAccuracy=truncateFloat(accuracy*100,2);
		//scoreTxt.text = "Score:" + (songScore + botplayScore) + ' / ${accuracyName}:' + shownAccuracy + "% / " + grade;
		updateScoreText();

		scoreTxt.screenCenter(X);
		botplayTxt.screenCenter(X);
		botplayTxt.visible = ScoreUtils.botPlay;

		if(judgeMan.judgementCounter.get('miss')>0 && currentOptions.failForMissing){
			health=0;
		}
		previousHealth=health;
		if (controls.PAUSE && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				FlxG.switchState(new GitarooPauseState());
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if desktop
			DiscordClient.changePresence(detailsPausedText + songData.displayName + " (" + storyDifficultyText + ")", grade + " | Acc: " + truncateFloat(accuracy*100,2) + "%", iconRPC);
			#end
		}

		#if !DISABLE_CHART_EDITOR
		if (FlxG.keys.justPressed.SEVEN)
		{
			inst.pause();
			vocals.pause();
			FlxG.switchState(new ChartingState(charterPos==0?inst.time:charterPos));

			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}
		#end

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		if (health > 2){
			health = 2;
			previousHealth = health;
			if(luaModchartExists && lua!=null)
				lua.setGlobalVar("health",health);
		}

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		#if !DISABLE_CHARACTER_EDITOR
		if (FlxG.keys.justPressed.EIGHT){
			FlxG.switchState(new CharacterEditorState(SONG.player2,new PlayState()));
		}
		#end

		super.update(elapsed);
		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.rawSongPos += FlxG.elapsed * 1000;
				if (Conductor.rawSongPos >= startPos)
					startSong();
			}
			Conductor.songPosition = Conductor.rawSongPos;
		}
		else
		{
			// Conductor.songPosition = inst.time;
			Conductor.rawSongPos += FlxG.elapsed * 1000;
			if(Conductor.rawSongPos>=vocals.length && vocals.length>0){
				dontSync=true;
				vocals.volume=0;
				vocals.stop();
			}
			Conductor.songPosition = Conductor.rawSongPos+currentOptions.noteOffset;



			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.rawSongPos)
				{
					songTime = (songTime + Conductor.rawSongPos) / 2;
					Conductor.lastSongPos = Conductor.rawSongPos;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = inst.time;
		}
		try{
			if(luaModchartExists && lua!=null){
				lua.setGlobalVar("songPosition",Conductor.songPosition);
				lua.setGlobalVar("rawSongPos",Conductor.rawSongPos);
			}
		}catch(e:Any){
			trace(e);
		}
		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}

			var bfMid = boyfriend.getMidpoint();
			var dadMid = opponent.getMidpoint();
			var gfMid = gf.getMidpoint();

			if(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection){
				if(turn!='bf'){
					turn='bf';
					if(currentOptions.staticCam==0)
						focus='bf';
				}
			}else{
				if(turn!='dad'){
					turn='dad';
					if(currentOptions.staticCam==0)
						focus='dad';
				}
			}

			if(currentOptions.staticCam==3 || currentOptions.noChars){
				var centerX = (stage.centerX==-1)?(((dadMid.x+ opponent.camOffset.x) + (bfMid.x- stage.camOffset.x))/2):stage.centerX;
				var centerY = (stage.centerY==-1)?(((dadMid.y+ opponent.camOffset.y) + (bfMid.y- stage.camOffset.y))/2):stage.centerY;
				camFollow.setPosition(centerX,centerY);
			}else{
				var focusedChar:Null<Character>=null;
				switch(focus){
					case 'dad':
						focusedChar=opponent;
						camFollow.setPosition(dadMid.x + opponent.camOffset.x, dadMid.y + opponent.camOffset.y);
					case 'bf':
						focusedChar=boyfriend;
						camFollow.setPosition(bfMid.x - stage.camOffset.x  + boyfriend.camOffset.x, bfMid.y - stage.camOffset.y + boyfriend.camOffset.y);
					case 'gf':
						focusedChar=gf;
						camFollow.setPosition(gfMid.x + gf.camOffset.x, gfMid.y + gf.camOffset.y);
				}
				if(currentOptions.camFollowsAnims){
					if(focusedChar.animation.curAnim!=null){
						switch (focusedChar.animation.curAnim.name){
							case 'singUP' | 'singUP-alt' | 'singUPmiss':
								camFollow.y -= 15 * focusedChar.camMovementMult;
							case 'singDOWN' | 'singDOWN-alt' | 'singDOWNmiss':
								camFollow.y += 15 * focusedChar.camMovementMult;
							case 'singLEFT' | 'singLEFT-alt' | 'singLEFTmiss':
								camFollow.x -= 15 * focusedChar.camMovementMult;
							case 'singRIGHT' | 'singRIGHT-alt' | 'singRIGHTmiss':
								camFollow.x += 15 * focusedChar.camMovementMult;
						}
					}
				}
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom,defaultCamZoom, Main.adjustFPS(0.05));
			camHUD.zoom = FlxMath.lerp(camHUD.zoom,1, Main.adjustFPS(0.05));
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// inst.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if(curSong == 'Spookeez'){
			switch (curStep){
				case 444,445:
					gf.playAnim("cheer",true);
					boyfriend.playAnim("hey",true);
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// inst.stop();
					// FlxG.switchState(new PlayState());
			}
		}
		playerStrums.forEach( function(spr:Receptor)
		{
			var pos = modManager.getReceptorPos(spr,0);
			var scale = modManager.getReceptorScale(spr,0);
			modManager.updateReceptor(spr, scale, pos);

			spr.point.x = pos.x;
			spr.point.y = pos.y;
			spr.scale.set(scale.x,scale.y);

			scale.put();
			pos.put();
		});

		dadStrums.forEach( function(spr:Receptor)
		{
			var pos = modManager.getReceptorPos(spr,1);
			var scale = modManager.getReceptorScale(spr,1);
			modManager.updateReceptor(spr, scale, pos);

			spr.point.x = pos.x;
			spr.point.y = pos.y;
			spr.scale.set(scale.x,scale.y);

			scale.put();
			pos.put();

		});

		// RESET = Quick Game Over Screen
		if (controls.RESET && currentOptions.resetKey)
		{
			health = 0;
			trace("RESET = True");
		}

		// CHEAT = brandon's a pussy
		if (controls.CHEAT)
		{
			health += 1;
			previousHealth = health;
			if(luaModchartExists && lua!=null)
				lua.setGlobalVar("health",health);
			trace("User is cheating!");
		}
		if(died)
			health=0;

		if(!died){
			if (health <= 0)
			{
				if(!currentOptions.noFail || (inCharter && startPos>0) ){
					died=true;
					boyfriend.stunned = true;

					persistentUpdate = false;
					persistentDraw = false;
					paused = true;

					vocals.stop();
					inst.stop();

					openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

					// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

					#if desktop
					// Game Over doesn't get his own variable because it's only used here
					DiscordClient.changePresence("Game Over - " + detailsText + songData.displayName + " (" + storyDifficultyText + ")", grade + " | Acc: " + truncateFloat(accuracy*100,2) + "%", iconRPC);
					#end
				}else{
					died=true;
					combo=0;
					showCombo();
					FlxG.sound.play(Paths.sound('fnf_loss_sfx'));
					var deathOverlay = new FlxSprite(0,0).makeGraphic(Std.int(FlxG.width*2),Std.int(FlxG.width*2),FlxColor.RED);
					deathOverlay.screenCenter(XY);
					deathOverlay.alpha = 0.6;
					add(deathOverlay);
					FlxTween.tween(deathOverlay, {alpha: 0}, 0.3, {
						onComplete: function(tween:FlxTween)
						{
							deathOverlay.destroy();
							FlxTween.tween(healthBar, {alpha: 0}, 0.7, {
								startDelay:1,
							});
						}
					});
					updateAccuracy();
				}
			}
		}

		while(unspawnNotes[0] != null)
		{
			if (Conductor.currentTrackPos-getPosFromTime(unspawnNotes[0].strumTime)>-3000)
			{
				var dunceNote:Note = unspawnNotes[0];

				renderedNotes.add(dunceNote);

				if(dunceNote.mustPress){
					playerNotes.push(dunceNote);
					playerNotes.sort((a,b)->Std.int(a.strumTime-b.strumTime));
				}

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);

			}else{
				break;
			}
		}

		var bfVar:Float=boyfriend.dadVar;

		if(boyfriend.animation.curAnim!=null){
			if (boyfriend.holdTimer > Conductor.stepCrochet * bfVar * 0.001 && !pressedKeys.contains(true) )
			{
				if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
				{
					boyfriend.dance();
				}
			}
		}

		if (generatedMusic)
		{
			if(startedCountdown){
				if(currentOptions.allowOrderSorting)
					renderedNotes.sort(sortByOrder);
				renderedNotes.forEachAlive(function(daNote:Note)
				{
					var revPerc:Float = modManager.get("reverse").getScrollReversePerc(daNote.noteData,daNote.mustPress==true?0:1);

					var strumLine = playerStrums.members[daNote.noteData];
					var isDownscroll = revPerc>.5;

					if(!daNote.mustPress){
						strumLine = dadStrums.members[daNote.noteData];
					}

					var notePos = modManager.getNotePos(daNote);
					var scale = modManager.getNoteScale(daNote);
					modManager.updateNote(daNote, scale, notePos);

					daNote.x = notePos.x;
					daNote.y = notePos.y;
					daNote.scale.copyFrom(scale);
					daNote.updateHitbox();
					scale.put();
					notePos.put();

					var shitGotHit = (daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit);
					var shit = strumLine.y + Note.swagWidth/2;
					if(daNote.isSustainNote){
						if(shitGotHit){
							var dY:Float = daNote.frameHeight;
							var dH:Float = strumLine.y+Note.swagWidth/2-daNote.y;
							dH /= daNote.scale.y;
							dY -= dH;

							var uH:Float = daNote.frameHeight*2;
							var uY:Float = strumLine.y+Note.swagWidth/2-daNote.y;

							uY /= daNote.scale.y;
							uH -= uY;

							var clipRect = new FlxRect(0,0,daNote.width*2,0);
							clipRect.y = CoolUtil.scale(revPerc,0,1,uY,dY);
							clipRect.height = CoolUtil.scale(revPerc,0,1,uH,dH);

							daNote.clipRect=clipRect;
						}
					}

					if (daNote.y > FlxG.height)
					{
						daNote.visible = false;
					}
					else
					{
						if((daNote.mustPress || !daNote.mustPress && !currentOptions.middleScroll)){
							daNote.visible = true;
						}
					}


					if(!daNote.mustPress && currentOptions.middleScroll){
						daNote.visible=false;
					}

					if(daNote.isSustainNote ){
						if(daNote.tooLate)
							daNote.desiredAlpha = .3;
					}else{
						if(daNote.tooLate)
							daNote.desiredAlpha = .3;
					}

					if (!daNote.mustPress && daNote.canBeHit && !daNote.wasGoodHit)
					{
						dadStrums.forEach(function(spr:Receptor)
						{
							if (Math.abs(daNote.noteData) == spr.ID)
							{
								//spr.playAnim('confirm', true);
								spr.playNote(daNote);
							}
						});

						var altAnim:String = "";

						if (SONG.notes[Math.floor(curStep / 16)] != null)
						{
							if (SONG.notes[Math.floor(curStep / 16)].altAnim)
								altAnim = '-alt';
						}

						switch(daNote.noteType){
							case 'alt':
								altAnim='-alt';
							case 'mine':
								// this really SHOULDN'T happen, but..
								health += 0.25; // they hit a mine, not you
						}

						health -= modchart.opponentHPDrain;

							//if(!daNote.isSustainNote){

							var anim = "";
							switch (Math.abs(daNote.noteData))
							{
							case 0:
								//dad.playAnim('singLEFT' + altAnim, true);
								anim='singLEFT' + altAnim;
							case 1:
								//dad.playAnim('singDOWN' + altAnim, true);
								anim='singDOWN' + altAnim;
							case 2:
								//dad.playAnim('singUP' + altAnim, true);
								anim='singUP' + altAnim;
							case 3:
								//dad.playAnim('singRIGHT' + altAnim, true);
								anim='singRIGHT' + altAnim;
							}
							if(opponent.animation.getByName(anim)==null){
								anim = anim.replace(altAnim,"");
							}

							if(luaModchartExists && lua!=null){
								lua.call("dadNoteHit",[Math.abs(daNote.noteData),daNote.strumTime,Conductor.songPosition,anim]); // TODO: Note lua class???
							}
						if(opponent.animation.curAnim!=null){
							var canHold = daNote.isSustainNote && opponent.animation.getByName(anim+"Hold")!=null;
							if(canHold && !opponent.animation.curAnim.name.startsWith(anim)){
								opponent.playAnim(anim,true);
							}else if(currentOptions.pauseHoldAnims && !canHold){
								opponent.playAnim(anim,true);

								if(daNote.holdParent && !daNote.isSustainEnd())
									opponent.holding=true;
								else{
									opponent.holding=false;
								}
							}else if(!currentOptions.pauseHoldAnims && !canHold){
								opponent.playAnim(anim,true);
							}
						}

						//}
						opponent.holdTimer = 0;

						if (SONG.needsVoices)
							vocals.volume = 1;
						daNote.wasGoodHit=true;
						lastHitDadNote=daNote;
						if(!daNote.isSustainNote){
							destroyNote(daNote);
						}else if(daNote.mustPress){
							//susNoteLanes[daNote.noteData].remove(daNote);
						}
					}

					if(daNote!=null && daNote.alive){
						if (daNote.tooLate || daNote.wasGoodHit && (isDownscroll && daNote.y>strumLine.y+daNote.height || !isDownscroll && daNote.y<strumLine.y-daNote.height))
						{
							if (daNote.tooLate && daNote.causesMiss)
							{
								//health -= 0.0475;
								noteMiss(daNote.noteData);
								if(!daNote.isSustainNote){
									if(currentOptions.accuracySystem==2){
										if(!daNote.isSustainNote){
											totalNotes+=2;
											hitNotes+=ScoreUtils.malewifeMissWeight;
										}
									}else{
										hitNotes+=judgeMan.getJudgementAccuracy("miss");
										if(currentOptions.accuracySystem!=1)
											totalNotes++;
									}
								}

								vocals.volume = 0;
								updateAccuracy();
							}
							destroyNote(daNote);
						}

					}
				});
			}
		}
		if(lastHitDadNote==null || !lastHitDadNote.alive || !lastHitDadNote.exists ){
			lastHitDadNote=null;
		}
		dadStrums.forEach(function(spr:Receptor)
		{

			if (spr.animation.finished && spr.animation.curAnim.name=='confirm' && (lastHitDadNote==null || !lastHitDadNote.isSustainNote || lastHitDadNote.animation.curAnim==null || lastHitDadNote.animation.curAnim.name.endsWith("end")))
			{
				spr.playAnim('static',true);
			}

		});

		if (!inCutscene){
			if(ScoreUtils.botPlay)
				botplay();


			if(pressedKeys.contains(true)){
				for(idx in 0...pressedKeys.length){
					var isHeld = pressedKeys[idx];
					if(isHeld)
						for(daNote in getHittableHolds(idx))
							noteHit(daNote);
				}
			}
		}

		if(currentOptions.ratingInHUD){
			camRating.zoom = camHUD.zoom;
		}else{
			camRating.zoom = camGame.zoom;
		}
		camReceptor.zoom = camHUD.zoom;
		camNotes.zoom = camReceptor.zoom;
		camSus.zoom = camNotes.zoom;


		if(luaModchartExists && lua!=null){
			lua.setGlobalVar("curDecBeat",curDecBeat);
			lua.setGlobalVar("curDecStep",curDecStep);

			lua.call("update",[elapsed]);
		}

		if(Conductor.rawSongPos>=inst.length){
			if(inst.volume>0 || vocals.volume>0)
				endSong();

			inst.volume=0;
			vocals.volume=0;
		}
		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}

	function endSong():Void
	{
		canPause = false;
		inst.volume = 0;
		vocals.volume = 0;
		inst.stop();

		#if cpp
		if(lua!=null){
			lua.destroy();
			lua=null;
		}
		#end
		if (SONG.validScore && !died && canScore)
		{
			#if !switch
			Highscore.saveScore(songData.chartName, songScore, storyDifficulty);
			#end
		}

		if(inCharter){
			inst.pause();
			vocals.pause();
			FlxG.switchState(new ChartingState(charterPos));
		}else{
			if (isStoryMode)
			{
				if(!died && canScore)
					campaignScore += songScore;

				gotoNextStory();

				if (storyPlaylist.length <= 0)
				{

					FlxG.sound.playMusic(Paths.music('freakyMenu'));

					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;

					FlxG.switchState(new StoryMenuState());

					// if ()
					StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

					if (SONG.validScore && !died && canScore)
					{
						//NGio.unlockMedal(60961);
						Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
					}

					FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
					FlxG.save.flush();
				}
				else
				{

					if (songData.chartName.toLowerCase() == 'eggnog')
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					prevCamFollow = camFollow;

					inst.stop();

					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
				FlxG.switchState(new FreeplayState());
			}
		}
	}


	var endingSong:Bool = false;
	var prevComboNums:Array<String> = [];

	private function showCombo(){
		var seperatedScore:Array<String> = Std.string(combo).split("");

		// WHY DOES HAXE NOT HAVE A DECREMENTING FOR LOOP
		// WHAT THE FUCK
		while(comboSprites.length>0){
			comboSprites[0].kill();
			comboSprites.remove(comboSprites[0]);
		}
		var placement:String = Std.string(combo);
		var ratingCameras = [camRating];
		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		if(currentOptions.ratingInHUD){
			coolText.scrollFactor.set(0,0);
			coolText.screenCenter();
		}

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (noteModifier=='pixel')
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		if(combo!=0){
			if(currentOptions.showComboCounter){
				var daLoop:Float = 0;
				var idx:Int = -1;
				for (i in seperatedScore)
				{
					idx++;
					if(i=='-'){
						i='negative';
					}
					//var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + i + pixelShitPart2));
					var numScore:Null<ComboSprite> = null;
					if(currentOptions.recycleComboJudges){
						numScore = comboBin.recycle(ComboSprite);
						numScore.setStyle(noteModifier);
					}else
						numScore = new ComboSprite(0,0,noteModifier);
					numScore.setup();
					numScore.number = i;
					numScore.screenCenter(XY);
					numScore.x = coolText.x + (43 * daLoop) - 90;
					numScore.y += 25;

					if(currentOptions.fcBasedComboColor){
						if(judgeMan.judgementCounter.get("miss")==0 && judgeMan.judgementCounter.get("bad")==0 && judgeMan.judgementCounter.get("shit")==0){
							if(judgeMan.judgementCounter.get("good")>0)
								numScore.color = 0x77E07E;
							else if(judgeMan.judgementCounter.get("sick")>0){
								numScore.color = 0x99F7F4;
							}
							else if(judgeMan.judgementCounter.get("epic")>0){
								numScore.color = 0xA97FDB;
							}
						}else{
							numScore.color = 0xFFFFFF;
						}
					}

					if (noteModifier!='pixel')
					{
						numScore.antialiasing = true;
						numScore.setGraphicSize(Std.int(numScore.width * 0.5));
					}
					else
					{
						numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom * .8));
					}
					numScore.updateHitbox();

					if(currentOptions.ratingInHUD){
						numScore.scrollFactor.set(0,0);
						numScore.y += 50;
						numScore.x -= 50;
					}
					numScore.cameras=ratingCameras;
					numScore.x += currentOptions.judgeX;
					numScore.y += currentOptions.judgeY;

					add(numScore);
					if(currentOptions.persistentCombo){
						comboSprites.push(numScore);
						if(prevComboNums[idx]!=i){
							numScore.y -= 30;
							FlxTween.tween(numScore, {y: numScore.y + 30}, 0.2, {
								ease: FlxEase.circOut
							});
						}

					}else{
						numScore.currentTween = FlxTween.tween(numScore, {alpha: 0}, 0.2, {
							onComplete: function(tween:FlxTween)
							{
								numScore.kill();
							//	numScore.destroy();
							},
							startDelay: Conductor.crochet * 0.002
						});
						numScore.acceleration.y = FlxG.random.int(200, 300);
						numScore.velocity.y -= FlxG.random.int(140, 160);
						numScore.velocity.x = FlxG.random.float(-5, 5);
					}

					daLoop++;
				}
			}
			prevComboNums = seperatedScore;
		}
	}

	var judge:FlxSprite;

	private function popUpScore(daRating:String,?noteDiff:Float):Void
	{
		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (noteModifier=='pixel')
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		var ratingCameras = [camRating];
		if(currentOptions.showRatings){
			var rating:Null<JudgeSprite> = null;

			if(currentOptions.recycleComboJudges){
				rating = judgeBin.recycle(JudgeSprite);
				rating.setStyle(noteModifier);
			}else
				rating = new JudgeSprite(0,0,noteModifier);//judgementSprites.recycle(JudgeSprite);


			rating.setup();
			rating.judgement = daRating;
			rating.screenCenter();
			rating.x = coolText.x - 40;
			rating.y -= 60;
			add(rating);


			if (noteModifier!='pixel')
			{
				rating.setGraphicSize(Std.int(rating.width * 0.7));
				rating.antialiasing = true;
			}
			else
			{
				rating.setGraphicSize(Std.int(rating.width * daPixelZoom * .7));
			}

			rating.updateHitbox();

			if(currentOptions.ratingInHUD){
				coolText.scrollFactor.set(0,0);
				rating.scrollFactor.set(0,0);

				rating.screenCenter();
				coolText.screenCenter();
				rating.y -= 25;
			}

			rating.x += currentOptions.judgeX;
			rating.y += currentOptions.judgeY;

			if(currentOptions.smJudges){
				if(judge!=null && judge.alive){
					judge.kill();
				}
				var scaleX = rating.scale.x;
				var scaleY = rating.scale.y;
				rating.scale.scale(1.1);
				if(rating.currentTween!=null && rating.currentTween.active){
					rating.currentTween.cancel();
					rating.currentTween=null;
				}
				rating.currentTween = FlxTween.tween(rating, {"scale.x": scaleX, "scale.y": scaleY}, 0.1, {
					onComplete: function(tween:FlxTween)
					{
						if(rating.alive && rating.currentTween==tween){
							rating.currentTween = FlxTween.tween(rating, {"scale.x": 0, "scale.y": 0}, 0.2, {
								onComplete: function(tween:FlxTween)
								{
									rating.kill();
									//rating.destroy();
									if(judge==rating)judge=null;
								},
								ease: FlxEase.quadIn,
								startDelay: 0.6
							});
						}
					},
					ease: FlxEase.quadOut
				});

			}else{
				rating.currentTween = FlxTween.tween(rating, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						rating.kill();
					//	rating.destroy();
					},
					startDelay: Conductor.crochet * 0.001
				});
				rating.acceleration.y = 550;
				rating.velocity.y -= FlxG.random.int(140, 175);
				rating.velocity.x -= FlxG.random.int(0, 10);
			}

			judge=rating;

			rating.cameras=ratingCameras;
			coolText.cameras=ratingCameras;

		}else{

			coolText.cameras=ratingCameras;
			if(currentOptions.ratingInHUD){
				coolText.scrollFactor.set(0,0);
				coolText.screenCenter();
			}
		}

		showCombo();
		var daLoop:Float=0;
		if(currentOptions.showMS && noteDiff!=null){
			var displayedMS = truncateFloat(noteDiff,2);
			var seperatedMS:Array<String> = Std.string(displayedMS).split("");
			for (i in seperatedMS)
			{
				if(i=="."){
					i = "point";
					daLoop-=.5;
				}
				if(i=='-'){
					i='negative';
					daLoop--;
				}

			//	var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + i + pixelShitPart2));
				var numScore:Null<ComboSprite> = null;
				if(currentOptions.recycleComboJudges){
					numScore = comboBin.recycle(ComboSprite);
					numScore.setStyle(noteModifier);
				}else
					numScore = new ComboSprite(0,0,noteModifier);

				numScore.setup();
				numScore.number = i;
				numScore.screenCenter();
				numScore.x = coolText.x + (32 * daLoop) + 15;
				numScore.y += 50;

				if(i=='point'){
					if(noteModifier!="pixel")
						numScore.x += 25;
					else{
						//numScore.y += 35;
						numScore.x += 24;
					}
				}


				switch(daRating){
					case 'epic':
						numScore.color = 0xC182FF;
					case 'sick':
						numScore.color = 0x00ffff;
					case 'good':
						numScore.color = 0x14cc00;
					case 'bad':
						numScore.color = 0xa30a11;
					case 'shit':
						numScore.color = 0x5c2924;
					default:
						numScore.color = 0xFFFFFF;
				}

				if (noteModifier!='pixel')
				{
					numScore.antialiasing = true;
					numScore.setGraphicSize(Std.int((numScore.width * 0.5)*.75));
				}
				else
				{
					numScore.setGraphicSize(Std.int((numScore.width * daPixelZoom * .8)*.75));
				}
				numScore.updateHitbox();

				numScore.acceleration.y = FlxG.random.int(100, 150);
				numScore.velocity.y -= FlxG.random.int(50, 75);
				numScore.velocity.x = FlxG.random.float(-2.5, 2.5);

				if(currentOptions.ratingInHUD){
					numScore.y += 10;
					numScore.x += 75;
					numScore.scrollFactor.set(0,0);
				}

				numScore.x += currentOptions.judgeX;
				numScore.y += currentOptions.judgeY;

				numScore.cameras=ratingCameras;

				add(numScore);

				numScore.currentTween = FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.kill();
						//numScore.destroy();
					},
					startDelay: Conductor.crochet * 0.0005
				});

				daLoop++;
			}
		}
		/*
			trace(combo);
			trace(seperatedScore);
		 */

		// add(coolText);

		coolText.destroy();



		updateAccuracy();
		curSection += 1;
	}

	function updateReceptors(){
		playerStrums.forEach(function(spr:Receptor)
		{
			if(pressedKeys[spr.ID] && spr.animation.curAnim.name!="confirm" && spr.animation.curAnim.name!="pressed" )
				spr.playAnim("pressed");

			if(!pressedKeys[spr.ID]){
				spr.playAnim("static");
			}
		});
	}

	private function keyPress(event:KeyboardEvent){
		#if !NO_BOTPLAY
		if(event.keyCode == FlxKey.F6){
			ScoreUtils.botPlay = !ScoreUtils.botPlay;
		}
		#end
		if(ScoreUtils.botPlay)return;
		var direction = bindData.indexOf(event.keyCode);
		if(direction!=-1 && !pressedKeys[direction]){
			pressedKeys[direction]=true;
			handleInput(direction);
			updateReceptors();
		}

	}

	private function keyRelease(event:KeyboardEvent){
		if(ScoreUtils.botPlay)return;
		var direction = bindData.indexOf(event.keyCode);
		if(direction!=-1 && pressedKeys[direction]){
			pressedKeys[direction]=false;
			updateReceptors();
		}
	}

	private function handleInput(direction:Int){
		if(direction!=-1){
			var hitting:Array<Note> = getHittableNotes(direction,true);
			hitting.sort((a,b)->Std.int(a.strumTime-b.strumTime)); // SHOULD be in order?
			// But just incase, we do this sort

			// TODO: chord cohesion, maybe
			if(hitting.length>0){
				boyfriend.holdTimer=0;
				for(hit in hitting){
					noteHit(hit);
					break;
				}
			}else{
				if(currentOptions.ghosttapSounds)
					FlxG.sound.play(Paths.sound('Ghost_Hit'),currentOptions.hitsoundVol/100);

				if(currentOptions.ghosttapping==false)
					badNoteCheck();
			}

		}
	}

	private function botplay(){
		var holdArray:Array<Bool> = [false,false,false,false];
		var controlArray:Array<Bool> = [false,false,false,false];
		for(note in playerNotes){
			if(note.mustPress && note.canBeHit && note.strumTime<=Conductor.songPosition+5){
				if(note.sustainLength>0 && botplayHoldMaxTimes[note.noteData]<note.sustainLength){
					controlArray[note.noteData]=true;
					botplayHoldTimes[note.noteData] = (note.sustainLength/1000)+.1;
				}else if(note.isSustainNote && botplayHoldMaxTimes[note.noteData]==0){
					holdArray[note.noteData] = true;
				}
				if(!note.isSustainNote){
					controlArray[note.noteData]=true;
					if(botplayHoldTimes[note.noteData]<=.2){
						botplayHoldTimes[note.noteData] = .2;
					}
				}
			}
		}

		for(idx in 0...botplayHoldTimes.length){
			if(botplayHoldTimes[idx]>0){
				pressedKeys[idx]=true;
				botplayHoldTimes[idx]-=FlxG.elapsed;
			}else{
				pressedKeys[idx]=false;
			}
		}

		for(idx in 0...controlArray.length){
			var pressed = controlArray[idx];
			if(pressed)
				handleInput(idx);
		}

		updateReceptors();
	}

	function getHittableNotes(direction:Int=-1,excludeHolds:Bool=false){
		var notes:Array<Note>=[];
		for(note in playerNotes){
			if(note.canBeHit && note.alive && !note.wasGoodHit && !note.tooLate && (direction==-1 || note.noteData==direction) && (!excludeHolds || !note.isSustainNote)){
				notes.push(note);
			}
		}
		return notes;
	}

	function getHittableHolds(?direction:Int=-1){
		var sustains:Array<Note>=[];
		for(note in getHittableNotes()){
			if(note.isSustainNote){
				sustains.push(note);
			}
		}
		return sustains;
	}

	function showMiss(direction:Int){
		boyfriend.holding=false;
		switch (direction)
		{
			case 0:
				boyfriend.playAnim('singLEFTmiss', true);
			case 1:
				boyfriend.playAnim('singDOWNmiss', true);
			case 2:
				boyfriend.playAnim('singUPmiss', true);
			case 3:
				boyfriend.playAnim('singRIGHTmiss', true);
		}
	}

	function noteMiss(direction:Int = 1):Void
	{
		health += judgeMan.getJudgementHealth('miss');
		judgeMan.judgementCounter.set("miss",judgeMan.judgementCounter.get("miss")+1);
		updateJudgementCounters();
		previousHealth=health;
		if(luaModchartExists && lua!=null){
			lua.call("noteMiss",[direction]);
		}
		if (combo > 5 && gf.animOffsets.exists('sad'))
		{
			gf.playAnim('sad');
		}
		combo = 0;
		showCombo();

		songScore += judgeMan.getJudgementScore('miss');

		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.3, 0.6));

		updateAccuracy();
		showMiss(direction);
	}

	function badNoteCheck()
	{
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;
		if(currentOptions.accuracySystem==2){
			hitNotes-=2;
		}else{
			hitNotes--;
		}
		if (leftP)
			noteMiss(0);
		if (downP)
			noteMiss(1);
		if (upP)
			noteMiss(2);
		if (rightP)
			noteMiss(3);
	}


	function noteHit(note:Note):Void
	{
		if (!note.wasGoodHit){
			var diff = note.strumTime - Conductor.songPosition;
			switch(note.noteType){
				case 'mine':
					hurtNoteHit(note);
				case 'alt':
					trace("woo alt");
					goodNoteHit(note,diff,true);
				default:
					goodNoteHit(note,diff,false);
			}
			var judge = judgeMan.determine(diff);

			note.wasGoodHit=true;
			playerStrums.forEach(function(spr:Receptor)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.playNote(note,(currentOptions.useNotesplashes && !note.isSustainNote)?(judge=='sick' || judge=='epic'):false);
				}
			});
			updateReceptors();

			if (!note.isSustainNote)
			{
				note.kill();
				if(note.mustPress){
					//noteLanes[note.noteData].remove(note);
					playerNotes.remove(note);
				}
				renderedNotes.remove(note, true);
				note.destroy();
			}else if(note.mustPress){
			//	susNoteLanes[note.noteData].remove(note);
			}
		}

	}

	function updateJudgementCounters(){
		for(judge in counters.keys()){
			var txt = counters.get(judge);
			var name:String = JudgementManager.judgementDisplayNames.get(judge);
			if(name==null){
				name = '${judge.substring(0,1).toUpperCase()}${judge.substring(1,judge.length)}';
			}
			txt.text = '${name}: ${judgeMan.judgementCounter.get(judge)}';
			txt.x=0;
		}
	}

	function hurtNoteHit(note:Note):Void{
		health -= 0.25;
		judgeMan.judgementCounter.set("miss",judgeMan.judgementCounter.get("miss")+1);
		updateJudgementCounters();
		previousHealth=health;
		if(luaModchartExists && lua!=null){
			lua.call("hitMine",[note.noteData,note.strumTime,Conductor.songPosition,note.isSustainNote]);
		}
		if (combo > 5 && gf.animOffsets.exists('sad'))
		{
			gf.playAnim('sad');
		}
		combo = 0;
		showCombo();

		songScore -= 600;

		FlxG.sound.play(Paths.sound('mineExplode'), FlxG.random.float(0.5, 0.7));

		if(currentOptions.accuracySystem==2)
			hitNotes+=ScoreUtils.malewifeMineWeight;
		else
			hitNotes-=1.2;

		updateAccuracy();
		boyfriend.holding=false;
		if(boyfriend.animation.getByName("hurt")!=null)
			boyfriend.playAnim('hurt', true);
		else
			showMiss(note.noteData);
	}

	function goodNoteHit(note:Note,noteDiff:Float,altAnim:Bool=false):Void
	{
		var judgement = note.isSustainNote?judgeMan.determine(0):judgeMan.determine(noteDiff);

		var breaksCombo = judgeMan.shouldComboBreak(judgement);

		if(judgement=='miss'){
			return noteMiss(note.noteData);
		}

		vocals.volume = 1;

		if (!note.isSustainNote)
		{
			if(breaksCombo){
				combo=0;
				showCombo();
				judgeMan.judgementCounter.set('miss',judgeMan.judgementCounter.get('miss')+1);
			}else{
				combo++;
			}

			var score:Int = judgeMan.getJudgementScore(judgement);
			if(currentOptions.accuracySystem==2){
				var wifeScore = ScoreUtils.malewife(noteDiff,Conductor.safeZoneOffset/180);
				totalNotes+=2;
				hitNotes+=wifeScore;
			}else{
				if(currentOptions.accuracySystem!=1)
					totalNotes++;
				hitNotes+=judgeMan.getJudgementAccuracy(judgement);
			}
			if(ScoreUtils.botPlay){
				botplayScore+=score;
			}else{
				songScore += score;
			}
			judgeMan.judgementCounter.set(judgement,judgeMan.judgementCounter.get(judgement)+1);
			updateJudgementCounters();
			popUpScore(judgement,-noteDiff);
			if(combo>highestCombo)
				highestCombo=combo;

			highComboTxt.text = "Highest Combo: " + highestCombo;
		}

		if(currentOptions.hitSound && !note.isSustainNote)
			FlxG.sound.play(Paths.sound('Normal_Hit'),currentOptions.hitsoundVol/100);

		var strumLine = playerStrums.members[note.noteData%4];


		if(luaModchartExists && lua!=null){
			lua.call("goodNoteHit",[note.noteData,note.strumTime,Conductor.songPosition,note.isSustainNote]); // TODO: Note lua class???
		}

		if(!note.isSustainNote){
			health += judgeMan.getJudgementHealth(judgement);
		}

		if(health>2)
			health=2;

		previousHealth=health;

		//if(!note.isSustainNote){
		var anim = "";
		switch (note.noteData)
		{
		case 0:
			anim='singLEFT';
		case 1:
			anim='singDOWN';
		case 2:
			anim='singUP';
		case 3:
			anim='singRIGHT';
		}
		if(breaksCombo && !note.isSustainNote){
			anim+='miss';
			boyfriend.playAnim(anim,true);
		}else{
			if(altAnim && boyfriend.animation.getByName(anim+"-alt")!=null){
				anim+='-alt';
			}
			if(boyfriend.animation.curAnim!=null){
				var canHold = note.isSustainNote && boyfriend.animation.getByName(anim+"Hold")!=null;
				if(canHold && !boyfriend.animation.curAnim.name.startsWith(anim)){
					boyfriend.playAnim(anim,true);
				}else if(currentOptions.pauseHoldAnims && !canHold){
					boyfriend.playAnim(anim,true);
					if(note.holdParent ){
						boyfriend.holding=true;
					}else{
						boyfriend.holding=false;
					}
				}else if(!currentOptions.pauseHoldAnims && !canHold){
					boyfriend.playAnim(anim,true);
				}
			}
		}



		//}
		vocals.volume = 1;
		updateAccuracy();

	}

	var fastCarCanDrive:Bool = true;

	override function stepHit()
	{
		super.stepHit();
		if(luaModchartExists && lua!=null){
			lua.setGlobalVar("curStep",curStep);
			lua.call("stepHit",[curStep]);
		}
		if(!paused){
			if (inst != null && !startingSong){
				if (inst.time > Conductor.rawSongPos + 45 || inst.time < Conductor.rawSongPos - 45)
				{
					resyncVocals();
				}
			}
		}
	}

	override function beatHit()
	{
		super.beatHit();

		stage.beatHit(curBeat);

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
				if(luaModchartExists && lua!=null){
					lua.setGlobalVar("bpm",Conductor.bpm);
				}
			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			if(dad.animation.curAnim!=null)
				if (!dad.animation.curAnim.name.startsWith("sing"))
					dad.dance();

			for(opp in opponents){
				if(opp!=dad){
					if(opp.animation.curAnim!=null)
						if (!opp.animation.curAnim.name.startsWith("sing"))
							opp.dance();
				}
			}


		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		// HARDCODING FOR MILF ZOOMS!
		if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		healthBar.beatHit(curBeat);

		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
		}

		if(boyfriend.animation.curAnim!=null)
			if (!boyfriend.animation.curAnim.name.startsWith("sing"))
				boyfriend.dance();


		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);
		}

		/*if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}*/

		if(luaModchartExists && lua!=null){
			lua.setGlobalVar("curBeat",curBeat);
			lua.call("beatHit",[curBeat]);
		}
	}

	override function destroy(){
		center.put();

		super.destroy();
	}

	override function switchTo(next:FlxState){
		// Do all cleanup of stuff here! This makes it so you dont need to copy+paste shit to every switchState
		#if cpp
		if(lua!=null){
			lua.destroy();
			lua=null;
		}
		#end
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN,keyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP,keyRelease);

		return super.switchTo(next);
	}

	public static function setStoryWeek(data:WeekData,difficulty:Int){
		PlayState.inCharter=false;
		PlayState.startPos = 0;
		PlayState.charterPos = 0;
		storyPlaylist = data.getCharts();
		weekData = data;

		isStoryMode = true;
		storyDifficulty = difficulty;

		SONG = Song.loadFromJson(data.songs[0].formatDifficulty(difficulty), storyPlaylist[0].toLowerCase());
		storyWeek = weekData.weekNum;
		campaignScore = 0;

		PlayState.songData=data.songs[0];
	}

	public function gotoNextStory(){
		PlayState.inCharter=false;
		PlayState.startPos = 0;
		PlayState.charterPos = 0;

		storyPlaylist.remove(storyPlaylist[0]);
		if(storyPlaylist.length>0){
			var songData = weekData.getByChartName(storyPlaylist[0]);
			SONG = Song.loadFromJson(songData.formatDifficulty(storyDifficulty), songData.chartName.toLowerCase());

			PlayState.songData=songData;
		}
	}

	public static function setSong(song:SwagSong){
		SONG = song;
		var songData = new SongData(SONG.song,SONG.player2,storyWeek,SONG.song,'week${storyWeek}');

		weekData = new WeekData("Chart",songData.weekNum,'dad',[songData],'bf','gf',songData.loadingPath);
		PlayState.songData=songData;
	}

	public static function setFreeplaySong(songData:SongData,difficulty:Int){
		PlayState.inCharter=false;
		PlayState.startPos = 0;
		PlayState.charterPos = 0;
		PlayState.songData=songData;
		SONG = Song.loadFromJson(songData.formatDifficulty(difficulty), songData.chartName.toLowerCase());
		weekData = new WeekData("Freeplay",songData.weekNum,'dad',[songData],'bf','gf',songData.loadingPath);
		// TODO: maybe have a "setPlaylist" function which takes WeekData and have FreeplayState create a temporary one n shit
		// could also be used to have custom 'freeplay playlists' where you play multiple songs in a row without being in story mode
		// for now, this'll do

		isStoryMode = false;
		storyDifficulty = difficulty;
		storyWeek = songData.weekNum;
	}
}
