package modchart.modifiers;
import ui.*;
import modchart.*;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.FlxG;
import math.*;

class DrunkModifier extends Modifier {

  override function getPath(visualDiff:Float, pos:Vector3, data:Int, player:Int, timeDiff:Float){
    var drunkPerc = getPercent(player);
    var tipsyPerc = getSubmodPercent("tipsy",player);
    var bumpyPerc = getSubmodPercent("bumpy",player);

    var drunkAPerc = getSubmodPercent("drunkA",player);
    var tipsyAPerc = getSubmodPercent("tipsyA",player);
    var bumpyAPerc = getSubmodPercent("bumpyA",player);

    var bumpySpeed = CoolUtil.scale(getSubmodPercent("bumpySpeed",player),0,1,1,2);
    var timeFactor = getModPercent("waveTimeFactor", player);

    var time = (Conductor.songPosition/1000) * timeFactor;
    if(tipsyPerc!=0 || tipsyAPerc != 0){
      var speed = getSubmodPercent("tipsySpeed",player);
      var offset = getSubmodPercent("tipsyOffset",player);
      pos.y += (tipsyPerc + tipsyAPerc) * (FlxMath.fastCos((time*((speed*1.2)+1.2) + data*((offset * 1.8)+1.8))) * Note.swagWidth*.4);
    }

    if(drunkPerc!=0 || drunkAPerc!=0){
      var speed = getSubmodPercent("drunkSpeed",player);
      var period = getSubmodPercent("drunkPeriod",player);
      var offset = getSubmodPercent("drunkOffset",player);

      var angle = time * (1+speed) + data*( (offset*0.2) + 0.2)
		    + visualDiff * ( (period*10) + 10) / FlxG.height;
      pos.x += (drunkPerc + drunkAPerc) * (FlxMath.fastCos(angle) * Note.swagWidth * 0.5);
    }

    if(bumpyPerc!=0 || bumpyAPerc!=0){
      pos.z += ((bumpyPerc + bumpyAPerc) * (.3 * FlxMath.fastSin((visualDiff/24)*bumpySpeed)));
    }


    return pos;
  }

  override function getSubmods(){
    return [
      "tipsy",
      "bumpy",
      "drunkA",
      "tipsyA",
      "bumpyA",
      "drunkSpeed",
      "drunkOffset",
      "drunkPeriod",
      "tipsySpeed",
      "tipsyOffset",
      "bumpySpeed"
    ];
  }

}
