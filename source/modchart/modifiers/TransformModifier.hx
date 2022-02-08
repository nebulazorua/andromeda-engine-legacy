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

  // thanks schmoovin'
  function rotateV3(vec:Vector3,xA:Float,yA:Float,zA:Float):Vector3{
    var rZ = CoolUtil.rotate(vec.x, vec.y, zA);
		var oZ = new Vector3(rZ.x, rZ.y, vec.z);
		var rX = CoolUtil.rotate(oZ.z, oZ.y, xA);
		var oX = new Vector3(oZ.x, rX.y,rX.x);
		var rY = CoolUtil.rotate(oX.x, oX.z, yA);

		return new Vector3(rY.x, oX.y, rY.y);

  }

  /*override function getReceptorPos(receptor:Receptor, pos:Vector3, data:Int, player:Int){
    pos.x += getPercent(player)*100;
    pos.y += getSubmodPercent("transformY",player)*100;
    receptor.z += getSubmodPercent('transformZ',player)*100;

    pos.x += getSubmodPercent('transform${receptor.direction}X',player)*100;
    pos.y += getSubmodPercent('transform${receptor.direction}Y',player)*100;

    receptor.z += getSubmodPercent('transform${receptor.direction}Z',player)*100;

    return pos;
  }

  override function getNotePos(note:Note, pos:Vector3, data:Int, player:Int){
    note.z += getSubmodPercent('transformZ',player)*100;
    note.z += getSubmodPercent('transform${note.noteData}Z',player)*100;
    return pos;
  }*/

  override function getPath(visualDiff:Float, pos:Vector3, data:Int, player:Int, sprite: FNFSprite, timeDiff:Float){
    pos.x += getPercent(player)*100;
    pos.y += getSubmodPercent("transformY",player)*100;
    pos.z += getSubmodPercent('transformZ',player)*100;

    pos.x += getSubmodPercent('transform${data}X',player)*100;
    pos.y += getSubmodPercent('transform${data}Y',player)*100;
    pos.z += getSubmodPercent('transform${data}Z',player)*100;

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
