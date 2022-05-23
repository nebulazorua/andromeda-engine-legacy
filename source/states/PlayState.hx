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
import flixel.util.FlxAxes;
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
import Section.Event;

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

	public var luaFuncs:Array<String> = [];
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public var scrollSpeed:Float = 1;
	public var songSpeed:Float = 1;
	public var dontSync:Bool=false;
	public var currentTrackPos:Float = 0;
	public var currentVisPos:Float = 0;
	var halloweenLevel:Bool = false;
	public var stage:Stage;

	public var zoomBeatingInterval:Float = 4;
	public var zoomBeatingZoom:Float = 0.015;

	private var vocals:FlxSound;

	public var cameraLocked:Bool = false;
	public var cameraLockX:Float = 0;
	public var cameraLockY:Float = 0;

	public var camOffX:Float = 0;
	public var camOffY:Float = 0;

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

	public var noteSpawnTime:Float = 1000;
	private var camFollow:FlxObject;
	public var currentOptions:Options;

	private static var prevCamFollow:FlxObject;
	private var lastHitDadNote:Note;
	public var eventSchedule:Array<Event> = [];
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
	public var unnamedLuaObjects:Int=0;
	public var defaultLuaClasses:Array<Dynamic>;
	public var dadLua:LuaCharacter;
	public var gfLua:LuaCharacter;
	public var bfLua:LuaCharacter;
	public var gameCam3D:RaymarchEffect;
	public var hudCam3D:RaymarchEffect;
	public var noteCam3D:RaymarchEffect;

	public static var noteModifier:String='base';
	public static var uiModifier:String='base';
	var pressedKeys:Array<Bool> = [false,false,false,false];
	var justPressedKeys:Array<Bool> = [false,false,false,false];
	private var camZooming:Bool = true;
	private var curSong:String = "";

	private var gfSpeed:Int = 4;
	private var health:Float = 1;
	private var previousHealth:Float = 1;
	private var combo:Int = 0;
	private var highestCombo:Int = 0;
	private var healthBar:Healthbar;

	var canToggleBotplay:Bool = #if NO_BOTPLAY false #else true #end;

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
	private static var sliderVelocities:Array<Song.VelocityChange> = [];

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

	var forceDisableModchart:Bool=false;

	function setupLuaSystem(){
		if(forceDisableModchart)return;
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
			lua.setGlobalVar("crochet",Conductor.crochet);
			lua.setGlobalVar("stepCrochet",Conductor.stepCrochet);
			lua.setGlobalVar("XY","XY");
			lua.setGlobalVar("X","X");
			lua.setGlobalVar("Y","Y");
			lua.setGlobalVar("width",FlxG.width);
			lua.setGlobalVar("height",FlxG.height);

			lua.setGlobalVar("black",FlxColor.BLACK);
			lua.setGlobalVar("white",FlxColor.WHITE);

			var timerCount:Int = 0;
			Lua_helper.add_callback(lua.state,"startTimer", function(time: Float){
				// 1 = time
				// 2 = callback

				var name = 'timerCallbackNum${timerCount}';
				Lua.pushvalue(lua.state,2);
				Lua.setglobal(lua.state, name);
				luaFuncs.push(name);

				new FlxTimer().start(time, function(t:FlxTimer){
					callLua(name,[]);

				});

				timerCount++;

			});

			Lua_helper.add_callback(lua.state,"colorFromString", function(str:String){
				return Std.int(FlxColor.fromString(str));
			});

			Lua_helper.add_callback(lua.state,"doCountdown", function(?status:Int=3){
				doCountdown(status);
			});

			Lua_helper.add_callback(lua.state,"addQuick", function(name:String, val:Dynamic){
				FlxG.watch.addQuick(name, val);
			});

			Lua_helper.add_callback(lua.state,"log", function(string:String){
				FlxG.log.add(string);
			});

			Lua_helper.add_callback(lua.state,"playSound", function(sound:String,volume:Float=1,looped:Bool=false){
				var path = 'assets/songs/${PlayState.SONG.song.toLowerCase()}/$sound.${Paths.SOUND_EXT}';
				FlxG.sound.play(CoolUtil.getSound(path),volume,looped);
			});

			Lua_helper.add_callback(lua.state,"playInternalSound", function(sound:String,volume:Float=1,looped:Bool=false){
				FlxG.sound.play(Paths.sound(sound),volume,looped);
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
			// TODO: Deprecate and make a new one with better control (layerName, etc)
			Lua_helper.add_callback(lua.state,"newSprite", function(?x:Int=0,?y:Int=0, ?drawBehind:Bool=false, ?autoAdd:Bool=false, ?spriteName:String){
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
				}else if(autoAdd){
					add(sprite);
				};
			});

			Lua_helper.add_callback(lua.state,"newCamera", function(?x:Int=0, ?y:Int=0,?cameraName:String){
				var cam = new FNFCamera(x,y);
				cam.bgColor = FlxColor.TRANSPARENT;
				var name = "UnnamedCamera"+unnamedLuaObjects;

				if(cameraName!=null) name=cameraName;
				else unnamedLuaObjects++;

				var lCam = new LuaCam(cam, name);
				var classIdx = Lua.gettop(lua.state)+1;
				lCam.Register(lua.state);
				Lua.pushvalue(lua.state,classIdx);
				FlxG.cameras.add(cam);

				trace('new camera named $name added!!');
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

			var healthbar = new LuaHPBar(healthBar,"healthbar",true);
			var bfIcon = new LuaSprite(healthBar.iconP1,"iconP1",true);
			var dadIcon = new LuaSprite(healthBar.iconP2,"iconP2",true);

			var window = new LuaWindow();

			var luaRenderedNotes = new LuaGroup<Note>(renderedNotes,"renderedNotes",true);
			var luaGameCam = new LuaCam(FlxG.camera,"gameCam");
			var luaHUDCam = new LuaCam(camHUD,"HUDCam");
			var luaNotesCam = new LuaCam(camNotes,"notesCam");
			var luaSustainCam = new LuaCam(camSus,"holdCam");
			var luaReceptorCam = new LuaCam(camReceptor,"receptorCam");
			// TODO: a flat 'camera' object which'll affect the properties of every camera

			new LuaModMgr(modManager).Register(lua.state);

			defaultLuaClasses = [luaModchart,window,bfLua,gfLua,dadLua,bfIcon,dadIcon,luaGameCam,luaHUDCam,luaNotesCam,luaSustainCam,luaReceptorCam,luaRenderedNotes];

			for(i in defaultLuaClasses)
				i.Register(lua.state);


			lua.errorHandler = function(error:String){
				FlxG.log.advanced(error, EngineData.LUAERROR, true);
			}

			// this catches compile errors
			try {
				lua.runFile(Paths.modchart(songData.chartName.toLowerCase()));
			}catch (e:Exception){
				luaModchartExists=false; // modshart
				FlxG.log.advanced(e, EngineData.LUAERROR, true);
			};

			if(luaModchartExists && lua!=null)
					if(Main.getFPSCap()>180)
						Main.setFPSCap(180);

			Lua.pushvalue(lua.state, Lua.LUA_GLOBALSINDEX);
			Lua.pushnil(lua.state);
			while(Lua.next(lua.state, -2) != 0) {
				// key = -2
				// value = -1
				if(Lua.isfunction(lua.state, -1) && Lua.isstring(lua.state,-2)){
					var name:String = Lua.tostring(lua.state,-2);
					luaFuncs.push(name);
				}
        Lua.pop(lua.state, 1);
      }
      Lua.pop(lua.state,1);

		}
	}

	override public function create()
	{
		camGame = new FNFCamera();
		camRating = new FNFCamera();
		camHUD = new FNFCamera();
		camNotes = new FNFCamera();
		camSus = new FNFCamera();
		camReceptor = new FNFCamera();

		FadeTransitionSubstate.nextCamera = camHUD;
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

		if(inCharter){
			if(currentOptions.chartingBotplay)currentOptions.botPlay=true;
			if(!currentOptions.chartingDetails){
				currentOptions.noChars=true;
				currentOptions.noStage=true;
			}
			forceDisableModchart=currentOptions.chartingNoModshart;
		}

		if(currentOptions.botPlay)canToggleBotplay=true;

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
		camHUD.bgColor.alpha = 0;
		camNotes.bgColor.alpha = 0;
		camRating.bgColor.alpha = 0;
		camSus.bgColor.alpha = 0;
		camReceptor.bgColor.alpha = 0;
		pauseHUD = new FNFCamera();
		pauseHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		if(!currentOptions.ratingOverNotes)
			FlxG.cameras.add(camRating);
		if(currentOptions.holdsBehindReceptors)
			FlxG.cameras.add(camSus);
		FlxG.cameras.add(camReceptor);
		if(!currentOptions.holdsBehindReceptors)
			FlxG.cameras.add(camSus);
		FlxG.cameras.add(camNotes);
		if(currentOptions.ratingOverNotes)
			FlxG.cameras.add(camRating);

		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(pauseHUD);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		sliderVelocities = [];

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
		songSpeed = speed;
		for(vel in SONG.sliderVelocities)
			sliderVelocities.push(vel);

		for (section in SONG.notes)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);
			section.sectionNotes.sort((a,b)->Std.int(a[0]-b[0]));
			if(section.events!=null){
				section.events.sort((a,b)->Std.int(a.time-b.time));
				for(event in section.events){
					if(event.events!=null){
						for(ev in event.events){
							var daEvent = {
								time: event.time,
								args: ev.args,
								name: ev.name
							};
							eventPreInit(daEvent);
						}

					}else
						eventPreInit(event);
				}
			}
		}

		sliderVelocities.sort((a,b)->Std.int(a.startTime-b.startTime));
		mapVelocityChanges();

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);



		switch (songData.chartName.toLowerCase())
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'U se the arrow keys to keep up \nwith me singing.'];
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

		if(SONG.player1=='bf-neb')
			gfVersion = 'lizzy';


		gf = new Character(400, 130, gfVersion, false, !currentOptions.noChars);
		gf.scrollFactor.set(1,1);
		stage.gf=gf;

		dad = new Character(100, 100, SONG.player2, false, !currentOptions.noChars);
		opponent=dad;
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
			case 3:
				focus = 'center';
		}

		if(currentOptions.noChars){
			focus = 'center';
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


		modManager = new ModManager(this);

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
		healthBar.setColors(dad.iconColor,boyfriend.iconColor);

		if(currentOptions.downScroll)
			healthBar.y = FlxG.height*.1;



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

		upscrollOffset = 50;
		downscrollOffset = FlxG.height-165;

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;
		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		shownAccuracy = 100;
		if(currentOptions.accuracySystem==1){ // ITG
			totalNotes = ScoreUtils.GetMaxAccuracy(noteCounter);
			shownAccuracy = 0;
		}

		if(currentOptions.backTrans>0){
			var overlay = new FlxSprite(0,0).makeGraphic(Std.int(FlxG.width*2),Std.int(FlxG.width*2),FlxColor.BLACK);
			overlay.screenCenter(XY);
			overlay.alpha = currentOptions.backTrans/100;
			overlay.scrollFactor.set();
			add(overlay);
		}

		if(currentOptions.staticCam==0)
			focus = 'dad';
		updateCamFollow();


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

	public function swapCharacter(who:String, newCharacter:String){
		var sprite:Character = null;
		switch(who){
			case 'dad':
				sprite=dad;
			case 'bf' | 'boyfriend':
				who='bf';
				sprite=boyfriend;
			case 'gf' | 'girlfriend':
				who='gf';
				sprite=gf;
		}
		if(sprite!=null){
			var newSprite:Character;
			var spriteX = sprite.x;
			var spriteY = sprite.y;
			var offX = sprite.posOffset.x;
			var offY = sprite.posOffset.y;

			var newX = spriteX - offX;
			var newY = spriteY - offY;

			var currAnim:String = "idle";
			if(sprite.animation.curAnim!=null)
				currAnim=sprite.animation.curAnim.name;
			remove(sprite);
			// TODO: Make this BETTER!!!
			if(who=="bf"){
				boyfriend = new Boyfriend(newX,newY,newCharacter,boyfriend.hasSprite);
				newSprite = boyfriend;
				if(bfLua!=null)bfLua.sprite = boyfriend;
				//iconP1.changeCharacter(newCharacter);
			}else if(who=="dad"){
				var index = opponents.indexOf(dad);
				if(index>=0)opponents.remove(dad);
				dad = new Character(newX,newY,newCharacter, dad.isPlayer ,dad.hasSprite);
				newSprite = dad;
				if(dadLua!=null)dadLua.sprite = dad;
				if(index>=0)opponents.insert(index,dad);

				//iconP2.changeCharacter(newCharacter);
			}else if(who=="gf"){
				gf = new Character(newX,newY,newCharacter, gf.isPlayer ,gf.hasSprite);
				newSprite = gf;
				if(gfLua!=null)gfLua.sprite = gf;
			}else{
				newSprite = new Character(newX,newY,newCharacter);
			}

			newSprite.x += newSprite.posOffset.x;
			newSprite.y += newSprite.posOffset.y;
			healthBar.setIcons(boyfriend.iconName,dad.iconName);
			healthBar.setColors(dad.iconColor,boyfriend.iconColor);

			add(newSprite);
			if(currAnim!="idle" && !currAnim.startsWith("dance")){
				newSprite.playAnim(currAnim,true);
			}else if(currAnim=='idle' || currAnim.startsWith("dance")){
				newSprite.dance();
			}

			return newSprite;

		}
		return null;
	}
	// shit bandaid solution

	public function swapCharacterByLuaName(spriteName:String,newCharacter:String){
		var sprite = luaSprites[spriteName];
		if(spriteName == 'bf' || spriteName == 'gf' || spriteName =='dad'){
			var newChar = swapCharacter(spriteName,newCharacter);
			luaSprites[spriteName] = newChar;
			return;
		}
		if(sprite!=null){
			var newSprite:Character;
			var spriteX = sprite.x;
			var spriteY = sprite.y;
			var offX = sprite.posOffset.x;
			var offY = sprite.posOffset.y;

			var newX = spriteX - offX;
			var newY = spriteY - offY;

			var currAnim:String = "idle";
			if(sprite.animation.curAnim!=null)
				currAnim=sprite.animation.curAnim.name;
			remove(sprite);
			// TODO: Make this BETTER!!!
			newSprite = new Character(newX,newY,newCharacter);


			newSprite.x += newSprite.posOffset.x;
			newSprite.y += newSprite.posOffset.y;
			healthBar.setIcons(boyfriend.iconName,dad.iconName);
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
		var countdownStatus:Int = 3; // 3 = show entire countdown. 2 = only sounds, 1 = non-visual countdown, 0 = skip countdown
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN,keyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP,keyRelease);

		inCutscene = false;

		generateStaticArrows(0, 1);
		generateStaticArrows(1, 0);

		modManager.setReceptors();
		modManager.registerModifiers();

		var toRemove:Array<Section.Event> = [];
		for(event in eventSchedule){
			var shouldKeep = eventPostInit(event);
			if(!shouldKeep)toRemove.push(event);
		}
		for(shit in toRemove)
			eventSchedule.remove(shit);

		if(!forceDisableModchart){
			#if FORCE_LUA_MODCHARTS
			setupLuaSystem();
			#else
			if(currentOptions.loadModcharts)
				setupLuaSystem();
			#end
		}else{
			luaModchartExists=false;
		}

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
		Conductor.songPosition=Conductor.rawSongPos + currentOptions.noteOffset;
		updateCurStep();
		updateBeat();

		if(startPos>0)canScore=false;

		if(luaModchartExists && lua!=null){
			var luaStatus:Dynamic = callLua("startCountdown",[]);
			switch(luaStatus){
				case 'all' | 3:
					countdownStatus = 3;
				case 'sound' | 2:
					countdownStatus = 2;
				case 'hidden' | 1:
					countdownStatus = 1;
				case 'skip' | 0:
					countdownStatus = 0;
				case 'stop' | -1:
					countdownStatus = -1;
				default:
					countdownStatus = 3;
			}
		}

		startTimer = new FlxTimer();

		if(countdownStatus==-1)return;

		doCountdown(countdownStatus);
	}

	function doCountdown(countdownStatus:Int=3){
		if(startTimer==null)
			startTimer = new FlxTimer();


		if(countdownStatus==0){
			Conductor.rawSongPos = startPos;
			Conductor.songPosition=Conductor.rawSongPos + currentOptions.noteOffset;
			updateCurStep();
			updateBeat();
			return;
		}


		var swagCounter:Int = 0;
		startTimer.start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			if(luaModchartExists && lua!=null)
				callLua("countdown",[swagCounter]);

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
			if(countdownStatus>1){
				switch (swagCounter)

				{
					case 0:
						if(countdownStatus>=2)
							FlxG.sound.play(Paths.sound('intro3${altSuffix}'), 0.6);
					case 1:
						if(countdownStatus>=3){
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
						}
						if(countdownStatus>=2)
							FlxG.sound.play(Paths.sound('intro2${altSuffix}'), 0.6);
					case 2:
						if(countdownStatus>=3){
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
						}
						if(countdownStatus>=2)
							FlxG.sound.play(Paths.sound('intro1${altSuffix}'), 0.6);
					case 3:
						if(countdownStatus>=3){
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
						}
						if(countdownStatus>=2)
							FlxG.sound.play(Paths.sound('introGo${altSuffix}'), 0.6);
					case 4:
				}
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
		Conductor.songPosition=Conductor.rawSongPos + currentOptions.noteOffset;
		updateCurStep();
		updateBeat();

		if(FlxG.sound.music!=null){
			FlxG.sound.music.stop();
		}

		#if desktop
		// Song duration in a float, useful for the time left feature
		songLength = inst.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText + songData.displayName + " (" + storyDifficultyText + ")", grade + " | Acc: " + CoolUtil.truncateFloat(accuracy*100,2) + "%", iconRPC, true, songLength);
		#end
	}

	var debugNum:Int = 0;

	function eventPreInit(event:Event){
		switch(event.name){
			case 'Scroll Velocity':
				switch(event.args[0]){
					case 'mult':
						var multiplier:Float = event.args[1];
						sliderVelocities.push({
							startTime: event.time,
							multiplier: multiplier
						});
					case 'constant':
						sliderVelocities.push({
							startTime: event.time,
							multiplier: event.args[1] / songSpeed
						});
				}
		}
	}

	function eventPostInit(event: Event):Bool
	{
		switch(event.name){
			case 'Set Modifier':
				var step = Conductor.getStep(event.time);
				var player:Int = 0;
				switch(event.args[2]){
					case 'player':
						player = 0;
					case 'opponent':
						player = 1;
					case 'both':
						player = -1;
				}
				modManager.queueSet(step, event.args[0], event.args[1], player);
				return false;
			case 'Ease Modifier':
				var step = Conductor.getStep(event.time);
				var player:Int = 0;
				switch(event.args[4]){
					case 'player':
						player = 0;
					case 'opponent':
						player = 1;
					case 'both':
						player = -1;
				}
				modManager.queueEase(step, step+event.args[2], event.args[0], event.args[1], event.args[3], player);
				return false;
			default:
			// nothing
		}
		return true;
	}

	function eventInit(event: Event):Bool
	{
		switch(event.name){
			case 'Change Character':
				var cache = new Character(-9000, -9000, event.args[1], event.args[0]=='bf');
				cache.alpha=1/9999;
				add(cache);
				remove(cache);
			default:
			// nothing
		}
		return true;
	}

	private function destroyNote(daNote:Note){
		daNote.active = false;
		daNote.visible = false;

		daNote.kill();

		renderedNotes.remove(daNote,true);
		if(daNote.mustPress)
			playerNotes.remove(daNote);


		if(daNote.parent!=null && daNote.parent.tail.contains(daNote))
			daNote.parent.tail.remove(daNote);


		if(daNote.parent!=null && daNote.parent.unhitTail.contains(daNote))
			daNote.parent.unhitTail.remove(daNote);

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
		var func = Math.round;
		if(!currentOptions.fixHoldSegCount)func=Math.floor;
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);
			section.sectionNotes.sort((a,b)->Std.int(a[0]-b[0]));
			if(section.events!=null){
				section.events.sort((a,b)->Std.int(a.time-b.time));
				for(event in section.events){
					if(event.events!=null){
						var pushingEvents = [];
						for(ev in event.events){
							var shouldKeep = eventInit(ev);
							if(shouldKeep){
								pushingEvents.push({
									time: event.time,
									args: ev.args,
									name: ev.name
								});
							}
							for(e in pushingEvents)eventSchedule.push(e);
							//if(shouldSchedule)eventSchedule.push(event);
						}
					}else{
						var shouldSchedule = eventInit(event);
						if(shouldSchedule)eventSchedule.push(event);
					}
				}
			}
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				if(daNoteData==-1)continue; // thanks PSYCH.
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

				var swagNote:Note = new Note(daStrumTime, daNoteData, currentOptions.noteSkin, noteModifier, EngineData.noteTypes[songNotes[3]], oldNote, false, songNotes[4]==true, getPosFromTime(daStrumTime));
				swagNote.sustainLength = func(songNotes[2] / Conductor.stepCrochet) * Conductor.stepCrochet;
				swagNote.scrollFactor.set(0, 0);
				swagNote.shitId = unspawnNotes.length;
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

				if(Math.round(susLength)>0){
					for (susNote in 0...Math.round(susLength))
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
						var sussy = daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet;
						var sustainNote:Note = new Note(sussy, daNoteData, currentOptions.noteSkin, noteModifier, EngineData.noteTypes[songNotes[3]], oldNote, true, swagNote.isRoll, getPosFromTime(sussy));
						sustainNote.parent = swagNote;
						sustainNote.cameras = [camSus];
						sustainNote.scrollFactor.set();
						unspawnNotes.push(sustainNote);
						sustainNote.isRoll = swagNote.isRoll;
						sustainNote.shitId = unspawnNotes.length;
						sustainNote.segment = swagNote.tail.length;
						swagNote.tail.push(sustainNote);
						swagNote.unhitTail.push(sustainNote);

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
				}else
					swagNote.isRoll=false;


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

		var removing:Array<Note>=[];
		for(note in unspawnNotes){
			if(note.strumTime<startPos && !note.isSustainNote || note.isSustainNote && removing.contains(note.parent) && !removing.contains(note)){
				removing.push(note);
			}
		}
		for(note in removing){
			unspawnNotes.remove(note);
			if(note.tail.length>0){
				for(tail in note.tail){
					unspawnNotes.remove(tail);
					destroyNote(tail);
				}
			}

			destroyNote(note);

		}


		if(eventSchedule.length>1)
			eventSchedule.sort(sortByEvents);


		generatedMusic = true;

		updateAccuracy();
	}

	function sortByEvents(Obj1:Event, Obj2:Event):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.time, Obj2.time);
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByStrum(wat:Int, Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.DESCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByOrder(wat:Int, Obj1:FNFSprite, Obj2:FNFSprite):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.zIndex, Obj2.zIndex);
	}

	function sortByZ(wat:Int, Obj1:FNFSprite, Obj2:FNFSprite):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.z, Obj2.z);
	}

	// ADAPTED FROM QUAVER!!!
	// https://github.com/Quaver/Quaver
	// https://github.com/Quaver/Quaver
	// https://github.com/Quaver/Quaver
	function mapVelocityChanges(){
		if(sliderVelocities.length==0)
			return;

		var pos:Float = sliderVelocities[0].startTime*(SONG.initialSpeed);
		velocityMarkers.push(pos);
		for(i in 1...sliderVelocities.length){
			pos+=(sliderVelocities[i].startTime-sliderVelocities[i-1].startTime)*(SONG.initialSpeed*sliderVelocities[i-1].multiplier);
			velocityMarkers.push(pos);
		}
	};
	// https://github.com/Quaver/Quaver
	// https://github.com/Quaver/Quaver
	// https://github.com/Quaver/Quaver
	// ADAPTED FROM QUAVER!!!

	private function generateStaticArrows(player:Int, pN:Int):Void
	{
		for (i in 0...4)
		{
			var dirs = ["left","down","up","right"];
			var clrs = ["purple","blue","green","red"];

			var babyArrow:Receptor = new Receptor(0, 100, i, currentOptions.noteSkin, noteModifier, Note.noteBehaviour);
			babyArrow.playerNum = pN;
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
			babyArrow.x = getXPosition(0, i, pN);

			newStrumLine.x = babyArrow.x;

			babyArrow.defaultX = babyArrow.x;
			babyArrow.defaultY = babyArrow.y;

			babyArrow.desiredX = babyArrow.x;
			babyArrow.desiredY = babyArrow.y;
			//babyArrow.point = FlxPoint.get(0,0);

			if (!isStoryMode)
			{
				babyArrow.yOffset -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow,{yOffset: babyArrow.yOffset + 10, alpha:1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
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
			if(judgeMan.judgementCounter.get("bad")+judgeMan.judgementCounter.get("shit")>=noteCounter.get("taps")/2 && noteCounter.get("taps")>0)
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
			if (inst != null && !startingSong)
			{
				Conductor.rawSongPos = inst.time;
				Conductor.songPosition = (Conductor.rawSongPos+currentOptions.noteOffset);
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

			if(!startingSong)
				resyncVocals();


			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText + songData.displayName + " (" + storyDifficultyText + ")", grade + " | Acc: " + CoolUtil.truncateFloat(accuracy*100,2) + "%", iconRPC, true, songLength- Conductor.rawSongPos);
			}
			else
			{
				DiscordClient.changePresence(detailsText + songData.displayName + " (" + storyDifficultyText + ")", grade + " | Acc: " + CoolUtil.truncateFloat(accuracy*100,2) + "%", iconRPC);
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
				DiscordClient.changePresence(detailsText + songData.displayName + " (" + storyDifficultyText + ")", grade + " | Acc: " + CoolUtil.truncateFloat(accuracy*100,2) + "%", iconRPC, true, songLength-Conductor.rawSongPos);
			}
			else
			{
				DiscordClient.changePresence(detailsText + songData.displayName + " (" + storyDifficultyText + ")", grade + " | Acc: " + CoolUtil.truncateFloat(accuracy*100,2) + "%", iconRPC);
			}
		}
		#end

		super.onFocus();
	}

	function pause(){
		if(subState!=null || paused)return;
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		// 1 / 1000 chance for Gitaroo Man easter egg
		#if release
		?if (FlxG.random.bool(0.1))
		{
			// gitaroo man easter egg
			FlxG.switchState(new GitarooPauseState());
		}
		else
		#end
			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
	}
	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText + songData.displayName + " (" + storyDifficultyText + ")", grade + " | Acc: " + CoolUtil.truncateFloat(accuracy*100,2) + "%", iconRPC);
		}
		#end

		pause();

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


	//public float GetSpritePosition(long offset, float initialPos) => HitPosition + ((initialPos - offset) * (ScrollDirection.Equals(ScrollDirection.Down) ? -HitObjectManagerKeys.speed : HitObjectManagerKeys.speed) / HitObjectManagerKeys.TrackRounding);
	// ADAPTED FROM QUAVER!!!
	// COOL GUYS FOR OPEN SOURCING
	// https://github.com/Quaver/Quaver
	// https://github.com/Quaver/Quaver
	// https://github.com/Quaver/Quaver
	function getPosFromTime(strumTime:Float):Float{
		var idx:Int = 0;
		while(idx<sliderVelocities.length){
			if(strumTime<sliderVelocities[idx].startTime)
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
		while(idx<sliderVelocities.length){
			if(strumTime<sliderVelocities[idx].startTime)
				break;
			idx++;
		}
		idx--;
		if(idx<=0)
			return SONG.initialSpeed;
		return SONG.initialSpeed*sliderVelocities[idx].multiplier;
	}

	function getPosFromTimeSV(strumTime:Float,?svIdx:Int=0):Float{
		if(svIdx==0)
			return strumTime*SONG.initialSpeed;

		svIdx--;
		var curPos = velocityMarkers[svIdx];
		curPos += ((strumTime-sliderVelocities[svIdx].startTime)*(SONG.initialSpeed*sliderVelocities[svIdx].multiplier));
		return curPos;
	}

	function updatePositions(){
		Conductor.currentVisPos = Conductor.songPosition;
		Conductor.currentTrackPos = getPosFromTime(Conductor.currentVisPos);
	}

	/*public function getXPosition(diff:Float, direction:Int, player:Int):Float{
		var x = FlxG.width/2 - Note.swagWidth/2; // centers them

		if(!currentOptions.middleScroll){
			switch(player){
				// player 0 (aka BF) should have his notes shifted right
				// and player 1 (aka dad) should have his notes shifted left
				case 0:
					x += FlxG.width / 4;
				case 1:
					x -= FlxG.width / 4;
			}
		}
		x -= Note.swagWidth*2; // so that everything is aligned on the left side
		x += Note.swagWidth * direction; // moves everything to be in position
		x += 56; // because lol

		return x; // return it
	}*/
	// ^^ this is VERY slightly off
	// so im just gonna take the code from andromeda 2.0 lmao

	public function getXPosition(diff:Float, direction:Int, player:Int):Float{

		var x:Float = (FlxG.width/2) - Note.swagWidth - 54 + Note.swagWidth*direction;
		if(!currentOptions.middleScroll){
			switch(player){
				case 0:
					x += FlxG.width/2 - Note.swagWidth*2 - 100;
				case 1:
					x -= FlxG.width/2 - Note.swagWidth*2 - 100;
			}
		}
		x -= 56;

		return x;
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
	function updateCamFollow(){
		var bfMid = boyfriend.getMidpoint();
		var dadMid = opponent.getMidpoint();
		var gfMid = gf.getMidpoint();

		if(cameraLocked){
			camFollow.setPosition(cameraLockX,cameraLockY);
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
				case 'center':
					focusedChar = null;
					var centerX = (stage.centerX==-1)?(((dadMid.x+ opponent.camOffset.x) + (bfMid.x- stage.camOffset.x + boyfriend.camOffset.x))/2):stage.centerX;
					var centerY = (stage.centerY==-1)?(((dadMid.y+ opponent.camOffset.y) + (bfMid.y- stage.camOffset.y + boyfriend.camOffset.y))/2):stage.centerY;
					camFollow.setPosition(centerX,centerY);
				case 'none':

			}
			if(currentOptions.camFollowsAnims && focusedChar!=null){
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
		if(focus!='none'){
			camFollow.x += camOffX;
			camFollow.y += camOffY;
		}
	}
	function doEvent(event:Event) : Void {
		var args = event.args;
		switch (event.name){
			case 'Change Character':
				var shit:String = args[0];
				switch(args[0]){
					case 'player':
						shit='bf';
					case 'opponent':
						shit='dad';
					default:
						shit=args[0];
				}
				swapCharacter(shit,args[1]);
			case 'Hey':
				boyfriend.playAnim("hey",true);
				gf.playAnim("cheer",true);
			case 'Play Anim':
				var char:Character = boyfriend;
				switch (args[0]){
					case 'gf':
						char = gf;
					case 'opponent':
						char=dad;
				}
				char.noIdleTimer = args[2]*1000;
				char.playAnim(args[1],true);
			case 'Camera Zoom Interval':
				zoomBeatingInterval = args[0];
				zoomBeatingZoom = args[1];
			case 'GF Speed':
				gfSpeed = Math.floor(args[0]);
			case 'Screen Shake':
				var axes:FlxAxes = XY;
				switch(args[2]){
					case 'XY':
						axes = XY;
					case 'X':
						axes = X;
					case 'Y':
						axes = Y;
				}
				FlxG.camera.shake(args[0],args[1],null,true,axes);
				camHUD.shake(args[0],args[1],null,true,axes);
			case 'Set Cam Pos':
				focus = 'none';
				camFollow.setPosition(args[0],args[1]);
			case 'Set Cam Focus':
				var shit:String = args[0];
				switch(args[0]){
					case 'player':
						shit='bf';
					case 'opponent':
						shit='dad';
					default:
						shit=args[0];
				}
				focus = shit;
				trace("set cam fuckus to " + args[0] + ' at ${Conductor.songPosition}');
			case 'Camera Zoom':
				defaultCamZoom = args[0];
			case 'Camera Zoom Bump':
				FlxG.camera.zoom += args[0];
				camHUD.zoom += args[1];
			case 'Camera Offset':
				camOffX = args[0];
				camOffY = args[1];
			case 'Custom':
				FlxG.log.add('hit custom event. ${args[1]} ${args[2]}');
		}

		if(luaModchartExists && lua!=null)
			callLua("doEvent",[event.name, event.args]); // TODO: Note lua class???

	}

	var differences:Array<Float>=[];
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


		shownAccuracy = CoolUtil.truncateFloat(FlxMath.lerp(shownAccuracy,accuracy*100, Main.adjustFPS(0.2)),2);
		if(accuracy<1 && shownAccuracy==100)shownAccuracy=99.99;

		if(Math.abs((accuracy*100)-shownAccuracy) <= 0.1)
			shownAccuracy=CoolUtil.truncateFloat(accuracy*100,2);

		//scoreTxt.text = "Score:" + (songScore + botplayScore) + ' / ${accuracyName}:' + shownAccuracy + "% / " + grade;
		updateScoreText();

		scoreTxt.screenCenter(X);
		botplayTxt.screenCenter(X);
		botplayTxt.visible = ScoreUtils.botPlay;

		if(judgeMan.judgementCounter.get('miss')>0 && currentOptions.failForMissing)
			health=0;

		previousHealth=health;
		if (controls.PAUSE && startedCountdown && canPause)
		{
			pause();

			#if desktop
			DiscordClient.changePresence(detailsPausedText + songData.displayName + " (" + storyDifficultyText + ")", grade + " | Acc: " + CoolUtil.truncateFloat(accuracy*100,2) + "%", iconRPC);
			#end
		}

		#if !DISABLE_CHART_EDITOR
		if (FlxG.keys.justPressed.SEVEN)
		{
			inst.pause();
			vocals.pause();
			persistentUpdate = false;
			persistentDraw = false;
			FlxG.switchState(new ChartingState());



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


		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.rawSongPos += FlxG.elapsed * 1000;
				if (Conductor.rawSongPos >= startPos)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = inst.time;
			Conductor.rawSongPos += FlxG.elapsed * 1000;
		}

		if(inst.playing && !startingSong){
			var delta = Conductor.rawSongPos/1000 - Conductor.lastSongPos;
			differences.push(delta);
			if(differences.length>20)
				differences.shift();
			Conductor.lastSongPos = inst.time/1000;
			if(Math.abs(delta)>=0.05){
				Conductor.rawSongPos = inst.time;
			}

			if(Conductor.rawSongPos>=vocals.length && vocals.length>0){
				dontSync=true;
				vocals.volume=0;
				vocals.stop();
			}
		}

		FlxG.watch.addQuick("curBeat", curBeat);
		FlxG.watch.addQuick("curStep", curStep);
		FlxG.watch.addQuick("curDecBeat", curDecBeat);
		FlxG.watch.addQuick("curDecStep", curDecStep);
		FlxG.watch.addQuick("rawSongPos", Conductor.rawSongPos);
		FlxG.watch.addQuick("instTime", inst.time);

		var avgDiff:Float = 0;
		for(diff in differences)avgDiff+=diff;
		avgDiff/=differences.length;
		FlxG.watch.addQuick("avgDiff", avgDiff*1000);

		Conductor.songPosition = (Conductor.rawSongPos+currentOptions.noteOffset);
		FlxG.watch.addQuick("songPos", Conductor.songPosition);

		try{
			if(luaModchartExists && lua!=null){
				lua.setGlobalVar("songPosition",Conductor.songPosition);
				lua.setGlobalVar("rawSongPos",Conductor.rawSongPos);
			}
		}catch(e:Any){
			trace(e);
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom,defaultCamZoom, Main.adjustFPS(0.05));
			camHUD.zoom = FlxMath.lerp(camHUD.zoom,1, Main.adjustFPS(0.05));
		}

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 8;
				case 48:
					gfSpeed = 4;
				case 80:
					gfSpeed = 8;
				case 112:
					gfSpeed = 4;
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
			modManager.updateReceptor(spr, 0, scale, pos);

			spr.desiredX = pos.x;
			spr.desiredY = pos.y;
			spr.desiredZ = pos.z;
			spr.scale.set(scale.x,scale.y);

			scale.put();
		});

		dadStrums.forEach( function(spr:Receptor)
		{
			var pos = modManager.getReceptorPos(spr,1);
			var scale = modManager.getReceptorScale(spr,1);
			modManager.updateReceptor(spr, 1, scale, pos);

			spr.desiredX = pos.x;
			spr.desiredY = pos.y;
			spr.desiredZ = pos.z;
			spr.scale.set(scale.x,scale.y);

			scale.put();

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
				if(!currentOptions.noFail && !inCharter ){
					died=true;
					boyfriend.stunned = true;

					persistentUpdate = false;
					persistentDraw = false;
					paused = true;

					vocals.stop();
					inst.stop();
					var char:Null<String> = null;
					if(boyfriend.animation.getByName("firstDeath")!=null && boyfriend.animation.getByName("deathLoop")!=null && boyfriend.animation.getByName("deathConfirm")!=null )char = boyfriend.curCharacter;

					openSubState(new GameOverSubstate(boyfriend.x, boyfriend.y, char));

					// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

					#if desktop
					// Game Over doesn't get his own variable because it's only used here
					DiscordClient.changePresence("Game Over - " + detailsText + songData.displayName + " (" + storyDifficultyText + ")", grade + " | Acc: " + CoolUtil.truncateFloat(accuracy*100,2) + "%", iconRPC);
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
			if (Conductor.currentTrackPos-getPosFromTime(unspawnNotes[0].strumTime)>-noteSpawnTime)
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
				if (boyfriend.isSinging && !boyfriend.animation.curAnim.name.endsWith('miss'))
				{
					boyfriend.dance();
				}
			}
		}

		var shouldResetDadReceptors:Bool = true; // lmao
		var notesToKill:Array<Note>=[];
		var sustainCount:Int = 0;
		if (generatedMusic)
		{
			if(startedCountdown){
				if(currentOptions.allowOrderSorting)
					renderedNotes.sort(sortByOrder);

				preNoteLogic(elapsed);
				renderedNotes.forEachAlive(function(daNote:Note)
				{
					if(!daNote.active){
						daNote.visible=false;
						notesToKill.push(daNote);
						return;
					}

					if(daNote.isSustainNote)sustainCount++;


					var revPerc:Float = modManager.get("reverse").getScrollReversePerc(daNote.noteData,daNote.mustPress==true?0:1);

					var strumLine = playerStrums.members[daNote.noteData];
					var isDownscroll = revPerc>.5;

					if(!daNote.mustPress)
						strumLine = dadStrums.members[daNote.noteData];

					var diff =  Conductor.songPosition - daNote.strumTime;
			    var vDiff = (daNote.initialPos-Conductor.currentTrackPos);
					if(daNote.holdingTime<daNote.sustainLength && daNote.wasGoodHit && !daNote.tooLate){
						diff=0;
						vDiff=0;
					}

			    var notePos = modManager.getPath(diff, vDiff, daNote.noteData, daNote.mustPress==true?0:1);

					notePos.x += daNote.manualXOffset;
					notePos.y -= daNote.manualYOffset;

					var scale = modManager.getNoteScale(daNote);
					modManager.updateNote(daNote, daNote.mustPress?0:1, scale, notePos);

					daNote.x = notePos.x;
					daNote.y = notePos.y;

					daNote.z = notePos.z;
					daNote.scale.copyFrom(scale);
					daNote.updateHitbox();

					if(daNote.isSustainNote){
							var futureSongPos = Conductor.songPosition + 75;
							var futureVisualPos = getPosFromTime(futureSongPos);

							var diff =  futureSongPos - daNote.strumTime;
					    var vDiff = (daNote.initialPos - futureVisualPos);

							var nextPos = modManager.getPath(diff, vDiff, daNote.noteData, daNote.mustPress==true?0:1);
							nextPos.x += daNote.manualXOffset;
					    nextPos.y -= daNote.manualYOffset;

							var diffX = (nextPos.x - notePos.x);
							var diffY = (nextPos.y - notePos.y);
							var rad = Math.atan2(diffY,diffX);
							var deg = rad * (180 / Math.PI);
							if(deg!=0)
								daNote.modAngle = deg + 90;
							else
								daNote.modAngle = 0;
					}

					scale.put();
					var visibility:Bool=true;

					if (daNote.y > camNotes.height)
					{
						visibility = false;
					}
					else
					{
						if((daNote.mustPress || !daNote.mustPress && !currentOptions.middleScroll)){
							visibility = true;
						}
					}


					if(!daNote.mustPress && currentOptions.middleScroll){
						visibility=false;
					}

					if(daNote.sustainLength > 0 && daNote.wasGoodHit)
						visibility=false;

					if(daNote.garbage){
						daNote.visible=false;
						daNote.active=false;
						notesToKill.push(daNote);
						return;
					}


					daNote.visible = visibility;

					if(daNote.holdingTime < daNote.sustainLength && daNote.mustPress){ // NEW HOLD LOGIC
						if(!daNote.tooLate && daNote.wasGoodHit){
							var isHeld = pressedKeys[daNote.noteData];
							if(daNote.isRoll)isHeld = false;
							var receptor = playerStrums.members[daNote.noteData];
							if(isHeld && receptor.animation.curAnim.name!="confirm")
								receptor.playAnim("confirm", true);

							daNote.holdingTime = Conductor.songPosition - daNote.strumTime;
							var regrabTime:Float = 0.2;
							if(daNote.isRoll)
								regrabTime = 0.35;

							if(isHeld)
								daNote.tripTimer = 1;
							else
								daNote.tripTimer -= elapsed/regrabTime; // maybe make the regrab timer an option
								// idk lol

							if(daNote.tripTimer<=0){
								daNote.tripTimer=0;
								trace("tripped hold / roll");
								daNote.tooLate=true;
								daNote.wasGoodHit=false;
								for(tail in daNote.tail){
									if(!tail.wasGoodHit)
										tail.tooLate=true;
								}
							}else{

								for(tail in daNote.unhitTail){
									if((tail.strumTime - 25) <= Conductor.songPosition && !tail.wasGoodHit && !tail.tooLate)
										noteHit(tail);
								}
								boyfriend.holding=daNote.unhitTail.length>0 && !daNote.isRoll;
								if(daNote.unhitTail.length>0)
									boyfriend.holdTimer=0;

								if(daNote.holdingTime >= daNote.sustainLength){
									updateReceptors();
									trace("finished hold / roll successfully");
									daNote.holdingTime = daNote.sustainLength;
									boyfriend.holding=false;
									// idk if I should add score when you finish a hold/roll
									// maybe health tho? idk i'll think bout it
								}

							}
						}
					}

					var shitGotHit = (daNote.parent!=null && daNote.parent.wasGoodHit && daNote.canBeHit) || (daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit);
					var shit = strumLine.y + Note.swagWidth/2;
					if(revPerc==0.5){
						daNote.clipRect=null;
						if(shitGotHit && daNote.wasGoodHit)
							daNote.visible=false;
					}else{
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
					}


					if (!daNote.mustPress && daNote.canBeHit && !daNote.wasGoodHit)
					{
						dadStrums.forEach(function(spr:Receptor)
						{
							if (Math.abs(daNote.noteData) == spr.ID)
								spr.playNote(daNote);
						});

						var altAnim:String = "";

						if (SONG.notes[Math.floor(curStep / 16)] != null)
							if (SONG.notes[Math.floor(curStep / 16)].altAnim)
								altAnim = '-alt';


						switch(daNote.noteType){
							case 'alt':
								altAnim='-alt';
							case 'mine':
								// this really SHOULDN'T happen, but..
								health += 0.25; // they hit a mine, not you
						}

						health -= modchart.opponentHPDrain;

						if(luaModchartExists && lua!=null)
							callLua("dadNoteHit",[Math.abs(daNote.noteData), daNote.strumTime, Conductor.songPosition, daNote.isSustainNote]); // TODO: Note lua class???

						playAnimationNote(opponent, daNote, altAnim);


						if(!daNote.isRoll){
							if(daNote.holdParent && !daNote.isSustainEnd())
								opponent.holding = true;
							else
								opponent.holding = false;
						}

						opponent.holdTimer = 0;

						if (SONG.needsVoices)
							vocals.volume = 1;
						daNote.wasGoodHit=true;

						lastHitDadNote=daNote;

						if(daNote.parent!=null && daNote.parent.unhitTail.length>0)
							shouldResetDadReceptors=false;


						if(!daNote.isSustainNote && daNote.sustainLength==0)
							notesToKill.push(daNote);
						else if(daNote.isSustainNote){
							if(daNote.parent.unhitTail.contains(daNote))
								daNote.parent.unhitTail.remove(daNote);

						}


					}


					if(daNote!=null && daNote.alive){
						if(daNote.tooLate && daNote.mustPress && !daNote.isSustainNote && !daNote.causedMiss){
							if(daNote.causesMiss){
								if(daNote.tail.length>0){
									for(tail in daNote.tail)
										tail.tooLate=true;

								}
								daNote.causedMiss = true;
								noteMiss(daNote.noteData);

								vocals.volume = 0;
								updateAccuracy();
							}
						}

						if((
							isDownscroll && daNote.y>FlxG.height+daNote.height ||
							!isDownscroll && daNote.y<-daNote.height ||
							(daNote.mustPress && daNote.holdingTime>=daNote.sustainLength || !daNote.mustPress && daNote.unhitTail.length==0 ) && daNote.sustainLength>0 ||
							daNote.isSustainNote && daNote.strumTime - Conductor.songPosition < -350 ||
							!daNote.isSustainNote && (daNote.sustainLength==0 || daNote.tooLate) && daNote.strumTime - Conductor.songPosition < -daNote.gcTime) && (daNote.tooLate || daNote.wasGoodHit))
							notesToKill.push(daNote);

					}
				});

				postNoteLogic(elapsed);
			}
		}

		if(lastHitDadNote==null || !lastHitDadNote.alive || !lastHitDadNote.exists)
			lastHitDadNote=null;


		FlxG.camera.followLerp = Main.adjustFPS(.02);
		camRating.followLerp = Main.adjustFPS(.02);

		super.update(elapsed);
		for(i in 0...justPressedKeys.length)justPressedKeys[i]=false;

		while(eventSchedule[0]!=null){
			var event = eventSchedule[0];
			if(Conductor.songPosition >= event.time){
				if(event.events!=null && event.events.length>0){
					for(e in event.events)doEvent(e);
				}else if(event.events==null)
					doEvent(event);
				eventSchedule.shift();
			}else{
				break;
			}
		}

		updateCamFollow();

		for(note in notesToKill){
			destroyNote(note);

		}

		dadStrums.forEach(function(spr:Receptor)
		{
			if (spr.animation.finished && spr.animation.curAnim.name=='confirm')
				spr.playAnim('static',true);


		});
		FlxG.watch.addQuick("note count", renderedNotes.members.length);
		FlxG.watch.addQuick("sus count", sustainCount);
		strumLineNotes.sort(sortByOrder);


		if (!inCutscene){


			/*if(pressedKeys.contains(true)){
				for(idx in 0...pressedKeys.length){
					var isHeld = pressedKeys[idx];
					if(isHeld)
						for(daNote in getHittableHolds(idx))
							noteHit(daNote);
				}
			}*/
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

			callLua("update",[elapsed]);
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
			FlxG.switchState(new ChartingState());
		}else{
			if (isStoryMode)
			{
				if(!died && canScore)
					campaignScore += songScore;

				gotoNextStory();

				if (storyPlaylist.length <= 0)
				{

					FlxG.sound.playMusic(Paths.music('freakyMenu'));

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
		var coolText:FlxObject = new FlxObject(0, 0);
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

					var scaleX = numScore.scale.x;
					var scaleY = numScore.scale.y;

					add(numScore);
					if(currentOptions.smJudges){
						comboSprites.push(numScore);
						//
						numScore.scale.x *= 1.25;
						numScore.scale.y *= 0.75;
						numScore.alpha = 0.6;
						numScore.currentTween = FlxTween.tween(numScore, {"scale.x": scaleX, "scale.y": scaleY, alpha: 1}, 0.2, {
							ease: FlxEase.circOut
						});
						/*numScore.y -= 30;
						numScore.currentTween = FlxTween.tween(numScore, {y: numScore.y + 30}, 0.2, {
							ease: FlxEase.circOut
						});*/


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

		var coolText:FlxObject = new FlxObject(0,0);
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
				rating.setGraphicSize(Std.int(rating.width * daPixelZoom * .8));
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
			var displayedMS = CoolUtil.truncateFloat(noteDiff,2);
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

	function updateReceptors(canReset:Bool=true){
		playerStrums.forEach( function(spr:Receptor)
		{
			if(pressedKeys[spr.ID] && spr.animation.curAnim.name!="confirm" && spr.animation.curAnim.name!="pressed" )
				spr.playAnim("pressed");

			if(!pressedKeys[spr.ID] && canReset)
				spr.playAnim("static");

		});

		strumLineNotes.sort(sortByOrder);
	}

	private function keyPress(event:KeyboardEvent){
		if(paused)return;
		if(event.keyCode == FlxKey.F6 && canToggleBotplay)
			ScoreUtils.botPlay = !ScoreUtils.botPlay;

		if(ScoreUtils.botPlay)return;
		var direction = bindData.indexOf(event.keyCode);
		if(direction!=-1 && !pressedKeys[direction]){
			justPressedKeys[direction]=true;
			pressedKeys[direction]=true;
			handleInput(direction);
			updateReceptors();
		}

	}

	private function keyRelease(event:KeyboardEvent){
		if(ScoreUtils.botPlay)return;
		var direction = bindData.indexOf(event.keyCode);
		if(paused && (direction == -1 || !pressedKeys[direction]))return;
		if(direction!=-1 && pressedKeys[direction]){
			pressedKeys[direction]=false;
			var hitting:Array<Note> = getHittableNotes(direction,false);
			hitting.sort((a,b)->Std.int(a.strumTime-b.strumTime)); // SHOULD be in order?
			updateReceptors(hitting[0]==null || !(hitting[0].wasGoodHit && hitting[0].isRoll));
		}
	}

	private function handleInput(direction:Int){
		if(direction!=-1){
			var hitting:Array<Note> = getHittableNotes(direction,false);
			hitting.sort((a,b)->Std.int(a.strumTime-b.strumTime)); // SHOULD be in order?
			// But just incase, we do this sort

			if(hitting.length>0){
				boyfriend.holdTimer=0;
				var hitNote = hitting[0];
				if(!hitNote.wasGoodHit) // because parent tap notes
					noteHit(hitNote);
				else if(hitNote.wasGoodHit && hitNote.isRoll){
					var receptor = playerStrums.members[hitNote.noteData];
					receptor.playAnim("confirm", true);
					hitNote.tripTimer = 1;
					playAnimationNote(boyfriend, hitNote, "");
				}


			}else{
				if((currentOptions.hitsoundType==1 || currentOptions.hitsoundType==2))
					FlxG.sound.play(Paths.sound('Ghost_Hit'),currentOptions.hitsoundVol/100);

				if(currentOptions.ghosttapping==false)
					badNoteCheck();
			}

		}
	}

	private function preNoteLogic(elapsed: Float){
		// put whatever code here idk

		// botplay
		if(ScoreUtils.botPlay){
			for(dir in 0...botplayHoldTimes.length){
				if(botplayHoldTimes[dir]>0)botplayHoldTimes[dir]-=elapsed*1000;
				if(botplayHoldTimes[dir]<0)botplayHoldTimes[dir]=0;
				var time = botplayHoldTimes[dir];
				if(time>0){
					if(!pressedKeys[dir]){
						pressedKeys[dir]=true;
						handleInput(dir);
						updateReceptors();
					}
				}else{
					if(pressedKeys[dir]){
						pressedKeys[dir]=false;
						updateReceptors();
					}
				}
			}
		}
	}

	private function postNoteLogic(elapsed: Float){
		// put whatever code here idk

		// botplay
		if(ScoreUtils.botPlay){
			for(dir in 0...botplayHoldTimes.length){
				var notes = getHittableNotes(dir);
				for(note in notes){
					var diff = note.strumTime - Conductor.songPosition;
					if(diff<=10 && note.causesMiss){
						if(note.sustainLength==0)
							botplayHoldTimes[dir] = 100;
						else
							botplayHoldTimes[dir] = note.sustainLength;


						pressedKeys[dir]=true;
						handleInput(dir);
						updateReceptors();
					}
				}
			}
		}
	}

	function getHittableNotes(direction:Int=-1,excludeHolds:Bool=false){
		var notes:Array<Note>=[];
		for(note in playerNotes){
			if((note.canBeHit && note.alive && !note.wasGoodHit || note.sustainLength>0 && note.wasGoodHit) && !note.tooLate && (direction==-1 || note.noteData==direction) && (!excludeHolds || !note.isSustainNote))
				notes.push(note);

		}
		return notes;
	}

	function getHittableHolds(?direction:Int=-1){
		var sustains:Array<Note>=[];
		for(note in getHittableNotes()){
			if(note.isSustainNote && !note.parent.tooLate){
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
			callLua("noteMiss",[direction]);
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

			if(!note.isSustainNote && note.sustainLength==0)boyfriend.holding=false;
			note.wasGoodHit=true;
			playerStrums.forEach(function(spr:Receptor)
			{
				if (Math.abs(note.noteData) == spr.ID){
					if(!note.isSustainNote || pressedKeys[note.noteData])
						spr.playNote(note,(currentOptions.useNotesplashes && !note.isSustainNote)?(judge=='sick' || judge=='epic'):false);
				}

			});

			if (!note.isSustainNote && note.tail.length==0)
			{
				note.kill();
				if(note.mustPress)
					playerNotes.remove(note);

				renderedNotes.remove(note, true);
				note.destroy();
			}else if(note.mustPress && note.isSustainNote){
				if(note.parent!=null){
					if(note.parent.unhitTail.contains(note))
						note.parent.unhitTail.remove(note);

				}
			}
		}

	}

	function updateJudgementCounters(){
		for(judge in counters.keys()){
			var txt = counters.get(judge);
			var name:String = JudgementManager.judgementDisplayNames.get(judge);
			if(name==null)
				name = '${judge.substring(0,1).toUpperCase()}${judge.substring(1,judge.length)}';

			txt.text = '${name}: ${judgeMan.judgementCounter.get(judge)}';
			txt.x=0;
		}
	}

	function hurtNoteHit(note:Note):Void{
		health -= 0.25;
		judgeMan.judgementCounter.set("miss",judgeMan.judgementCounter.get("miss")+1);
		updateJudgementCounters();
		previousHealth=health;
		if(luaModchartExists && lua!=null)
			callLua("hitMine",[note.noteData,note.strumTime,Conductor.songPosition,note.isSustainNote]);

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

	function playAnimationNote(who:Character, daNote:Note, suffix:String=''){
		var dirs = ["LEFT","DOWN","UP","RIGHT"];
		var dir = "";
		var anim = "";
		dir = dirs[daNote.noteData];
		anim = 'sing${dir}';

		if(!daNote.isRoll){
			if(daNote.tail.length>0 && !daNote.isSustainNote){
				if(who.animation.getByName('hold${dir}Start')!=null)
					anim = 'hold${dir}Start';
				else if(who.animation.getByName('hold${dir}')!=null)
					anim = 'hold${dir}';
			}else if(daNote.isSustainNote){
				if(who.animation.getByName('hold${dir}')!=null)
					anim = 'hold${dir}';
			}

			if(daNote.isSustainEnd()){
				if(who.animation.getByName('hold${dir}End')!=null)
					anim = 'hold${dir}End';
			}
		}
		if(daNote.noteType=='alt')suffix+='-alt';

		if(who.animation.getByName(anim+suffix)!=null)
			anim += suffix;

		who.holdTimer = 0;
		if(who.animation.curAnim!=null){
			if(who.animation.curAnim!=null && (!anim.startsWith("hold") || who.animation.curAnim.name!=anim))
				who.playAnim(anim,true);
		}


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

		if((currentOptions.hitsoundType==1 || currentOptions.hitsoundType==3) && !note.isSustainNote)
			FlxG.sound.play(Paths.sound('Normal_Hit'),currentOptions.hitsoundVol/100);

		var strumLine = playerStrums.members[note.noteData%4];


		if(luaModchartExists && lua!=null)
			callLua("goodNoteHit",[note.noteData,note.strumTime,Conductor.songPosition,note.isSustainNote]); // TODO: Note lua class???


		if(!note.isSustainNote)
			health += judgeMan.getJudgementHealth(judgement);


		if(health>2)
			health=2;

		previousHealth=health;

		//if(!note.isSustainNote){
		var dirs = ["LEFT","DOWN","UP","RIGHT"];
		var dir = "";
		var anim = "";
		dir = dirs[note.noteData];
		anim = 'sing${dir}';

		var suffix = '';
		if(breaksCombo && !note.isSustainNote){
			anim='sing${dir}miss';
			boyfriend.playAnim(anim,true);
		}else if(!note.isSustainNote || !note.isRoll)
			playAnimationNote(boyfriend, note, suffix);




		//}
		vocals.volume = 1;
		updateAccuracy();

	}

	var fastCarCanDrive:Bool = true;

	function callLua(name:String, args:Array<Any>, ?type: String): Any{
		if(luaFuncs.contains(name))
			return lua.call(name, args, type);

		return null;
	}

	override function stepHit()
	{
		super.stepHit();
		if(luaModchartExists && lua!=null){
			lua.setGlobalVar("curStep",curStep);
			callLua("stepHit",[curStep]);
		}
		if(!paused){
			if (inst != null && !startingSong){
				if (inst.time > Conductor.rawSongPos + 45 || inst.time < Conductor.rawSongPos - 45)
				{
					//resyncVocals();
				}
			}
		}

		if (curStep % gfSpeed == 0)
			gf.dance();

		var lastChange = Conductor.getBPMFromStep(curStep);
		if(lastChange.bpm != Conductor.bpm){
			Conductor.changeBPM(lastChange.bpm);
			FlxG.log.add('CHANGED BPM!');
			if(luaModchartExists && lua!=null){
				lua.setGlobalVar("bpm",Conductor.bpm);
				lua.setGlobalVar("crochet",Conductor.crochet);
				lua.setGlobalVar("stepCrochet",Conductor.stepCrochet);
			}
		}
	}

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection){
				if(turn!='bf'){
					turn='bf';
					trace('changed turn to $turn at ${Conductor.songPosition}');
					if(currentOptions.staticCam==0)
						focus='bf';
				}
			}else{
					if(turn!='dad'){
						turn='dad';
						trace('changed turn to $turn at ${Conductor.songPosition}');
						if(currentOptions.staticCam==0)
							focus='dad';
				}
			}
		}

		stage.beatHit(curBeat);

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			if(dad.animation.curAnim!=null)
				if (!dad.isSinging)
					dad.dance();

			for(opp in opponents){
				if(opp!=dad){
					if(opp.animation.curAnim!=null)
						if (!opp.isSinging)
							opp.dance();
				}
			}


		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		// HARDCODING FOR MILF ZOOMS!
		/*if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}*/

		if (camZooming && FlxG.camera.zoom < defaultCamZoom + 0.35 && curBeat % zoomBeatingInterval == 0)
		{
			FlxG.camera.zoom += zoomBeatingZoom;
			camHUD.zoom += zoomBeatingZoom*2;
		}

		healthBar.beatHit(curBeat);


		if(boyfriend.animation.curAnim!=null)
			if (!boyfriend.isSinging)
				boyfriend.dance();


		/*if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);
		}*/

		/*if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}*/

		if(luaModchartExists && lua!=null){
			lua.setGlobalVar("curBeat",curBeat);
			callLua("beatHit",[curBeat]);
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

		Main.setFPSCap(OptionUtils.options.fps);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN,keyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP,keyRelease);

		return super.switchTo(next);
	}

	public static function setStoryWeek(data:WeekData,difficulty:Int){
		PlayState.inCharter=false;
		PlayState.startPos = 0;
		ChartingState.lastSection = 0;
		storyPlaylist = data.getCharts();
		weekData = data;

		isStoryMode = true;
		storyDifficulty = difficulty;

		SONG = Song.loadFromJson(data.songs[0].formatDifficulty(difficulty), storyPlaylist[0].toLowerCase());
		storyWeek = weekData.weekNum;
		campaignScore = 0;

		PlayState.songData=data.songs[0];
	}
	// eight equals equals equals D
	public function gotoNextStory(){
		PlayState.inCharter=false;
		PlayState.startPos = 0;
		ChartingState.lastSection = 0;
		if(8==D)
			trace("cock penis!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");

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
		ChartingState.lastSection = 0;
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
