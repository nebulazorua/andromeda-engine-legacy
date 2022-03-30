package modchart.modifiers;
import ui.*;
import modchart.*;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import math.*;

class ScaleModifier extends Modifier {
  inline function lerp(a:Float,b:Float,c:Float){
    return a+(b-a)*c;
  }
  function getScale(sprite:Dynamic, scale:FlxPoint, data:Int, player:Int){
    var miniX = getPercent(player)+getSubmodPercent("miniX",player)+getSubmodPercent('mini${data}X',player);
    var miniY = getPercent(player)+getSubmodPercent("miniY",player)+getSubmodPercent('mini${data}Y',player);

    scale.x*=1-miniX;
    scale.y*=1-miniY;
    var angle = sprite.baseAngle;

    var stretch = getSubmodPercent("stretch",player) + getSubmodPercent('stretch${data}',player);
    var squish = getSubmodPercent("squish",player) + getSubmodPercent('squish${data}',player);

    var stretchX =lerp(1,0.5,stretch);
    var stretchY =lerp(1,2,stretch);

    var squishX =lerp(1,2,squish);
    var squishY =lerp(1,0.5,squish);

    scale.x*=(Math.sin(angle*Math.PI/180)*squishY)+(Math.cos(angle*Math.PI/180)*squishX);
    scale.x*=(Math.sin(angle*Math.PI/180)*stretchY)+(Math.cos(angle*Math.PI/180)*stretchX);

    scale.y*=(Math.cos(angle*Math.PI/180)*stretchY)+(Math.sin(angle*Math.PI/180)*stretchX);
    scale.y*=(Math.cos(angle*Math.PI/180)*squishY)+(Math.sin(angle*Math.PI/180)*squishX);

    return scale;
  }

  override function getReceptorScale(receptor:Receptor, scale:FlxPoint, data:Int, player:Int){
    return getScale(receptor,scale,data,player);
  }

  override function getNoteScale(note:Note, scale:FlxPoint, data:Int, player:Int){
    return getScale(note,scale,data,player);
  }


  override function getSubmods(){
    var subMods:Array<String> = ["squish","stretch","miniX","miniY"];

    var receptors = modMgr.receptors[0];
    var kNum = receptors.length;
    for(recep in receptors){
      subMods.push('mini${recep.direction}X');
      subMods.push('mini${recep.direction}Y');
      subMods.push('squish${recep.direction}');
      subMods.push('stretch${recep.direction}');
    }
    return subMods;
  }
}
