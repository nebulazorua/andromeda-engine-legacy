package modchart.modifiers;
import ui.*;
import modchart.*;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;

class FlipModifier extends Modifier {
  override function getReceptorPos(receptor:Receptor, pos:FlxPoint, data:Int, player:Int){
    if(getPercent(player)==0)return pos;

    var receptors = modMgr.receptors[player];
    var kNum = receptors.length-1;

    var idx:Int = Std.int(CoolUtil.scale(data,0,kNum,kNum,0));
    var current = receptor;
    var next = receptors[idx];
    var dist = next.defaultX-current.defaultX;

    pos.x = pos.x + dist * getPercent(player);

    return pos;
  }
}
