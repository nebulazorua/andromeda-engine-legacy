package states;

import flixel.addons.ui.FlxUIState;
import sys.thread.Thread;
import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import lime.app.Application;
import Discord.DiscordClient;
import flixel.FlxSprite;
import Options;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import haxe.Json;
import sys.FileSystem;
import ui.*;
using StringTools;

class InitState extends FlxUIState {
  public static function initTransition(){ // TRANS RIGHTS
    FlxTransitionableState.defaultTransIn = FadeTransitionSubstate;
    FlxTransitionableState.defaultTransOut = FadeTransitionSubstate;


  }

  public static function getNoteskins(){
    var currentOptions = OptionUtils.options;
    Note.skinManifest.clear();
    OptionUtils.noteSkins = Paths.getDirs("skins");

    if(!OptionUtils.noteSkins.contains(currentOptions.noteSkin))
      currentOptions.noteSkin='default';

    for(skin in OptionUtils.noteSkins){
      Note.skinManifest.set(skin,Paths.noteskinManifest(skin));
    }
  }

  public static function getCharacters(){
    EngineData.characters=[];
    for(file in FileSystem.readDirectory('assets/characters/data') ){
      if(file.endsWith(".json")){
        var name = file.replace(".json","");
        if(!name.endsWith("-player")){
          EngineData.characters.push(name);
        }
      }
    }
  }

  override function create()
  {
    OptionUtils.bindSave();
    OptionUtils.loadOptions(OptionUtils.options);
    var currentOptions = OptionUtils.options;

    getNoteskins();

    EngineData.options = currentOptions;
    ui.FPSMem.showFPS = currentOptions.showFPS;
    ui.FPSMem.showMem = currentOptions.showMem;
    ui.FPSMem.showMemPeak = currentOptions.showMemPeak;

    PlayerSettings.init();

		FlxG.save.bind('funkin', 'ninjamuffin99');
		Highscore.load();

    FlxG.sound.muteKeys=null;
    FlxG.sound.volumeUpKeys=null;
    FlxG.sound.volumeDownKeys=null;
    FlxG.sound.volume = FlxG.save.data.volume;

    FlxG.sound.volumeHandler = function(volume:Float){
      FlxG.save.data.volume=volume;
    }

    #if !FORCED_JUDGE
    if(!JudgementManager.dataExists(currentOptions.judgementWindow)){
      OptionUtils.options.judgementWindow = 'Andromeda';
      OptionUtils.saveOptions(OptionUtils.options);
    }
    #end

    FlxGraphic.defaultPersist = true;

		if (FlxG.save.data.weekUnlocked != null)
		{
			// FIX LATER!!!
			// WEEK UNLOCK PROGRESSION!!
			// StoryMenuState.weekUnlocked = FlxG.save.data.weekUnlocked;

			if (StoryMenuState.weekUnlocked.length < 4)
				StoryMenuState.weekUnlocked.insert(0, true);

			// QUICK PATCH OOPS!
			if (!StoryMenuState.weekUnlocked[0])
				StoryMenuState.weekUnlocked[0] = true;
		}

    if(currentOptions.fps<30 || currentOptions.fps>360){
      currentOptions.fps = 120;
    }

    Main.setFPSCap(currentOptions.fps);
    super.create();

    #if desktop
		DiscordClient.initialize();

		Application.current.onExit.add (function (exitCode) {
			DiscordClient.shutdown();
		 });
		#end


    var canCache=false;
    #if sys
      #if cpp // IDK IF YOU CAN DO "#IF SYS AND CPP" OR THIS'LL WORK I THINK
        canCache=true;
      #end
    #end
    if(canCache){
      if(!currentOptions.cacheCharacters && !currentOptions.cacheSongs && !currentOptions.cacheSounds  && !currentOptions.cachePreload)
        canCache=false;
    }

    FlxG.fixedTimestep = false;

    getCharacters();

    //characters
    var nextState:FlxUIState = new TitleState();
    if(currentOptions.shouldCache && canCache)
      nextState = new CachingState(nextState);
    else
      initTransition();


    #if GOTO_CHAR_EDITOR
    FlxG.switchState(new CharacterEditorState('bf',nextState));
    #else
    FlxG.switchState(nextState);
    #end
  }



}
