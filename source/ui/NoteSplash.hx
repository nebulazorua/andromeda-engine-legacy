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
import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.FlxGraphic;

class NoteSplash extends FlxSprite{
  public static var splashCache:Map<String,Map<String,FlxFramesCollection>>=[];
  var animFramerate:Float = 24;
  var splashOffset:Array<Null<Float>>=[];
  var splashAngle:Float = 0;
  var loadedSplashData:Dynamic;
  public function setTextures(note:Note){
    var behaviour = note.behaviour;
    // TODO: quants
    var args = behaviour.arguments.splashes;
    if(args!=null){

      var cache = splashCache.get(note.modifier);
      if(cache==null)cache = new Map<String,FlxFramesCollection>();
      if(frames!=cache.get(note.graphicType) || !cache.exists(note.graphicType)){
        frames = !cache.exists(note.graphicType)?Paths.noteSkinAtlas(args.sheet, 'skins', note.skin, note.modifier, note.graphicType):cache.get(note.graphicType);
        frames.parent.persist=true;
        cache.set(note.graphicType,frames);
        splashCache.set(note.modifier,cache);
      }

      var dirs = ["left","down","up","right"];
      var data = Reflect.field(args,dirs[note.noteData]);
      if(data!=null){
        if(loadedSplashData==data)return;
        loadedSplashData=data;
        var framerate:Null<Int> = 24;
        var angel:Null<Float> = 0;
        if(data.angle!=null)angel=data.angle;
        if(data.framerate!=null)framerate=data.framerate;
        animFramerate=framerate;
        splashAngle=angel;
        animation.addByPrefix('splash', data.prefix, framerate, false);
        if(data.offsetX==null)splashOffset[0]=0;else splashOffset[0]=data.offsetX;
        if(data.offsetY==null)splashOffset[1]=0;else splashOffset[1]=data.offsetY;
      }else{
        //kill();
        visible=false;
        trace("nothing for this one!!");
      }
    }else{
      //kill();
      visible=false;
    }
  }

  public function play(receptor:Receptor){
    visible=true;
    setPosition(receptor.x - Note.swagWidth - receptor.offset.x,receptor.y - Note.swagWidth - receptor.offset.y);
    animation.play('splash',true);
    scrollFactor.copyFrom(receptor.scrollFactor);
    centerOffsets();
    offset.x += splashOffset[0];
    offset.y += splashOffset[1];
    angle = splashAngle;
    animation.curAnim.frameRate = animFramerate + FlxG.random.int(-2,2);
  }

  public function setup(note:Note,?receptor:Receptor){
    var behaviour = note.behaviour;
    var args = behaviour.arguments.splashes;
    if(args==null){
      //kill();
      visible=false;
      return;
    }
    setTextures(note);
    if(animation.getByName("splash")!=null){
      var dirs = ["left","down","up","right"];
      var data = Reflect.field(args,dirs[note.noteData]);
      var nScale:Null<Float> = args.scale==null?1:args.scale;
      if(data!=null && data.scale!=null)
        nScale=data.scale;

      var argAlpha:Null<Float> = data.alpha==null?args.alpha:data.alpha;

      alpha = argAlpha==null?0.6:argAlpha;

      antialiasing=!!args.antialiasing;
      // something something static platforms null cant be bool
      // so i need to do this because if args.antialiasing==null then antialiasing will be false, not null
      if(args.antialiasing!=antialiasing)antialiasing=true;

      visible=false;
      scale.set(nScale,nScale);
      updateHitbox();

      if(receptor!=null)
        play(receptor);
    }else{
      //kill();
      visible=false;
      return;
    }
  }
  public function new(x:Float,y:Float){
    super(x,y);
    animation.finishCallback = function(name:String){
      //kill();
      visible=false;
    }
    setPosition(x-Note.swagWidth/2,y-Note.swagWidth/2);
    visible=false;
  }
}
