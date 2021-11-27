package modchart.modifiers;
import ui.*;
import modchart.*;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;

class AngleModifier extends Modifier {
  override function getNotePos(note:Note, pos:FlxPoint, data:Int, player:Int){
    if(getPercent(player)==0)return pos;
    
    pos.copyFrom(CoolUtil.rotate(pos.x,pos.y,getPercent(player)));

    return pos;
  }
}
