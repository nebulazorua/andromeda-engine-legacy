package modchart.modifiers;
import ui.*;
import modchart.*;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;

class ConfusionModifier extends Modifier {
  override function updateNote(pos:FlxPoint, scale:FlxPoint, note:Note){
    var player = note.mustPress==true?0:1;
    if(!note.isSustainNote){
      note.modAngle = getPercent(player)*100 + getSubmodPercent('note${note.noteData}Angle',player);
    }

  }

  override function updateReceptor(pos:FlxPoint, scale:FlxPoint, receptor:Receptor){
    receptor.desiredAngle = getPercent(receptor.playerNum)*100 + getSubmodPercent('receptor${receptor.direction}Angle',receptor.playerNum);
  }

  override function getSubmods(){
    var subMods:Array<String> = ["noteAngle","receptorAngle"];

    var receptors = modMgr.receptors[0];
    var kNum = receptors.length;
    for(recep in receptors){
      subMods.push('note${recep.direction}Angle');
      subMods.push('receptor${recep.direction}Angle');
    }

    return subMods;
  }
}
