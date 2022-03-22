package modchart.modifiers;
import ui.*;
import modchart.*;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import math.*;

class SawtoothModifier extends Modifier {

  // https://github.com/stepmania/stepmania/blob/984dc8668f1fedacf553f279a828acdebffc5625/src/ArrowEffects.cpp
  override function getPath(visualDiff:Float, pos:Vector3, data:Int, player:Int, timeDiff:Float){
    if(getPercent(player)==0)return pos;

    var percent = getPercent(player);
    var period = (getSubmodPercent("sawtoothPeriod",player)) + 1;
    pos.x += (percent*Note.swagWidth) *
    ((0.5 / period * visualDiff) / Note.swagWidth -
    Math.floor((0.5 / period * visualDiff) / Note.swagWidth) );



    return pos;
  }

  override function getSubmods(){
    return ["sawtoothPeriod"];
  }

}
