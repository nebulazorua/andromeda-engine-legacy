package modchart.modifiers;
import ui.*;
import modchart.*;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import math.*;

class AngleModifier extends Modifier {
  override function getPath(visualDiff:Float, pos:Vector3, data:Int, player:Int, timeDiff:Float){
    if(getPercent(player)==0)return pos;

    //pos.copyFrom(CoolUtil.rotate(pos.x,pos.y,getPercent(player)));
    var rotated = CoolUtil.rotate(pos.x,pos.y,getPercent(player)*100);
    pos.x = rotated.x;
    pos.y = rotated.y;
    
    return pos;
  }
}
