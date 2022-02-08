package modchart.modifiers;
import ui.*;
import modchart.*;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.FlxCamera;
import math.*;

class CamModifier extends Modifier {
  var prefix:String = "game";
  var cams:Array<Dynamic> = [];

  public function new(modMgr:ModManager,prefix:String,?cams:Array<Dynamic>){
    super(modMgr);
    if(cams==null){
      cams=[modMgr.state.camGame];
    }

    this.prefix=prefix;
    this.cams=cams;

    submods.set(prefix + "Pitch",new Modifier(modMgr));
    submods.set(prefix + "Yaw",new Modifier(modMgr));
    submods.set(prefix + "XOffset",new Modifier(modMgr));
    submods.set(prefix + "YOffset",new Modifier(modMgr));
    submods.set(prefix + "ScrollXOffset",new Modifier(modMgr));
    submods.set(prefix + "ScrollYOffset",new Modifier(modMgr));
  }

  override function update(elapsed){
    var pitch = getSubmodPercent(prefix + "Pitch",0)*100;
    var yaw = getSubmodPercent(prefix + "Yaw",0)*100;

    var xOffset = getSubmodPercent(prefix + "XOffset",0)*100;
    var yOffset = getSubmodPercent(prefix + "YOffset",0)*100;

    var xScrollOffset = (getSubmodPercent(prefix + "ScrollXOffset",0))*100;
    var yScrollOffset = (getSubmodPercent(prefix + "ScrollYOffset",0))*100;
    for(camera in cams){
      var cam:FNFCamera = camera;
      cam.pitch = pitch;
      cam.yaw = yaw;
      cam.offset.set(xOffset,yOffset);
      cam.scrollOffset.set(xScrollOffset,yScrollOffset);
    }
  }

}
