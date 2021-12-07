package ui;
import states.*;
import flixel.tweens.FlxTween;
import haxe.Timer;

class ComboSprite extends FNFSprite {
  public var currentTween:FlxTween;
  //public var created:Float;
  var currentStyle:String='';
  public var number(default, set):String;
  public function set_number(val:String){
    if(animation.getByName(val)!=null){
      animation.play(val,true);
      return number=val;
    }else{
      animation.play('0',true);
      return number='0';
    }

  }

  public function setup(){
    alpha=1;
    if(currentTween!=null && currentTween.active){
      currentTween.cancel();
    }
    currentTween=null;
    scale.set(1,1);
    velocity.set(0,0);
    drag.set(0,0);
    maxVelocity.set(0,0);
    acceleration.set(0,0);
    updateHitbox();
    visible=true;
  }

  public function setStyle(style:String){
    if(style!=currentStyle){
      currentStyle=style;
      switch(style){
        case 'pixel':
          loadGraphic(Paths.image('pixelUI/numbers'), true, 10, 12);
          setGraphicSize(Std.int(width*PlayState.daPixelZoom));
        default:
          loadGraphic(Paths.image('numbers'), true, 91, 135);
      }
      var numbers = ["negative","0","1","2","3","4","5","6","7","8","9","point"];

      for(idx in 0...numbers.length){
        var anim = numbers[idx];
        animation.add(anim,[idx],0,false);
      }
    }
  }

  public function new(x:Float=0,y:Float=0,style='default'){
    super(x,y);
    setStyle(style);
    animation.play('0',true);
    number='0';

    //visible=false;
    //scrollFactor.set();
  }
}
