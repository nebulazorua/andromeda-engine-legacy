package ui;
import states.*;
import flixel.tweens.FlxTween;

class JudgeSprite extends FNFSprite {
  public var currentTween:FlxTween;
  var currentStyle:String='';
  public var judgement(default, set):String;
  public function set_judgement(val:String){
    if(animation.getByName(val)!=null){
      animation.play(val,true);
      return judgement=val;
    }else{
      animation.play('shit',true);
      return judgement='shit';
    }

  }
  public function setStyle(style:String){
    if(style!=currentStyle){
      currentStyle=style;
      switch(style){
        case 'pixel':
          loadGraphic(Paths.image('pixelUI/judgements'), true, 54, 20);
          animation.add('epic', [0], 0, false);
          animation.add('sick', [1], 0, false);
          animation.add('good', [2], 0, false);
          animation.add('bad', [3], 0, false);
          animation.add('shit', [4], 0, false);
          setGraphicSize(Std.int(width*PlayState.daPixelZoom));
        default:
          loadGraphic(Paths.image('judgements'), true, 403, 150);
          animation.add('epic', [0], 0, false);
          animation.add('sick', [1], 0, false);
          animation.add('good', [2], 0, false);
          animation.add('bad', [3], 0, false);
          animation.add('shit', [4], 0, false);
      }
    }
  }

  public function new(x:Float=0,y:Float=0,style='default'){
    super(x,y);
    setStyle(style);
    animation.play('shit',true);
    judgement='shit';

    visible=false;
    scrollFactor.set();
  }
}
