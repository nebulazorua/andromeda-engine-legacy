package modchart;

import modchart.modifiers.*;
import modchart.Event.*;
import modchart.Event.FuncEvent;
import modchart.Event.ModEvent;
import modchart.Event.SetEvent;
import modchart.Event.EaseEvent;
import flixel.tweens.FlxEase;
import flixel.math.FlxPoint;

// TODO: modifier priority system
class ModManager {
  private var definedMods:Map<String,Modifier>=[]; // ModList class for defining mods? idk
  private var schedule:Map<String,Array<ModEvent>>=[];
  private var funcs:Array<FuncEvent>=[];
  private var mods:Array<Modifier> = [];

  public var state:PlayState;
  public var receptors:Array<Array<Receptor>>=[[],[]];
  public function new(state:PlayState){
    this.state = state;
    var playerReceptors = state.playerStrums;
    var dadReceptors = state.dadStrums;

    for(data in 0...playerReceptors.length){
      var rec = playerReceptors.members[data];
      receptors[0][rec.direction] = rec;
    }
    for(data in 0...dadReceptors.length){
      var rec = dadReceptors.members[data];
      receptors[1][rec.direction] = rec;
    }
  }

  public function registerDefaultModifiers(){
    defineMod("reverse",new ReverseModifier(this)); // also cross, split, alternate, centered
    defineMod("mini",new ScaleModifier(this)); // also squish and stretch
    defineMod("flip",new FlipModifier(this));
    defineMod("invert",new InvertModifier(this));
    defineMod("transform",new TransformModifier(this));
  }

  public function getList(modName:String,player:Int):Array<ModEvent>{
    if(definedMods[modName]!=null){
      // TODO: seperate schedule by player
      var list:Array<ModEvent> = [];
      for(e in schedule[modName]){
        if(e.player==player){
          list.push(e);
        }
      }
      list.sort((a,b)->Std.int(a.step-b.step));

      return list;
    }
    return [];
  }

  public function getLatest(modName:String,player:Int){
    if(definedMods[modName]!=null){
      var list:Array<ModEvent> = getList(modName,player);
      var idx = list.length-1;
      if(idx>=0)
        return list[idx];
    }
    return new ModEvent(0,modName,0,0,this);
  }

  public function getPreviousWithEvent(event:ModEvent){
    if(definedMods[event.modName]!=null){
      var list:Array<ModEvent> = getList(event.modName,event.player);
      var idx = list.indexOf(event);
      if(idx!=-1 && idx>0){
        return list[idx-1];
      }
    }
    return new ModEvent(0,event.modName,0,0,this);
  }

  public function getLatestWithEvent(event:ModEvent){
    return getLatest(event.modName,event.player);
  }

  public function defineMod(modName:String, modifier:Modifier, defineSubmods=true){
    if(!mods.contains(modifier)){
      mods.push(modifier);
      schedule.set(modName,[]);
      definedMods.set(modName,modifier);

      if(defineSubmods){
        for(name in modifier.submods.keys()){
          var mod = modifier.submods.get(name);
          defineMod(name,mod,false);
        }
      }
    }
  }

  public function removeMod(modName:String){
    if(definedMods.exists(modName)){
      definedMods.remove(modName);
    }
  }

  public function defineBlankMod(modName:String){
    defineMod(modName, new Modifier(this));
  }

  public function get(modName:String):Dynamic{
    return definedMods[modName];
  }

  public function getModPercent(modName:String, player:Int){
    return get(modName).getPercent(player);
  }

  public function exists(modName:String):Bool{
    return definedMods.exists(modName);
  }

  public function set(modName:String, percent:Float, player:Int){
    if(exists(modName)){
      definedMods[modName].setPercent(percent,player);
    }
  }

  private function run(){
    for(modName in schedule.keys()){
      var events = schedule.get(modName);
      for(event in events){
        if(!event.finished && state.curDecStep>=event.step)
          event.run(state.curDecStep);
      }
    }
    for(event in funcs){
      if(!event.finished && state.curDecStep>=event.step)
        event.run(state.curDecStep);
    }
  }

  public function update(elapsed:Float){
    run();
    for(mod in mods){
      mod.update(elapsed);
    }

    updateReceptorOffsets();
    updateReceptorScales();
  }

  public function updateReceptorOffsets(){
    for(player in 0...receptors.length){
      var columns = receptors[player];
      for(dir in 0...columns.length){
        var receptor = columns[dir];
        var pos = receptor.point;
        pos.set(0,0);
        for(mod in mods){
          pos = mod.getReceptorPos(receptor, pos, receptor.direction, player);
        }
        receptor.point.set(pos.x,pos.y);
      }
    }
  }

  public function getNotePos(note:Note){
    var pos = FlxPoint.get(state.getXPosition(note),state.getYPosition(note));
    for(mod in mods){
      pos = mod.getNotePos(note, pos, note.noteData, note.mustPress==true?0:1);
    }

    return pos;

  }

  public function getNoteScale(note:Note){
    var def = note.scaleDefault;
    var scale = FlxPoint.get(def.x,def.y);
    for(mod in mods){
      scale = mod.getNoteScale(note, scale, note.noteData, note.mustPress==true?0:1);
    }
    return scale;
  }

  public function updateNote(note:Note, scale:FlxPoint, pos:FlxPoint){
    for(mod in mods){
      mod.updateNote(pos, scale, note);
    }
  }

  public function updateReceptorScales(){
    for(player in 0...receptors.length){
      var columns = receptors[player];
      for(dir in 0...columns.length){
        var receptor = columns[dir];
        var def = receptor.scaleDefault;
        var scale = FlxPoint.get(def.x,def.y);
        for(mod in mods){
          scale = mod.getReceptorScale(receptor, scale, receptor.direction, player);
        }
        receptor.scale.set(scale.x,scale.y);
        scale.put();
      }
    }
  }

  public function queueEase(step:Float, endStep:Float, modName:String, percent:Float, style:String, player:Int=-1){
    var easeFunc = Reflect.getProperty(FlxEase, style);
    if(easeFunc==null)easeFunc=FlxEase.linear;

    schedule[modName].push(
      new EaseEvent(
        step,
        endStep,
        modName,
        percent,
        easeFunc,
        player,
        this
      )
    );
  }

  public function queueEaseL(step:Float, length:Float, modName:String, percent:Float, style:String, player:Int=-1){
    var easeFunc = Reflect.getProperty(FlxEase, style);
    if(easeFunc==null)easeFunc=FlxEase.linear;
    var stepSex = Conductor.stepToSeconds(step);

    schedule[modName].push(
      new EaseEvent(
        step,
        Conductor.getStep(stepSex+(length*1000)),
        modName,
        percent,
        easeFunc,
        player,
        this
      )
    );
  }

  public function queueSet(step:Float, modName:String, percent:Float, player:Int=-1){
    schedule[modName].push(
      new SetEvent(
        step,
        modName,
        percent,
        player,
        this
      )
    );
  }

  public function queueFunc(step:Float, callback:Void->Void){
    funcs.push(
      new FuncEvent(
        step,
        callback,
        this
      )
    );
  }

}
