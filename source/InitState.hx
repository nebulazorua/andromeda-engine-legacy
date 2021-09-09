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

using StringTools;

class InitState extends FlxUIState {
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
    if(currentOptions.shouldCache && canCache){
      FlxG.switchState(new CachingState(new TitleState()));
    }else{
      FlxG.switchState(new TitleState());
    }
  }



}
