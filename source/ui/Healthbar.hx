package ui;

import flixel.FlxSprite;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.FlxBasic;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;

class Healthbar extends FlxSpriteGroup {
  public var bg:FlxSprite;
  public var bar:FlxBar;
  public var iconP1:HealthIcon;
  public var iconP2:HealthIcon;
  public var smooth:Bool = false;

  public var value:Float = 1;

  var display:Float = 1;
  var instance:FlxBasic;
  var property:String;
  public function new(x:Float,y:Float,player1:String,player2:String,?instance:FlxBasic,?property:String,min:Float=0,max:Float=2,baseColor:FlxColor=0xFFFF0000,secondaryColor:FlxColor=0xFF66FF33){
    super(x,y);
    if(property==null || instance==null){
      property='value';
      instance=this;
    }


    this.instance=instance;
    this.property=property;
    display = Reflect.getProperty(instance,property);
    bg = new FlxSprite(0, 0).loadGraphic(Paths.image('healthBar','shared'));

    bar = new FlxBar(bg.x + 4, bg.y + 4, RIGHT_TO_LEFT, Std.int(bg.width - 8), Std.int(bg.height - 8), this, 'display', min, max);
    bar.createFilledBar(baseColor,secondaryColor);


    iconP1 = new HealthIcon(player1, true);
    iconP1.y = bar.y - (iconP1.height / 2);


    iconP2 = new HealthIcon(player2, false);
    iconP2.y = bar.y - (iconP2.height / 2);
    add(bg);
    add(bar);
    add(iconP1);
    add(iconP2);

  }
  public function setIcons(?player1,?player2){
    player1=player1==null?iconP1.animation.curAnim.name:player1;
    player2=player2==null?iconP2.animation.curAnim.name:player2;
    iconP1.changeCharacter(player1);
    iconP2.changeCharacter(player2);
  }

  public function setColors(baseColor:FlxColor,secondaryColor:FlxColor){
    bar.createFilledBar(baseColor,secondaryColor);
    bar.updateBar();
  }
  public function setIconSize(iconP1Size:Int,iconP2Size:Int){
    iconP1.setGraphicSize(Std.int(iconP1Size));
    iconP2.setGraphicSize(Std.int(iconP2Size));

    iconP1.updateHitbox();
    iconP2.updateHitbox();
  }
  public function beatHit(curBeat:Float){
    setIconSize(Std.int(iconP1.width+30),Std.int(iconP2.width+30));
  }

  override function update(elapsed:Float){
    var num = Reflect.getProperty(instance,property);
    if(smooth){
      display = FlxMath.lerp(display,num,Main.adjustFPS(.2));
      if(Math.abs(display-num)<.1){
        display=num;
      }
    }else{
      display=num;
    }

    var percent = bar.percent;
    var opponentPercent = 100-bar.percent;
    setIconSize(Std.int(FlxMath.lerp(iconP1.width, 150, Main.adjustFPS(0.1))),Std.int(FlxMath.lerp(iconP2.width, 150, Main.adjustFPS(0.1))));
    var iconOffset:Int = 26;
    iconP1.x = bar.x + (bar.width * (FlxMath.remapToRange(percent, 0, 100, 100, 0) * 0.01) - iconOffset);
    iconP2.x = bar.x + (bar.width * (FlxMath.remapToRange(percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

    if (percent < 20 && iconP1.lossIndex!=-1)
      iconP1.animation.curAnim.curFrame = iconP1.lossIndex;
    else if(percent > 80 && iconP1.winningIndex!=-1)
      iconP1.animation.curAnim.curFrame = iconP1.winningIndex;
    else
      iconP1.animation.curAnim.curFrame = iconP1.neutralIndex;


    if (opponentPercent < 20 && iconP2.lossIndex!=-1)
      iconP2.animation.curAnim.curFrame = iconP2.lossIndex;
    else if(opponentPercent > 80 && iconP2.winningIndex!=-1)
      iconP2.animation.curAnim.curFrame = iconP2.winningIndex;
    else
      iconP2.animation.curAnim.curFrame = iconP2.neutralIndex;

    super.update(elapsed);


  }
}
