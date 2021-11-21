package modchart.modifiers;
import ui.*;
import modchart.*;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.FlxG;

class TornadoModifier extends Modifier {
  override function getNotePos(note:Note, pos:FlxPoint, data:Int, player:Int){
    if(getPercent(player)==0)return pos;

    var width = 3;
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
    note.z += z;

    return pos;
  }
}
