package modchart.modifiers;
import ui.*;
import modchart.*;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;

class OpponentModifier extends Modifier {
  override function getReceptorPos(receptor:Receptor, pos:FlxPoint, data:Int, player:Int){
    if(getPercent(player)==0)return pos;
    var nPlayer = Std.int(CoolUtil.scale(player,0,1,1,0));
    var receptors = modMgr.receptors[nPlayer];

    var current = receptor;
    var next = receptors[data];
    var distX = next.defaultX-current.defaultX;
    var distY = next.defaultY-current.defaultY;

    pos.x = pos.x + distX * getPercent(player);
    pos.y = pos.y + distY * getPercent(player);

    return pos;
  }
}
