package modchart.modifiers;
import ui.*;
import modchart.*;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
using StringTools;

class ReverseModifier extends Modifier {

  public function getReversePercent(dir:Int, player:Int, ?scrolling=false){
    var suffix = '';
    if(scrolling==true)suffix='Scroll';
    var receptors = modMgr.receptors[player];
    var kNum = receptors.length;
    var percent:Float = 0;
    if(suffix==''){
      percent += getPercent(player) + getSubmodPercent("reverse" + Std.string(dir),player);
    }else{
      percent += getSubmodPercent("reverse" + suffix,player);
    }

    if(dir>=kNum/2)
      percent += getSubmodPercent("split" + suffix,player);

    if((dir%2)==1)
      percent += getSubmodPercent("alternate" + suffix,player);

    var first = kNum/4;
    var last = kNum-1-first;

    if(dir>=first && dir<=last){
      percent += getSubmodPercent("cross" + suffix,player);
    }

    if(percent>2)
      percent%=2;

    if(percent>1)
      percent=CoolUtil.scale(percent,1,2,1,0);

    if(modMgr.state.currentOptions.downScroll)
      percent = 1-percent;

    return percent;
  }

  public function getScrollReversePerc(dir:Int, player:Int){
    return getReversePercent(dir,player);
  }

  override function getReceptorPos(receptor:Receptor, pos:FlxPoint, data:Int, player:Int){
    var perc = getReversePercent(data,player,false);

    var shift = CoolUtil.scale(perc,0,1,modMgr.state.upscrollOffset,modMgr.state.downscrollOffset);
    shift = CoolUtil.scale(getSubmodPercent("centered",player),0,1,shift,receptor.offset.y);

    pos.y = pos.y+shift;
    return pos;
  }

  override function getNotePos(note:Note, pos:FlxPoint, data:Int, player:Int){
    var perc = getScrollReversePerc(data,player);
    var state = modMgr.state;

    var downscrollY = state.getYPosition(note, -1);
    var upscrollY = state.getYPosition(note, 1);

    pos.y = CoolUtil.scale(perc,0,1,upscrollY,downscrollY);

    return pos;
  }

  override function updateNote(pos:FlxPoint, scale:FlxPoint, note:Note){
    var perc = getScrollReversePerc(note.noteData,note.mustPress==true?0:1);
    if(perc>.5 && note.isSustainNote){
      note.flipY=true;
    }else{
      note.flipY=false;
    }
  }

  override function getSubmods(){
    var subMods:Array<String> = ["cross","split","alternate","reverseScroll","crossScroll","splitScroll","alternateScroll", "centered"];

    var receptors = modMgr.receptors[0];
    var kNum = receptors.length;
    for(recep in receptors){
      subMods.push('reverse${recep.direction}');
    }
    return subMods;
  }
}
