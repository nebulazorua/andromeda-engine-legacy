package modchart.modifiers;
import ui.*;
import modchart.*;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.FlxG;
import math.Vector3;

class TransformModifier extends Modifier { // this'll be transformX in ModManager
  inline function lerp(a:Float,b:Float,c:Float){
    return a+(b-a)*c;
  }

  // thanks schmoovin'
  function rotateV3(vec:Vector3,xA:Float,yA:Float,zA:Float):Vector3{
    var rZ = CoolUtil.rotate(vec.x, vec.y, zA);
		var oZ = new Vector3(rZ.x, rZ.y, vec.z);
		var rX = CoolUtil.rotate(oZ.z, oZ.y, xA);
		var oX = new Vector3(oZ.x, rX.y,rX.x);
		var rY = CoolUtil.rotate(oX.x, oX.z, yA);

		return new Vector3(rY.x, oX.y, rY.y);

  }

  override function getReceptorPos(receptor:Receptor, pos:FlxPoint, data:Int, player:Int){
    pos.x += getPercent(player)*100;
    pos.y += getSubmodPercent("transformY",player)*100;
    receptor.z += getSubmodPercent('transformZ',player)*100;

    pos.x += getSubmodPercent('transform${receptor.direction}X',player)*100;
    pos.y += getSubmodPercent('transform${receptor.direction}Y',player)*100;

    receptor.z += getSubmodPercent('transform${receptor.direction}Z',player)*100;

    return pos;
  }

  /*override function getPos(pos:FlxPoint, data:Int, player:Int, obj:FNFSprite){
    // thank u schmovin
    var rX = getSubmodPercent("rotateX",player)*100;
    var rY = getSubmodPercent("rotateY",player)*100;
    var rZ = getSubmodPercent("rotateZ",player)*100;

    var receptor = modMgr.receptors[player][data];

    var origin = new FlxPoint(receptor.defaultX,0);
    if(obj is Note){
      origin.y = receptor.y;
    }
    var diffPoint = pos.subtractPoint(origin);
    var zScale = FlxG.height;
    var diff = new Vector3(diffPoint.x,diffPoint.y,obj.z);
    diff.z *= zScale;

    var newV3 = rotateV3(diff,rX,rY,rZ);
    newV3.z /= zScale;
    pos = origin.add(newV3.x,newV3.y);
    obj.z = newV3.z;

    return pos;
  }*/

  // TODO: overhaul modifier system some time


  override function getNotePos(note:Note, pos:FlxPoint, data:Int, player:Int){
    pos.x += getPercent(player)*100;
    pos.y += getSubmodPercent("transformY",player)*100;
    note.z += getSubmodPercent('transformZ',player)*100;

    pos.x += getSubmodPercent('transform${data}X',player)*100;
    pos.y += getSubmodPercent('transform${data}Y',player)*100;

    note.z += getSubmodPercent('transform${data}Z',player)*100;

    return pos;
  }

  override function getSubmods(){
    var subMods:Array<String> = ["transformY","transformZ","rotateX","rotateY","rotateZ"];

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
