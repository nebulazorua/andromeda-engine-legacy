package modchart.modifiers;
import ui.*;
import modchart.*;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import math.*;

class OpponentModifier extends Modifier {
  override function getPath(visualDiff:Float, pos:Vector3, data:Int, player:Int, sprite: FNFSprite, timeDiff:Float){
    if(getPercent(player)==0)return pos;
    var nPlayer = Std.int(CoolUtil.scale(player,0,1,1,0));

    var oppReceptors = modMgr.receptors[nPlayer];
    var plrReceptors = modMgr.receptors[player];

    var current = plrReceptors[data];
    var next = oppReceptors[data];
    var distX = next.defaultX-current.defaultX;
    var distY = next.defaultY-current.defaultY;

    pos.x = pos.x + distX * getPercent(player);
    pos.y = pos.y + distY * getPercent(player);

    return pos;
  }
}
