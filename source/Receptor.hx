// THANK YOU SRPEREZ FOR SOME MATH THAT I DONT UNDERSTAND
// (TAKEN FROM KE)

package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import haxe.unit.*;
import hscript.*;
import Note.NoteBehaviour;
import Shaders;
import flixel.util.FlxColor;

// TODO: have the receptor manage its own notes n shit

class Receptor extends FlxSprite {
  public static var dynamicColouring:Bool=false;


  public var baseAngle:Float = 0;
  public var desiredAngle:Float = 0;
  public var noteScale:Float = .7;
  public var skin:String= 'default';
  public var incomingAngle:Float = 0;
  public var defaultX:Float = 0;
  public var defaultY:Float = 0;
  public var incomingNoteAlpha:Float = 1;


  var colorSwap:ColorSwap;
  // if this is true, then it'll tint when it hits a note

  public function new(x:Float,y:Float,noteData:Int,skin:String='default',modifier:String='base',behaviour:NoteBehaviour,daScale:Float=.7){
    super(x,y);

    colorSwap = new ColorSwap();
    shader=colorSwap.shader;

    noteScale=daScale;
    this.skin=skin;
    var dirs = ["left","down","up","right"];
    var clrs = ["purple","blue","green","red"];
    var dir = dirs[noteData];

    switch(behaviour.actsLike){
      case 'default':
        frames = Paths.noteSkinAtlas(behaviour.arguments.receptors.sheet, 'skins', skin, modifier);

        antialiasing = behaviour.antialiasing;
        setGraphicSize(Std.int((width * behaviour.scale) * daScale/.7));

        var dir = dirs[noteData];
        var recepData = Reflect.field(behaviour.arguments.receptors,dir);
        animation.addByPrefix('static', recepData.prefix);
        animation.addByPrefix('pressed',recepData.press, 24, false);
        animation.addByPrefix('confirm',recepData.confirm, 24, false);
        var ang:Null<Float> = recepData.angle;
        if(ang==null)
          baseAngle = 0;
        else
          baseAngle = ang;

      case 'pixel':
        loadGraphic(Paths.noteSkinImage(behaviour.arguments.receptor.sheet, 'skins', skin, modifier), true, behaviour.arguments.receptor.gridSizeX, behaviour.arguments.receptor.gridSizeX);
        animation.add('green', [6]);
        animation.add('red', [7]);
        animation.add('blue', [5]);
        animation.add('purplel', [4]);

        setGraphicSize(Std.int((width * behaviour.scale) * daScale/.7));
        updateHitbox();
        antialiasing = behaviour.antialiasing;

        animation.add('static', Reflect.field(behaviour.arguments.receptor,'${dir}Idle') );
        animation.add('pressed', Reflect.field(behaviour.arguments.receptor,'${dir}Pressed'), 12, false);
        animation.add('confirm', Reflect.field(behaviour.arguments.receptor,'${dir}Confirm'), 24, false);
        var ang:Null<Float> = Reflect.field(behaviour.arguments.receptor,'${dir}Angle');

        if(ang==null)
          baseAngle = 0;
        else
          baseAngle = ang;
    }
    updateHitbox();
  }

  public function playNote(note:Note){
    playAnim("confirm",true);
    if(dynamicColouring){
      // TODO: finish this
      // its just not working lol

      //var colour:FlxColor = CoolUtil.getDominantColour(note);
      //colorSwap.hue=((colour.hue+1)%360)/360;
      //colorSwap.sat=colour.saturation;
      //colorSwap.val=colour.brightness;
    }
  }

  public function playAnim(anim:String,?force:Bool=false){
    colorSwap.hue=0;
    colorSwap.sat=0;
    colorSwap.val=0;

    animation.play(anim,force);
    updateHitbox();
    offset.set((frameWidth/2)-(54*(.7/noteScale) ),(frameHeight/2)-(56*(.7/noteScale) ) );
  }

  override function update(elapsed:Float){
    angle = baseAngle+desiredAngle;
    super.update(elapsed);
  }
}
