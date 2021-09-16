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

// TODO: have the receptor manage its own notes n shit

class Receptor extends FlxSprite {
  public var baseAngle:Float = 0;
  public var desiredAngle:Float = 0;
  public var noteScale:Float = .7;
  public var skin:String= 'default';
  public var incomingAngle:Float = 0;
  public var defaultX:Float = 0;
  public var defaultY:Float = 0;
  public var incomingNoteAlpha:Float = 1;


  public function new(x:Float,y:Float,noteData:Int,skin:String='default',modifier:String='base',behaviour:NoteBehaviour,daScale:Float=.7){
    super(x,y);

    noteScale=daScale;
    this.skin=skin;
    var dirs = ["left","down","up","right"];
    var clrs = ["purple","blue","green","red"];
    var dir = dirs[noteData];

    switch(behaviour.actsLike){
      case 'default':
        frames = Paths.noteSkinAtlas(behaviour.arguments.spritesheet, 'skins', skin, modifier);

        antialiasing = behaviour.antialiasing;
        setGraphicSize(Std.int((width * behaviour.scale) * daScale/.7));

        var dir = dirs[noteData];
        animation.addByPrefix('static', Reflect.field(behaviour.arguments,'${dir}ReceptorPrefix')+"0");
        animation.addByPrefix('pressed',  Reflect.field(behaviour.arguments,'${dir}ReceptorPressPrefix')+"0", 24, false);
        animation.addByPrefix('confirm',  Reflect.field(behaviour.arguments,'${dir}ReceptorConfirmPrefix')+"0", 24, false);
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
    }
    updateHitbox();
  }

  public function playAnim(anim:String,?force:Bool=false){
    animation.play(anim,force);
    updateHitbox();
    offset.set((frameWidth/2)-(54*(.7/noteScale) ),(frameHeight/2)-(56*(.7/noteScale) ) );
  }

  override function update(elapsed:Float){
    angle = baseAngle+desiredAngle;
    super.update(elapsed);
  }
}
