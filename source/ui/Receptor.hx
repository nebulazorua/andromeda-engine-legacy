// THANK YOU SRPEREZ FOR SOME MATH THAT I DONT UNDERSTAND
// (TAKEN FROM KE)

package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import haxe.unit.*;
import hscript.*;
import ui.Note.NoteBehaviour;
import Shaders;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;

// TODO: have the receptor manage its own notes n shit

class Receptor extends FNFSprite {
  public static var dynamicColouring:Bool=false;  // if this is true, then it'll tint to the hit note's dominant colour when it hits a note
  // (DOESNT WORK RN!)

  public var playerNum:Int=0;
  public var baseAngle:Float = 0;
  public var desiredAngle:Float = 0;
  public var noteScale:Float = .7;
  public var skin:String= 'default';
  public var incomingAngle:Float = 0;
  public var defaultX:Float = 0;
  public var defaultY:Float = 0;
  public var incomingNoteAlpha:Float = 1;
  public var direction:Int= 0 ;
  public var xOffset:Float = 0;
  public var yOffset:Float = 0;
  public var zOffset:Float = 0;

  public var desiredZIndex:Float = 0;

  public var scaleDefault:Null<FlxPoint>;
  public var noteSplash:NoteSplash;

  public var desiredX:Float = 0;
  public var desiredY:Float = 0;
  public var desiredZ:Float = 0;


  public function new(x:Float,y:Float,noteData:Int,skin:String='default',modifier:String='base',behaviour:NoteBehaviour,daScale:Float=.7){
    super(x,y);
    desiredX=x;
    desiredY=y;

    noteSplash = new NoteSplash(x,y);
    noteSplash.visible=false;

    scaleDefault = FlxPoint.get();

    //colorSwap = new ColorSwap();
    //shader=colorSwap.shader;

    direction=noteData;
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
        loadGraphic(Paths.noteSkinImage(behaviour.arguments.receptor.sheet, 'skins', skin, modifier),true,behaviour.arguments.receptor.gridSizeX,behaviour.arguments.receptor.gridSizeY);
        trace(width,behaviour.arguments.receptor.sheet);

        setGraphicSize(Std.int((width * behaviour.scale) * daScale/.7));
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

    scaleDefault.set(scale.x,scale.y);
  }

  public function playNote(note:Note,doSplash:Bool=false){
    playAnim("confirm",true);
    if(doSplash)
      noteSplash.setup(note,this);

  }

  override function destroy(){
    super.destroy();
  }

  public function playAnim(anim:String,?force:Bool=false){
    animation.play(anim,force);
    updateHitbox();
    offset.set((frameWidth/2)-(54*(.7/noteScale) ),(frameHeight/2)-(56*(.7/noteScale)));
    updateZIndex();
  }

  public function getZIndex(){
    var animZOffset:Float = 0;
    if(animation.curAnim!=null && animation.curAnim.name=='confirm')animZOffset+=1;
    return z + desiredZIndex + animZOffset - playerNum;
  }

  function updateZIndex(){
    zIndex=getZIndex();
  }

  override function update(elapsed:Float){
    angle = baseAngle+desiredAngle;


    x = desiredX + xOffset;
    y = desiredY + yOffset;
    z = desiredZ + zOffset;
    updateZIndex();

    super.update(elapsed);

  }
}
