package modchart.modifiers;

import modchart.*;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.FlxG;

class DrunkModifier extends Modifier {

  override function getPos(pos:FlxPoint, data:Int, player:Int){
    var drunkPerc = getPercent(player);
    var tipsyPerc = getSubmodPercent("tipsy",player);
    var tipsySpeed = CoolUtil.scale(getSubmodPercent("tipsySpeed",player),0,1,1,2);
    var drunkSpeed = CoolUtil.scale(getSubmodPercent("drunkSpeed",player),0,1,1,2);

    var time = Conductor.songPosition/1000;

    if(drunkPerc!=0){
      pos.x += drunkPerc * (FlxMath.fastCos((time + data*.2 + pos.y*10/FlxG.height)*drunkSpeed) * Note.swagWidth*.5);
    }

    if(tipsyPerc!=0){
      pos.y += tipsyPerc * (FlxMath.fastCos((time*1.2 + data*1.8)*tipsySpeed) * Note.swagWidth*.4);
    }

    return pos;
  }




  override function getSubmods(){
    return ["tipsy","drunkSpeed","tipsySpeed"];
  }

}
