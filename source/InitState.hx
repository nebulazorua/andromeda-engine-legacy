package;

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

using StringTools;

class InitState extends FlxUIState {
  public static function initTransition(){ // TRANS RIGHTS
    var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
    diamond.persist = true;
    diamond.destroyOnNoUse = false;

    FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
      new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
    FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
      {asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
  }
  override function create()
  {
    #if polymod
    polymod.Polymod.init({modRoot: "mods", dirs: ['introMod']});
    #end

    OptionUtils.bindSave();
    OptionUtils.loadOptions(OptionUtils.options);
    var currentOptions = OptionUtils.options;
    EngineData.options = currentOptions;
    PlayerSettings.init();

		FlxG.save.bind('funkin', 'ninjamuffin99');
		Highscore.load();

    FlxG.sound.muteKeys=null;
    FlxG.sound.volume = FlxG.save.data.volume;

    FlxG.sound.volumeHandler = function(volume:Float){
      FlxG.save.data.volume=volume;
    }

    if(!JudgementManager.dataExists(currentOptions.judgementWindow)){
      OptionUtils.options.judgementWindow = 'Vanilla';
      OptionUtils.saveOptions(OptionUtils.options);
    }

    FlxGraphic.defaultPersist = currentOptions.cacheUsedImages;

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



    if(currentOptions.shouldCache && canCache){
      FlxG.switchState(new CachingState(new TitleState()));
    }else{
      initTransition();
      transIn = FlxTransitionableState.defaultTransIn;
      transOut = FlxTransitionableState.defaultTransOut;
      FlxG.switchState(new TitleState());
    }
  }



}
