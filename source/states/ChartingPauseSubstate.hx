package states;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import ui.*;
using StringTools;
import Option;
import ui.Checkbox;
import Options;
class PauseButton extends Option
{
	private var callback:Void->Void;

	public function new(?name:String,?callback:Void->Void){
		super(name);
    this.callback = callback;
	}

	public override function accept():Bool{
    callback();
		return false;
	}
}


class PauseToggle extends Option
{
	private var value:Bool = false;
	private var checkbox:Checkbox;
	private var callback:Bool->Void;

	public function new(?name:String,defaultValue:Bool=false,?callback:Bool->Void){
		super();
		this.name = name;
    this.value = defaultValue;
		checkbox = new Checkbox(defaultValue);
    checkbox.canClick = false;
    checkbox.callback=callback;
    checkbox.setGraphicSize(Std.int(checkbox.frameWidth*.6) );
    checkbox.updateHitbox();
    checkbox.trackOffX = -120;
    checkbox.trackOffY = -25;
		add(checkbox);
	}

	public override function createOptionText(curSelected:Int,optionText:FlxTypedGroup<Option>):Dynamic{
    remove(text);
    text = new Alphabet(0, (70 * curSelected) + 30, name, true, false);
    text.movementType = "list";
    text.isMenuItem = true;
		text.offsetX = 145;
		text.gotoTargetPosition();
		checkbox.tracker = text;
    add(text);
    return text;
  }

	public override function accept():Bool{
    value=!value;
		checkbox.changeState(value);
		return false;
	}
}

class ChartingPauseSubstate extends MusicBeatSubstate
{
	var startTimer:FlxTimer;
	var grpMenuShit:FlxTypedGroup<Option>;

	/*var menuItems:Array<String> = [
		'Resume',
    "Play from beginning",
    "Play from here",
    // TODO: toggle for a few diff options (botplay, etc)
    // also prob add a prompt thing so I can add like "New Chart" and have an "ARE YOU SURE????" thing
    // prob ask bepixel or echo to do those assets
		'Exit to menu'
  ];*/
  var menuItems:Array<Option> = [];

  function createOptions(){
    menuItems.push(new PauseButton("Resume", function(){
      close();
    }));

    menuItems.push(new PauseButton("Play from beginning", function(){
      ChartingState.instance.startSong(0);
    }));

    menuItems.push(new PauseButton("Play from here", function(){
      ChartingState.instance.startSong(FlxG.sound.music.time);
    }));

    menuItems.push(new PauseToggle("Botplay", OptionUtils.options.chartingBotplay, function(state){
      OptionUtils.options.chartingBotplay = state;
    }));

    menuItems.push(new PauseToggle("Details", OptionUtils.options.chartingDetails, function(state){
      OptionUtils.options.chartingDetails = state;
    }));

		menuItems.push(new PauseToggle("Modchart", !OptionUtils.options.chartingNoModshart, function(state){
			OptionUtils.options.chartingNoModshart = !state;
		}));

    menuItems.push(new PauseButton("Exit to menu", function(){
        if(PlayState.isStoryMode)
          FlxG.switchState(new StoryMenuState());
        else
          FlxG.switchState(new FreeplayState());
    }));

  }

	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var countingDown:Bool=false;

	public function new()
	{
		super();

    FlxG.sound.music.pause();
    ChartingState.instance.vocals.pause();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);
		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		grpMenuShit = new FlxTypedGroup<Option>();
		add(grpMenuShit);

    createOptions();
    for (i in 0...menuItems.length)
    {
      var text = menuItems[i].createOptionText(0,grpMenuShit);
			text.targetY = i;
			text.gotoTargetPosition();

      grpMenuShit.add(menuItems[i]);
    }
		/*for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}*/

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{

		super.update(elapsed);

		var upP = FlxG.keys.justPressed.UP;
		var downP = FlxG.keys.justPressed.DOWN;
		var accepted = FlxG.keys.justPressed.ENTER;
    var leftP = FlxG.keys.justPressed.LEFT;
    var rightP = FlxG.keys.justPressed.RIGHT;
    var fuckGoBack = FlxG.keys.justPressed.ESCAPE;

    if(fuckGoBack){
      close();
      return;
    }


		if (upP)
			changeSelection(-1);

		if (downP)
			changeSelection(1);

    var option = menuItems[curSelected];

    if(leftP){
      if(option.left()) {
        option.createOptionText(curSelected,grpMenuShit);
        changeSelection();
      }
    }
    if(rightP){
      if(option.right()) {
        option.createOptionText(curSelected,grpMenuShit);
        changeSelection();
      }
    }

    if(option.allowMultiKeyInput){
      var pressed = FlxG.keys.firstJustPressed();
      var released = FlxG.keys.firstJustReleased();
      if(pressed!=-1){
        if(option.keyPressed(pressed)){
          option.createOptionText(curSelected,grpMenuShit);
          changeSelection();
        }
      }
      if(released!=-1){
        if(option.keyReleased(released)){
          option.createOptionText(curSelected,grpMenuShit);
          changeSelection();
        }
      }
    }

    if(accepted){
      if(option.accept())
        option.createOptionText(curSelected,grpMenuShit);

      changeSelection();
    }

	}

	override function destroy()
	{
		super.destroy();
	}

  function changeSelection(?diff:Int=0){
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		curSelected += diff;

		if (curSelected < 0)
			curSelected = Std.int(menuItems.length) - 1;
		if (curSelected >= Std.int(menuItems.length))
			curSelected = 0;


		for (i in 0...grpMenuShit.length)
		{
			var item = grpMenuShit.members[i];
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

	}

}
