package;
import flixel.input.keyboard.FlxKey;

class Option
{
  public var type:String = "Option";
  public var parent:OptionCategory;
  public var name:String = "Option";
  public var description:String = "";
  public var allowMultiKeyInput=false;

  public function new(?name:String){
    this.type = "Option";
    if(name!=null){
      this.name = name;
    }
  }

  public function keyPressed(key:FlxKey):Bool{
    trace("Unset");
    return false;
  }
  public function keyReleased(key:FlxKey):Bool{
    trace("Unset");
    return false;
  }

  public function accept():Bool{
    trace("Unset");
    return false;
  };
  public function right():Bool{
    trace("Unset");
    return false;
  };
  public function left():Bool{
    trace("Unset");
    return false;
  };
  public function selected():Bool{
    trace("Unset");
    return false;
  };
  public function deselected():Bool{
    trace("Unset");
    return false;
  };
}
