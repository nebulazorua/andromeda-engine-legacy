package modchart;

import modchart.modifiers.*;
import modchart.Event.*;
import modchart.Event.FuncEvent;
import modchart.Event.ModEvent;
import modchart.Event.SetEvent;
import modchart.Event.EaseEvent;
import flixel.tweens.FlxEase;
import flixel.math.FlxPoint;
import flixel.FlxCamera;
import haxe.Exception;
import states.*;
import math.*;
import flixel.math.FlxMath;
import flixel.FlxG;
import ui.*;
// TODO: modifier priority system
class ModManager {
  private var definedMods:Map<String,Modifier>=[];

  private var schedule:Map<String,Array<ModEvent>>=[];
  private var funcs:Array<FuncEvent>=[];
  private var mods:Array<Modifier> = [];

  public var state:PlayState;
  public var receptors:Array<Array<Receptor>>=[[],[]];
  public function new(state:PlayState){
    this.state = state;
  }

  public function setReceptors(){
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

  public function registerModifiers(){
    // NOTE: the order matters!
    // it goes from first defined to last defined
    defineBlankMod("waveTimeFactor");
    set("waveTimeFactor", 100, 0);
    set("waveTimeFactor", 100, 1);
    defineMod("reverse",new ReverseModifier(this)); // also cross, split, alternate, centered
    defineMod("stealth",new AlphaModifier(this));
    defineMod("opponentSwap",new OpponentModifier(this));
    defineMod("zigzag",new ZigZagModifier(this));
    defineMod("sawtooth",new SawtoothModifier(this));
    defineMod("bounce",new BounceModifier(this));
    defineMod("square",new SquareModifier(this));
    defineMod("scrollAngle",new AngleModifier(this));
    defineMod("mini",new ScaleModifier(this)); // also squish and stretch
    defineMod("flip",new FlipModifier(this));
    defineMod("invert",new InvertModifier(this));
    defineMod("tornado",new TornadoModifier(this));
    defineMod("drunk",new DrunkModifier(this));
    defineMod("confusion",new ConfusionModifier(this));
    defineMod("beat",new BeatModifier(this));
    defineMod("rotateX",new RotateModifier(this));
    defineMod("centerrotateX",new RotateModifier(this,'center',new Vector3(FlxG.width/2 - Note.swagWidth / 2,FlxG.height/2 - Note.swagWidth / 2)));
    defineMod("localrotateX",new LocalRotateModifier(this));
    defineMod("boost",new AccelModifier(this));
    defineMod("transformX",new TransformModifier(this));
    var infPath:Array<Array<Vector3>>=[[],[],[],[] ];

    var r = 0;
    while(r<360){
      for(data in 0...infPath.length){
        var rad = r*Math.PI / 180;
        infPath[data].push(new Vector3(
          FlxG.width/2 + (FlxMath.fastSin(rad))*600,
          FlxG.height/2 + (FlxMath.fastSin(rad)*FlxMath.fastCos(rad))*600,
          0
        ));
      }
      r+=15;
    }
    defineMod("infinite",new PathModifier(this,infPath,1850));
    // an example of PathModifier using a figure 8 pattern
    // when creating a PathModifier, the 2nd argument is an array of arrays of Vector3
    // Array<Array<Vector3>> where the 1st (path[0]) element is the left's path and the 4th (path[3]) element is the right's path, and everything inbetween
    // the 3rd argument is the ms it takes to go from the start of the path to the end. Higher numbers = slower speeds.

    defineMod("receptorScroll",new ReceptorScrollModifier(this));


    var gameCams:Array<FlxCamera> = [state.camGame];
    var hudCams:Array<FlxCamera> = [state.camHUD];
    if(state.currentOptions.ratingInHUD){
      hudCams.push(state.camHUD);
    }else{
      gameCams.push(state.camHUD);
    }
    defineMod("gameCam",new CamModifier(this,"gameCam",gameCams ));
    defineMod("hudCam",new CamModifier(this,"hudCam",hudCams ));
    defineMod("noteCam",new CamModifier(this,"noteCam",[state.camNotes,state.camSus,state.camReceptor] ));

    defineMod("perspective",new PerspectiveModifier(this));
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
    if(schedule.get(modName)==null){
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
    defineMod(modName, new Modifier(this), false);
  }

  public function get(modName:String):Dynamic{
    return definedMods[modName];
  }

  public function getModPercent(modName:String, player:Int):Float{
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

  public function getMods():Array<Modifier>{
    var modArr:Array<Modifier>=[];
    for(m in mods){
      modArr.push(m);
    }
    return modArr;
  }

  public function update(elapsed:Float){
    run();
    for(mod in mods){
      mod.update(elapsed);
    }
  }

  public function getPath(diff:Float, vDiff:Float, column:Int, player:Int):Vector3{
    var pos = new Vector3(state.getXPosition(diff, column, player), vDiff, 0);
    for(mod in mods){
      pos = mod.getPath(vDiff, pos, column, player, diff);
    }

    return pos;
  }


  public function getNotePos(note:Note):Vector3{
    var diff =  Conductor.songPosition - note.strumTime;
    var vDiff = (note.initialPos-Conductor.currentTrackPos);
    var pos = getPath(diff, vDiff, note.noteData, note.mustPress==true?0:1); //FlxPoint.get(state.getXPosition(diff, note.noteData, note.mustPress==true?0:1),vDiff);

    pos.x += note.manualXOffset;
    pos.y -= note.manualYOffset;

    return pos;
  }

  public function getNoteScale(note:Note):FlxPoint{
    var def = note.scaleDefault;
    var scale = FlxPoint.get(def.x,def.y);
    for(mod in mods){
      scale = mod.getNoteScale(note, scale, note.noteData, note.mustPress==true?0:1);
    }
    return scale;
  }

  public function updateNote(note:Note, player:Int, scale:FlxPoint, pos:Vector3){
    for(mod in mods){
      mod.updateNote(note, player, pos, scale);
    }
  }


  public function getReceptorPos(rec:Receptor, player:Int=0):Vector3{
    var pos = getPath(0, 0, rec.direction, player);

    return pos;
  }

  public function getReceptorScale(rec:Receptor, player:Int=0):FlxPoint{
    var def = rec.scaleDefault;
    var scale = FlxPoint.get(def.x,def.y);
    for(mod in mods){
      scale = mod.getReceptorScale(rec, scale, rec.direction, player);
    }
    return scale;
  }

  public function updateReceptor(rec:Receptor, player:Int, scale:FlxPoint, pos:Vector3){
    for(mod in mods){
      mod.updateReceptor(rec, player, pos, scale);
    }
  }

  public function queueEase(step:Float, endStep:Float, modName:String, percent:Float, style:String='linear', player:Int=-1, ?startVal:Float){
    if(schedule[modName]==null)schedule[modName]=[];
    if(player==-1){
      queueEase(step, endStep, modName, percent, style, 0);
      queueEase(step, endStep, modName, percent, style, 1);
    }else{
      var easeFunc = FlxEase.linear;
      try{
        var newEase = Reflect.getProperty(FlxEase, style);
        if(newEase!=null)easeFunc=newEase;
      }


      schedule[modName].push(
        new EaseEvent(
          step,
          endStep,
          modName,
          percent,
          easeFunc,
          player,
          this,
          startVal
        )
      );

    }
  }

  public function queueEaseL(step:Float, length:Float, modName:String, percent:Float, style:String, player:Int=-1, ?startVal:Float){
    if(schedule[modName]==null){
      trace('$modName is not a valid mod!');
      return;
    }
    if(player==-1){
      queueEaseL(step, length, modName, percent, style, 0);
      queueEaseL(step, length, modName, percent, style, 1);
    }else{
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
          this,
          startVal
        )
      );
    }
  }

  public function queueSet(step:Float, modName:String, percent:Float, player:Int=-1){
    if(player==-1){
      queueSet(step, modName, percent, 0);
      queueSet(step, modName, percent, 1);
    }else{
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
