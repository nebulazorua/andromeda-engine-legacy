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
		var bumpyPerc = getSubmodPercent("bumpy", player);
		var tipZPerc = getSubmodPercent("tipZ", player);
    var timeFactor = getModPercent("waveTimeFactor", player);

    var time = (Conductor.songPosition/1000) * timeFactor;
    if(tipsyPerc!=0){
      var speed = getSubmodPercent("tipsySpeed",player);
      var offset = getSubmodPercent("tipsyOffset",player);
      pos.y += tipsyPerc * (FlxMath.fastCos((time*((speed*1.2)+1.2) + data*((offset * 1.8)+1.8))) * Note.swagWidth*.4);
    }

    if(drunkPerc!=0){
      var speed = getSubmodPercent("drunkSpeed",player);
      var period = getSubmodPercent("drunkPeriod",player);
      var offset = getSubmodPercent("drunkOffset",player);

      var angle = time * (1+speed) + data*( (offset*0.2) + 0.2)
		    + visualDiff * ( (period*10) + 10) / FlxG.height;
      pos.x += drunkPerc * (FlxMath.fastCos(angle) * Note.swagWidth * 0.5);
    }

		if (tipZPerc != 0)
		{
			var speed = getSubmodPercent("tipZSpeed", player);
			var offset = getSubmodPercent("tipZOffset", player);
			pos.z += tipZPerc * (FlxMath.fastCos((time * ((speed * 1.2) + 1.2) + data * ((offset * 1.8) + 3.2))) * 0.15);
		}


    if(bumpyPerc!=0){
			var period = getSubmodPercent("bumpyPeriod", player);
			var offset = getSubmodPercent("bumpyOffset", player);
			var angle = (visualDiff + (100.0 * offset)) / ((period * 16.0) + 16.0);
			pos.z += (bumpyPerc * 40 * FlxMath.fastSin(angle))/250;
    }


    return pos;
  }

  override function getSubmods(){
    return [
      "tipsy",
      "bumpy",
      "drunkSpeed",
      "drunkOffset",
      "drunkPeriod",
      "tipsySpeed",
      "tipsyOffset",
      "bumpyOffset",
      "bumpyPeriod",

      "tipZ",
			"tipZSpeed",
			"tipZOffset",

      "drunkZ",
      "drunkZSpeed",
      "drunkZOffset",
      "drunkZPeriod"
    ];
  }

}
