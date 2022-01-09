package modchart.modifiers;
import ui.*;
import modchart.*;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;

class BeatModifier extends Modifier {
  override function getNotePos(note:Note, pos:FlxPoint, data:Int, player:Int){
    if(getPercent(player)==0)return pos;
    var accelTime:Float = 0.2;
    var totalTime:Float = 0.5;

    var beat = modMgr.state.curDecBeat + accelTime;
    var evenBeat = beat%2!=0;

    if(beat<0)return pos;

    beat -= Math.floor(beat);
    beat += 1;
    beat -= Math.floor(beat);
    if(beat>=totalTime)return pos;
    var amount:Float = 0;
    if(beat<accelTime){
      amount = CoolUtil.scale(beat, 0, accelTime, 0, 1);
      amount *= amount;
    }else{
      amount = CoolUtil.scale(beat, accelTime, totalTime, 1, 0);
      amount = 1 - (1-amount) * (1-amount);
    }
    if(evenBeat)amount*=-1;

    var shift = 20*amount*FlxMath.fastSin(pos.y / 15 + Math.PI/2);
    pos.x += getPercent(player)*shift;
    return pos;
  }
}
