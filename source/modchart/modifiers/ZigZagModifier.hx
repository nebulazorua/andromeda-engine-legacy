package modchart.modifiers;
import ui.*;
import modchart.*;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import math.*;

//https://github.com/stepmania/stepmania/blob/984dc8668f1fedacf553f279a828acdebffc5625/src/ArrowEffects.cpp
class ZigZagModifier extends Modifier {

  override function getPath(visualDiff:Float, pos:Vector3, data:Int, player:Int, timeDiff:Float){
    if(getPercent(player)==0)return pos;
    var offset = getSubmodPercent("zigzagOffset",player);
    var period = getSubmodPercent("zigzagPeriod",player);
    var perc = getPercent(player);

    var result:Float = CoolUtil.triangle( (Math.PI * (1/(period+1)) *
		((visualDiff+(100*(offset )))/Note.swagWidth) ) );

		pos.x += (perc*Note.swagWidth/2) * result;


    return pos;
  }

  override function getSubmods(){
    return ["zigzagPeriod","zigzagOffset"];
  }

}
