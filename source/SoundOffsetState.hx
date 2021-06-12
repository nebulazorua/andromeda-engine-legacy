package;
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

class SoundOffsetState extends MusicBeatState
{
  public var playingAudio:Bool=false;
  public var status:FlxText;
  public var beatCounter:Float = 0;
  public var beatCounts=[];
  public var currOffset:Int = OptionUtils.options.noteOffset;
  public var offsetTxt:FlxText;
  public var metronome:Character;
  override function create(){
    #if desktop
    // Updating Discord Rich Presence
    DiscordClient.changePresence("Calibrating audio", null);
    #end
    var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menuDesat"));

    menuBG.color = 0xFFa271de;
    menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
    menuBG.updateHitbox();
    menuBG.screenCenter();
    menuBG.antialiasing = true;
    add(menuBG);

    var title:FlxText = new FlxText(0, 20, 0, "Audio Calibration", 32);
    title.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    title.screenCenter(X);
    add(title);

    status = new FlxText(0, 50, 0, "Audio is paused", 24);
    status.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    status.screenCenter(X);
    add(status);

    offsetTxt = new FlxText(0, 80, 0, "Current offset: 0ms", 24);
    offsetTxt.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    offsetTxt.screenCenter(X);
    add(offsetTxt);


    var instructions:FlxText = new FlxText(0, 125, 0, "Press the spacebar to pause/play the beat\nPress enter in time with the beat to get an approximate offset\nPress R to reset\nPress left and right to adjust the offset manually. Hold shift for precision.\nPress ESC to go back and save the current offset", 24);
    instructions.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    instructions.screenCenter(X);
    add(instructions);

    metronome = new Character(FlxG.width/2,300,'gf');
    metronome.setGraphicSize(Std.int(metronome.width*.6));
    metronome.screenCenter(XY);
    metronome.y += 100;
    add(metronome);
  }

  override function beatHit(){
    super.beatHit();
    beatCounter=0;
    if(playingAudio){
      FlxG.sound.play(Paths.sound('beat'),1);
      metronome.dance();
    }


  }

  override function update(elapsed:Float){
    if(playingAudio){
      if (FlxG.sound.music.volume > 0)
      {
        FlxG.sound.music.volume -= 0.5 * FlxG.elapsed;
      }
      beatCounter+=elapsed*1000;
      status.text = "Audio is playing";
      Conductor.changeBPM(50);
      Conductor.songPosition += FlxG.elapsed * 1000;
    }else{
      if (FlxG.sound.music.volume < 0.7)
      {
        FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
      }
      status.text = "Audio is paused";
      Conductor.changeBPM(0);
      Conductor.songPosition = 0;
      beatCounter=0;
    }

    offsetTxt.text = 'Current offset:  ${currOffset}ms';

    status.screenCenter(X);
    if(FlxG.keys.justPressed.SPACE){
      playingAudio = !playingAudio;
      if(playingAudio==false){
        OptionUtils.options.noteOffset=currOffset;
      }
    }

    if(playingAudio){
      if(FlxG.keys.justPressed.ENTER){
        beatCounts.push(beatCounter);
        var total:Float = 0;
        for(i in beatCounts){
          total+=i;
        }
        currOffset=Std.int(total/beatCounts.length);
      }
    }
    if(FlxG.keys.justPressed.R){
      beatCounts = [];
      currOffset = 0;
    }
    if(FlxG.keys.justPressed.ESCAPE){
      OptionUtils.options.noteOffset = currOffset;
      OptionUtils.saveOptions(OptionUtils.options);
      FlxG.switchState(new OptionsMenu());
    }

    if(!FlxG.keys.pressed.SHIFT){
      if(FlxG.keys.pressed.LEFT){
        currOffset--;
      };
      if(FlxG.keys.pressed.RIGHT){
        currOffset++;
      };
    }else{
      if(FlxG.keys.justPressed.LEFT){
        currOffset--;
      };
      if(FlxG.keys.justPressed.RIGHT){
        currOffset++;
      };
    }

    super.update(elapsed);
  }

}
