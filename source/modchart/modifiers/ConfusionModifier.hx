package modchart.modifiers;
import ui.*;
import modchart.*;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;

class ConfusionModifier extends Modifier {
  override function updateNote(pos:FlxPoint, scale:FlxPoint, note:Note){
    var player = note.mustPress==true?0:1;
    if(!note.isSustainNote){
      note.modAngle = (getPercent(player) + getSubmodPercent('confusion${note.noteData}',player) + getSubmodPercent('note${note.noteData}Angle',player))*100;
    }

  }

  override function updateReceptor(pos:FlxPoint, scale:FlxPoint, receptor:Receptor){
    receptor.desiredAngle = (getPercent(receptor.playerNum) + getSubmodPercent('confusion${receptor.direction}',receptor.playerNum) + getSubmodPercent('receptor${receptor.direction}Angle',receptor.playerNum))*100;
  }

  override function getSubmods(){
    var subMods:Array<String> = ["noteAngle","receptorAngle"];

    var receptors = modMgr.receptors[0];
    var kNum = receptors.length;
    for(recep in receptors){
      subMods.push('note${recep.direction}Angle');
      subMods.push('receptor${recep.direction}Angle');
      subMods.push('confusion${recep.direction}');
    }

    return subMods;
  }
}
