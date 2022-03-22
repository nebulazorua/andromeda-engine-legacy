package modchart.modifiers;
import ui.*;
import modchart.*;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import math.*;

class BounceModifier extends Modifier {
  // https://github.com/stepmania/stepmania/blob/984dc8668f1fedacf553f279a828acdebffc5625/src/ArrowEffects.cpp
  override function getPath(visualDiff:Float, pos:Vector3, data:Int, player:Int, timeDiff:Float){
    if(getPercent(player)==0)return pos;
    // https://github.com/stepmania/stepmania/blob/984dc8668f1fedacf553f279a828acdebffc5625/src/ArrowEffects.cpp
    var offset = getSubmodPercent("bounceOffset",player)*100;

    var bounce:Float = Math.abs( FlxMath.fastSin( ( (visualDiff + (1 * (offset) ) ) /
			( 60 + (getSubmodPercent("bouncePeriod",player)*60) ) ) ) );

		pos.x += getPercent(player) * Note.swagWidth * 0.5 * bounce;



    return pos;
  }

  override function getSubmods(){
    return ["bouncePeriod", "bounceOffset"];
  }

}
