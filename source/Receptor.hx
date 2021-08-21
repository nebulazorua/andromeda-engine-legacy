package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;

// TODO: have the receptor manage its own notes n shit

class Receptor extends FlxSprite {
  public var baseAngle:Float = 0;
  public var desiredAngle:Float = 0;
  public var noteScale:Float = .7;
  public var skin:String= 'default';

  public function new(x:Float,y:Float,noteData:Int,skin:String='default',daScale:Float=.7){
    super(x,y);

    noteScale=daScale;
    this.skin=skin;
    var dirs = ["left","down","up","right"];
    var clrs = ["purple","blue","green","red"];
    var dir = dirs[noteData];

    switch(skin){
      case 'default':
        frames = Paths.getSparrowAtlas('NOTE_assets','shared');

        antialiasing = true;
        setGraphicSize(Std.int(width * daScale));

        var dir = dirs[noteData];
        animation.addByPrefix('static', 'arrow${dir.toUpperCase()}');
        animation.addByPrefix('pressed', '${dir} press', 24, false);
        animation.addByPrefix('confirm', '${dir} confirm', 24, false);
      case 'pixel':
        loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
        animation.add('green', [6]);
        animation.add('red', [7]);
        animation.add('blue', [5]);
        animation.add('purplel', [4]);

        setGraphicSize(Std.int((width * PlayState.daPixelZoom) * daScale));
        updateHitbox();
        antialiasing = false;

        animation.add('static', [noteData]);
        animation.add('pressed', [noteData+4,noteData+8], 12, false);
        animation.add('confirm', [noteData+12,noteData+16], 24, false);
    }
    updateHitbox();
  }

  public function playAnim(anim:String,?force:Bool=false){ // THANKS KE FOR SOME SHIT https://github.com/KadeDev/Kade-Engine/blob/master/source/StaticArrow.hx
    animation.play(anim,force);
    updateHitbox();
    offset.set((frameWidth/2)-(54*(.7/noteScale) ),(frameHeight/2)-(56*(.7/noteScale) ) );
    angle = baseAngle+desiredAngle;
  }

  override function update(elapsed:Float){
    angle = baseAngle+desiredAngle;
    super.update(elapsed);
    if(FlxG.keys.justPressed.Z){
      trace("a");
      baseAngle+=10;
    }
  }
}
