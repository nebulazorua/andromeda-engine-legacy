package;
import flixel.input.keyboard.FlxKey;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
class Option extends FlxTypedGroup<FlxSprite>
{
  public var type:String = "Option";
  public var parent:OptionCategory;
  public var name:String = "Option";
  public var description:String = "";
  public var allowMultiKeyInput=false;
  public var text:Alphabet;
  public var isSelected:Bool=false;

  public function new(?name:String){
    super();
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

  public function createOptionText(curSelected:Int,optionText:FlxTypedGroup<Option>):Dynamic{
    remove(text);
    text = new Alphabet(0, (70 * curSelected) + 30, name, true, false);
    text.movementType = "list";
    text.isMenuItem = true;
    text.offsetX = 70;
    text.gotoTargetPosition();
    add(text);
    return text;
  }

  override function update(elapsed:Float){
    super.update(elapsed);
  };
}
