package modchart.modifiers;
import ui.*;
import modchart.*;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
using StringTools;
import math.*;

class ReverseModifier extends Modifier {

  public function getReversePercent(dir:Int, player:Int, ?scrolling=false){
    var suffix = '';
    if(scrolling==true)suffix='Scroll';
    var receptors = modMgr.receptors[player];
    var kNum = receptors.length;
    var percent:Float = 0;
    if(dir>=kNum/2)
      percent += getSubmodPercent("split" + suffix,player);

    if((dir%2)==1)
      percent += getSubmodPercent("alternate" + suffix,player);

    var first = kNum/4;
    var last = kNum-1-first;

    if(dir>=first && dir<=last){
      percent += getSubmodPercent("cross" + suffix,player);
    }

    if(suffix==''){
      percent += getPercent(player) + getSubmodPercent("reverse" + Std.string(dir),player);
    }else{
      percent += getSubmodPercent("reverse" + suffix,player);
    }

    if(getSubmodPercent("unboundedReverse",player)==0){
      percent %=2;
      if(percent>1)percent=2-percent;
    }




    if(modMgr.state.currentOptions.downScroll)
      percent = 1-percent;

    return percent;
  }

  public function getScrollReversePerc(dir:Int, player:Int){
    return getReversePercent(dir,player);
  }

  override function getPath(visualDiff:Float, pos:Vector3, data:Int, player:Int, timeDiff:Float){
    var perc = getReversePercent(data,player);
    var shift = CoolUtil.scale(perc,0,1,modMgr.state.upscrollOffset,modMgr.state.downscrollOffset);
    var mult = CoolUtil.scale(perc,0,1,1,-1);
    shift = CoolUtil.scale(getSubmodPercent("centered",player),0,1,shift,modMgr.state.center.y - 56);

    pos.y = shift + (visualDiff * mult);

    return pos;
  }

  override function updateNote(note:Note, player:Int, pos:Vector3, scale:FlxPoint){
    /*var perc = getScrollReversePerc(note.noteData,note.mustPress==true?0:1);
    if(perc>.5 && note.isSustainNote){
      note.flipY=true;
    }else{
      note.flipY=false;
    }*/
  }

  override function getSubmods(){
    var subMods:Array<String> = ["cross", "split", "alternate", "reverseScroll", "crossScroll", "splitScroll", "alternateScroll", "centered", "unboundedReverse"];

    var receptors = modMgr.receptors[0];
    var kNum = receptors.length;
    for(recep in receptors){
      subMods.push('reverse${recep.direction}');
    }
    return subMods;
  }
}
