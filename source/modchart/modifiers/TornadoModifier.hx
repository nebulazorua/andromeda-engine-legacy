package modchart.modifiers;
import ui.*;
import modchart.*;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.FlxG;
import math.*;

class TornadoModifier extends Modifier {
  //override function getNotePos(note:Note, pos:Vector3, data:Int, player:Int){
  override function getPath(visualDiff:Float, pos:Vector3, data:Int, player:Int, timeDiff:Float){
    if(getPercent(player)==0)return pos;

    var receptors = modMgr.receptors[player];
    var len = receptors.length;
    // thank you 4mbr0s3
    var playerColumn = data % receptors.length;
    var columnPhaseShift = playerColumn * Math.PI / 3;
    var phaseShift =visualDiff / 135;
    var returnReceptorToZeroOffsetX = (-Math.cos(-columnPhaseShift) + 1) / 2 * Note.swagWidth * 3;
    var offsetX = (-Math.cos(phaseShift - columnPhaseShift) + 1) / 2 * Note.swagWidth * 3 - returnReceptorToZeroOffsetX;
    var outPos = pos.clone();
    return outPos.add(new Vector3(offsetX * getPercent(player)));

    /*var width = 2;
    var receptors = modMgr.receptors[player];
    var len = receptors.length;

    var start:Int = data-width;
    var end:Int = data+width;
    start = Std.int(CoolUtil.clamp(start,0,len));
    end = Std.int(CoolUtil.clamp(end,0,len));

    var min:Float = FlxMath.MAX_VALUE_FLOAT;
    var max:Float = -FlxMath.MAX_VALUE_FLOAT;

    for(i in start...end){
      var rec = receptors[i];
      min = Math.min(min,rec.defaultX);
      max = Math.max(max,rec.defaultX);
    }

    var offset:Float = receptors[data].defaultX;
    var between:Float = CoolUtil.scale(offset,min,max,-1,1);
    var rads:Float = Math.acos(between);
    rads += pos.y * 6 / FlxG.height;

    var adjustedOffset = CoolUtil.scale(FlxMath.fastCos(rads),-1,1,min,max);
    var z = CoolUtil.scale(FlxMath.fastSin(rads),0,1,0,0.1);
    pos.x += (adjustedOffset-offset)*getPercent(player);
    pos.z += z;

    return pos;*/
  }
}
