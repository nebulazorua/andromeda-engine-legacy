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


  public function new(x:Float,y:Float,noteData:Int,skin:String='default',type:String='base',daScale:Float=.7){
    super(x,y);

    noteScale=daScale;
    this.skin=skin;
    var dirs = ["left","down","up","right"];
    var clrs = ["purple","blue","green","red"];
    var dir = dirs[noteData];

    switch(type){
      case 'base':
        frames = Paths.noteSkinAtlas("NOTE_assets", 'skins', skin, 'base');

        antialiasing = true;
        setGraphicSize(Std.int(width * daScale));

        var dir = dirs[noteData];
        animation.addByPrefix('static', 'arrow${dir.toUpperCase()}');
        animation.addByPrefix('pressed', '${dir} press', 24, false);
        animation.addByPrefix('confirm', '${dir} confirm', 24, false);
      case 'pixel':
        loadGraphic(Paths.noteSkinImage("arrows", 'skins', skin, 'pixel'), true, 17, 17);
        animation.add('green', [6]);
        animation.add('red', [7]);
        animation.add('blue', [5]);
        animation.add('purplel', [4]);

        setGraphicSize(Std.int((width * PlayState.daPixelZoom) * daScale/.7));
        updateHitbox();
        antialiasing = false;

        animation.add('static', [noteData]);
        animation.add('pressed', [noteData+4,noteData+8], 12, false);
        animation.add('confirm', [noteData+12,noteData+16], 24, false);
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
