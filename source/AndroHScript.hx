package;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;
import sys.FileSystem;
import sys.io.File;
import flixel.FlxG;
import flixel.util.FlxAxes;
import modchart.*
import modchart.modifiers.*
import states.*;

class AndroHScript {
  var parser:Parser;
  var interp:Interp;
  var expr:Expr;

  public function new(path:String,?origin:String){
    if(origin==null)origin=path;

    parser = new Parser();
    interp = new Interp();

    parser.allowTypes=true;

    interp.variables.set("Sys",Sys);
    interp.variables.set("Std",Std);
    interp.variables.set("Conductor",Conductor);
    interp.variables.set("Character",Character);
    interp.variables.set("FlxMath",FlxMath);
    interp.variables.set("StringTools",StringTools);
    interp.variables.set("PlayState",PlayState);
    interp.variables.set("currentState",FlxG.state);
    interp.variables.set("FlxAxes",FlxAxes);
    interp.variables.set("X",FlxAxes.X);
    interp.variables.set("Y",FlxAxes.Y);
    interp.variables.set("XY",FlxAxes.XY);
    interp.variables.set("CoolUtil",CoolUtil);
    interp.variables.set("cameras",FlxG.cameras);
    interp.variables.set("Paths",Paths);
    interp.variables.set("Controls",Controls);
    interp.variables.set("Note",Note);
    interp.variables.set("Controls",Controls);
    if(FlxG.state==PlayState.currentPState){
      var state = PlayState.currentPState;
      interp.variables.set("options",state.currentOptions);
    }else{
      interp.variables.set("options",EngineData.options.clone());
    }
  }

  public function loadScript(path:String){
    if(FileSystem.exists(path)){
      try {
        expr = parser.parseString(File.getContent(path),origin);
      }catch(e){
        FlxG.log.error(e.toString())
      }
    }else{
      trace('$path is non-existant wtf');
      return;
    }

    if(expr){

    }
  }

}
