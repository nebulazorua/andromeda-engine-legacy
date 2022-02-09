package modchart.modifiers;
import ui.*;
import modchart.*;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import math.*;

class OpponentModifier extends Modifier {
  override function getPath(visualDiff:Float, pos:Vector3, data:Int, player:Int, timeDiff:Float){
    if(getPercent(player)==0)return pos;
    var nPlayer = Std.int(CoolUtil.scale(player,0,1,1,0));

    var oppX = modMgr.state.getXPosition(timeDiff, data, nPlayer);
    var plrX = modMgr.state.getXPosition(timeDiff, data, player);

    var distX = oppX-plrX;

    pos.x = pos.x + distX * getPercent(player);

    return pos;
  }
}
