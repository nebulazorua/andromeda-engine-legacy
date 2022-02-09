package modchart.modifiers;
import ui.*;
import modchart.*;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import math.*;

class InvertModifier extends Modifier {
  /*override function getPath(visualDiff:Float, pos:Vector3, data:Int, player:Int, timeDiff:Float){
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
    var cRec = receptors;
    var nRec = receptors[newIdx];
    var oldOffset = cRec.defaultX;
    var newOffset = nRec.defaultX;
    var dist = newOffset-oldOffset;
    pos.x += dist * getPercent(player);

    return pos;
  }*/

  override function getPath(visualDiff:Float, pos:Vector3, data:Int, player:Int, timeDiff:Float){
    if(getPercent(player)==0)return pos;

    var receptors = modMgr.receptors[player];
    var kNum = receptors.length-1;

    var distance = Note.swagWidth * ((data%2==0)?1:-1);
    pos.x += distance * getPercent(player);

    return pos;
  }
}
