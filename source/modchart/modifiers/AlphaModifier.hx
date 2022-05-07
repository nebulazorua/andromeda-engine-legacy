package modchart.modifiers;
import ui.*;
import modchart.*;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import math.*;
import flixel.FlxG;
class AlphaModifier extends Modifier {
  public static var fadeDistY = 120;

  public function getHiddenSudden(player:Int=-1){
    return getSubmodPercent("hidden",player) * getSubmodPercent("sudden",player);
  }

  public function getHiddenEnd(player:Int=-1){
    return modMgr.state.center.y + fadeDistY * CoolUtil.scale(getHiddenSudden(player),0,1,-1,-1.25) + modMgr.state.center.y * getSubmodPercent("hiddenOffset",player);
  }

  public function getHiddenStart(player:Int=-1){
    return modMgr.state.center.y + fadeDistY * CoolUtil.scale(getHiddenSudden(player),0,1,0,-0.25) + modMgr.state.center.y * getSubmodPercent("hiddenOffset",player);
  }

  public function getSuddenEnd(player:Int=-1){
    return modMgr.state.center.y + fadeDistY * CoolUtil.scale(getHiddenSudden(player),0,1,1,1.25) + modMgr.state.center.y * getSubmodPercent("suddenOffset",player);
  }

  public function getSuddenStart(player:Int=-1){
    return modMgr.state.center.y + fadeDistY * CoolUtil.scale(getHiddenSudden(player),0,1,0,0.25) + modMgr.state.center.y * getSubmodPercent("suddenOffset",player);
  }

  function getVisibility(yPos:Float,player:Int,note:Note):Float{
    var distFromCenter = yPos;
    var alpha:Float = 0;

    if(yPos<0 && getSubmodPercent("stealthPastReceptors", player)==0)
      return 1.0;


    var time = Conductor.songPosition/1000;

    if(getSubmodPercent("hidden",player)!=0){
      var hiddenAdjust = CoolUtil.clamp(CoolUtil.scale(yPos,getHiddenStart(player),getHiddenEnd(player),0,-1),-1,0);
      alpha += getSubmodPercent("hidden",player)*hiddenAdjust;
    }

    if(getSubmodPercent("sudden",player)!=0){
      var suddenAdjust = CoolUtil.clamp(CoolUtil.scale(yPos,getSuddenStart(player),getSuddenEnd(player),0,-1),-1,0);
      alpha += getSubmodPercent("sudden",player)*suddenAdjust;
    }

    if(getPercent(player)!=0)
      alpha -= getPercent(player);


    if(getSubmodPercent("blink",player)!=0){
      var f = CoolUtil.quantize(FlxMath.fastSin(time*10),0.3333);
      alpha += CoolUtil.scale(f,0,1,-1,0);
    }

    if(getSubmodPercent("randomVanish",player)!=0){
      var realFadeDist:Float = 240;
      alpha += CoolUtil.scale(Math.abs(distFromCenter),realFadeDist,2*realFadeDist,-1,0)*getSubmodPercent("randomVanish",player);
    }

    return CoolUtil.clamp(alpha+1,0,1);
  }

  function getGlow(visible:Float){
    var glow = CoolUtil.scale(visible, 1, 0.5, 0, 1.3);
    return CoolUtil.clamp(glow,0,1);
  }

  function getAlpha(visible:Float){
    var alpha = CoolUtil.scale(visible, 0.5, 0, 1, 0);
    return CoolUtil.clamp(alpha,0,1);
  }

  override function updateNote(note:Note, player:Int, pos:Vector3, scale:FlxPoint){
    var player = note.mustPress==true?0:1;
    var yPos:Float = (note.initialPos-Conductor.currentTrackPos)+modMgr.state.upscrollOffset;


    var alphaMod = 1 - getSubmodPercent("alpha",player) * (1-getSubmodPercent("noteAlpha",player));
    var alpha = getVisibility(yPos,player,note);

    if(getSubmodPercent("dontUseStealthGlow",player)==0){
      note.desiredAlpha = getAlpha(alpha);
      note.effect.setFlash(getGlow(alpha));
    }else{
      note.desiredAlpha = alpha;
    }
    note.desiredAlpha*=alphaMod;
  }

  override function updateReceptor(receptor:Receptor, player:Int, pos:Vector3, scale:FlxPoint){
    var alpha = 1 - getSubmodPercent("alpha",player);
    if(getSubmodPercent("dark",player)!=0 || getSubmodPercent('dark${receptor.direction}',player)!=0){
      alpha = alpha*(1-getSubmodPercent("dark",player))*(1-getSubmodPercent('dark${receptor.direction}',player));
    }
    receptor.alpha = alpha;

  }

  override function getSubmods(){
    var subMods:Array<String> = ["noteAlpha", "alpha", "hidden","hiddenOffset","sudden","suddenOffset","blink","randomVanish","dark","useStealthGlow","stealthPastReceptors"];
    return subMods;
  }
}
