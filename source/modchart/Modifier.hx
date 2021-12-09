package modchart;
import flixel.math.FlxPoint;
import ui.*;

class Modifier {
  public var modMgr:ModManager;
  public var percents:Array<Float>=[0,0];
  public var submods:Map<String,Modifier> = [];
  public function new(modMgr:ModManager){
    this.modMgr=modMgr;
    for(submod in getSubmods()){
      submods.set(submod,new Modifier(modMgr));
    }
  }

  public function getSubmods():Array<String>{
    return [];
  }

  public function getModPercent(modName:String, player:Int){
    return modMgr.getModPercent(modName,player);
  }

  public function getSubmodPercent(modName:String, player:Int){
    if(submods.exists(modName)){
      return submods.get(modName).getPercent(player);
    }else{
      return 0;
    }
  }

  public function setSubmodPercent(modName:String, endPercent:Float, player:Int){
    return submods.get(modName).setPercent(endPercent, player);
  }

  public function getPercent(player:Int):Float{
    if(player<0){
      var average:Float = 0;
      for(perc in percents){
        average = average + perc;
      }
      return average/percents.length;
    }
    return percents[player];
  }

  public function setPercent(percent:Float, player:Int=-1){
    if(player<0){
      for(idx in 0...percents.length){
        percents[idx]=percent/100;
      }
    }else{
      percents[player]=percent/100;
    }
  }

  public function updateNote(pos:FlxPoint, scale:FlxPoint, note:Note){}
  public function updateReceptor(pos:FlxPoint, scale:FlxPoint, receptor:Receptor){}

  public function update(elapsed:Float){};

  public function getReceptorScale(receptor:Receptor, scale:FlxPoint, data:Int, player:Int)return scale;
  public function getNoteScale(note:Note, scale:FlxPoint, data:Int, player:Int)return scale;

  public function getReceptorPos(receptor:Receptor, pos:FlxPoint, data:Int, player:Int)return pos;
  public function getNotePos(note:Note,pos:FlxPoint, data:Int, player:Int)return pos;

  public function getPos(pos:FlxPoint, data:Int, player:Int, object:FNFSprite)return pos;
}
