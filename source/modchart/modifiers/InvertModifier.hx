package modchart.modifiers;
import ui.*;
import modchart.*;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;

class InvertModifier extends Modifier {
  override function getReceptorPos(receptor:Receptor, pos:FlxPoint, data:Int, player:Int){
    if(getPercent(player)==0)return pos;

    var receptors = modMgr.receptors[player];
    var kNum = receptors.length-1;

    var first:Int = 0;
    var last:Int = kNum;
    var left:Int = Std.int((kNum-1)/2);
    var right:Int = Std.int((kNum+1)/2);
    if(data<=left){
        first = 0;
        last = left;
    }else if(data>=right){
        first = right;
        last = kNum;
    }else{
        first = Std.int(kNum/2);
        last = Std.int(kNum/2);
    }

    var newIdx:Int = Std.int(CoolUtil.scale(data,first,last,last,first));
    var cRec = receptor;
    var nRec = receptors[newIdx];
    var oldOffset = cRec.defaultX;
    var newOffset = nRec.defaultX;
    var dist = newOffset-oldOffset;
    pos.x += dist * getPercent(player);

    return pos;
  }
}
