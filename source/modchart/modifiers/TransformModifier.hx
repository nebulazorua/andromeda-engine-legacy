package modchart.modifiers;
import ui.*;
import modchart.*;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.FlxG;
import math.Vector3;
import math.*;

class TransformModifier extends Modifier { // this'll be transformX in ModManager
  inline function lerp(a:Float,b:Float,c:Float){
    return a+(b-a)*c;
  }

  override function getPath(visualDiff:Float, pos:Vector3, data:Int, player:Int, timeDiff:Float){
    pos.x += getPercent(player)*100;
    pos.y += getSubmodPercent("transformY",player)*100;
    pos.z += getSubmodPercent('transformZ',player)*100;

    pos.x += getSubmodPercent('transform${data}X',player)*100;
    pos.y += getSubmodPercent('transform${data}Y',player)*100;
    pos.z += getSubmodPercent('transform${data}Z',player)*100;

    return pos;
  }

  override function getSubmods(){
    var subMods:Array<String> = ["transformY","transformZ"];

    var receptors = modMgr.receptors[0];
    var kNum = receptors.length;
    for(recep in receptors){
      subMods.push('transform${recep.direction}X');
      subMods.push('transform${recep.direction}Y');
      subMods.push('transform${recep.direction}Z');
    }
    return subMods;
  }
}
