package;

class Option
{
  public var type:String = "Option";
  public var parent:OptionCategory;
  public var name ( default, default ):String = "Option";
  public var description ( default, default ):String = "";
  public var isButton ( default, default ):Bool = false;
  public function new(?name:String){
    this.type = "Option";
    if(name!=null){
      this.name = name;
    }
  }

  public function accept():Bool{
    trace("Unset");
    return false;
  };
  public function next():Bool{
    trace("Unset");
    return false;
  };
  public function back():Bool{
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
