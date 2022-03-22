package modchart;

import flixel.tweens.FlxEase.EaseFunction;
import ui.*;

class Event {
  public var modMgr:ModManager;
  public var step:Float = 0;
  public var finished:Bool=false;
  public function new(step:Float,modMgr:ModManager){
    this.modMgr=modMgr;
    this.step=step;
  }

  public function run(curStep:Float){}
}

class FuncEvent extends Event {
  public var callback:Void->Void;

  public function new(step:Float,callback:Void->Void,modMgr:ModManager){
    super(step,modMgr);
    this.callback=callback;
  }

  override function run(curStep:Float){
    if(curStep>=step){
      callback();
      finished=true;
    }
  }
}

class ModEvent extends Event {
  public var modName:String = '';
  public var endPercent:Float = 0;
  public var player:Int = -1;

  private var mod:Modifier;

  public function getPreviousPercent(){
    return modMgr.getPreviousWithEvent(this).endPercent;
  }

  public function getCurrentPercent(){
    return modMgr.getLatestWithEvent(this).endPercent;
  }

  public function new(step:Float,modName:String,target:Float,player:Int=-1,modMgr:ModManager){
    super(step,modMgr);
    this.modName=modName;
    this.player=player;
    endPercent=target;

    this.mod = modMgr.get(modName);
  }
}

class EaseEvent extends ModEvent {
  public var easeFunction:EaseFunction;
  public var endStep:Float = 0;
  public var length:Float = 0;
  public var startPercent:Null<Float> = 0;
  public function new(step:Float,endStep:Float,modName:String,target:Float,ease:EaseFunction,player:Int=-1,modMgr:ModManager, ?startVal:Float){
    super(step,modName,target,player,modMgr);
    this.endStep=endStep;
    this.easeFunction=ease;
    this.length = endStep-step;

    this.startPercent = startVal;//getCurrentPercent();
  }

  function ease(t:Float,b:Float,c:Float,d:Float){ // elapsed, begin, change (ending-beginning), duration
    var time = t / d;
    return c * easeFunction(time) + b;
  }

  override function run(curStep:Float){
    if(curStep>=step && curStep<=endStep){
      if(this.startPercent==null)
        this.startPercent = mod.getPercent(player) * 100;
      
      var passed = curStep-step;
      var change = endPercent-startPercent;
      mod.setPercent(
        ease(passed,startPercent,change,length),
        player
      );
    }else if(curStep>endStep){
      finished=true;
      mod.setPercent(endPercent,player);
    }
  }

}

class SetEvent extends ModEvent {

  override function run(curStep:Float){
    if(curStep>=step){
      mod.setPercent(endPercent,player);
      finished=true;
    }
  }
}
