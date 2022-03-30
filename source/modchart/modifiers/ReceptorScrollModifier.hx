package modchart.modifiers;

import ui.*;
import modchart.*;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.FlxG;
import math.*;

class ReceptorScrollModifier extends Modifier {
  inline function lerp(a:Float,b:Float,c:Float){
    return a+(b-a)*c;
  }
  //var moveSpeed:Float = 800;
  var moveSpeed:Float = Conductor.crochet * 1.5; // gotta keep da sustain segments together so it doesnt look so shit
  override function getPath(visualDiff:Float, pos:Vector3, data:Int, player:Int, timeDiff:Float){
    if(getPercent(player)==0)return pos;
    // in the galaxy code ^^
    // using as reference because im bad


    var currSongPos = Conductor.currentTrackPos;
    var vDiff = -(-visualDiff - currSongPos) / moveSpeed;
    var reversed = Math.floor(vDiff)%2==0;

    var startY = pos.y;
    var revPerc = reversed?1-vDiff%1:vDiff%1;
    // haha perc 30
    var endY = modMgr.state.upscrollOffset + ((modMgr.state.downscrollOffset - Note.swagWidth/2) * revPerc);

    pos.y = lerp(startY, endY, getPercent(player));

    return pos;
  }

  override function updateNote(note:Note, player:Int, pos:Vector3, scale:FlxPoint){
    if(getPercent(player)==0)return;
    var currSongPos = Conductor.currentTrackPos;
    var visualDiff = (note.initialPos-Conductor.currentTrackPos);

    var songPos = currSongPos / moveSpeed;
    var notePos = -(-visualDiff - currSongPos) / moveSpeed;

    if(Math.floor(songPos)!=Math.floor(notePos)){
      note.desiredAlpha *= .5;
      note.zIndex++;
    }
    if(note.wasGoodHit && note.holdingTime>=note.sustainLength)note.garbage=true;
  }
}
