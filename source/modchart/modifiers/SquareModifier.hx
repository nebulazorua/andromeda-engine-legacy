package modchart.modifiers;
import ui.*;
import modchart.*;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import math.*;

class SquareModifier extends Modifier {
  // https://github.com/stepmania/stepmania/blob/984dc8668f1fedacf553f279a828acdebffc5625/src/ArrowEffects.cpp
  override function getPath(visualDiff:Float, pos:Vector3, data:Int, player:Int, timeDiff:Float){
    if(getPercent(player)==0)return pos;
    var offset = getSubmodPercent("squareOffset",player);
    var period = getSubmodPercent("squarePeriod",player);
    var perc = getPercent(player)*100;
    var cum:Float = (Math.PI * (visualDiff+(1*(offset))) /
			(Note.swagWidth+(period*Note.swagWidth)));
    var fResult = CoolUtil.square( cum );



		pos.x += getPercent(player) * Note.swagWidth * 0.5 * fResult;

    return pos;
  }

  override function getSubmods(){
    return ["squarePeriod","squareOffset"];
  }

}
