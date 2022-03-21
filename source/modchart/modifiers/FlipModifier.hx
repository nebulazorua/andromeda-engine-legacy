package modchart.modifiers;
import ui.*;
import modchart.*;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import math.*;

class FlipModifier extends Modifier {

  override function getPath(visualDiff:Float, pos:Vector3, data:Int, player:Int, timeDiff:Float){
    if(getPercent(player)==0)return pos;

    var receptors = modMgr.receptors[player];
    var kNum = receptors.length-1;

    var distance = Note.swagWidth * (receptors.length/2) * (1.5-data);
    pos.x += distance * getPercent(player);

    return pos;
  }
}
