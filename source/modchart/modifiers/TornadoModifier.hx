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
  }
}
