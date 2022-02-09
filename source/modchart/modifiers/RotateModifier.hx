package modchart.modifiers;
import ui.*;
import modchart.*;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.FlxG;
import math.Vector3;
import math.*;

class RotateModifier extends Modifier { // this'll be rotateX in ModManager
  inline function lerp(a:Float,b:Float,c:Float){
    return a+(b-a)*c;
  }
  var daOrigin:Vector3;
  var prefix:String;
  public function new(modMgr:ModManager,?prefix:String='',?origin:Vector3){
    super(modMgr);

    this.prefix=prefix;
    this.daOrigin=origin;

    submods.set('${prefix}rotateY',new Modifier(modMgr));
    submods.set('${prefix}rotateZ',new Modifier(modMgr));

  }

  // thanks schmoovin'
  function rotateV3(vec:Vector3,xA:Float,yA:Float,zA:Float):Vector3{
    var rotateZ = CoolUtil.rotate(vec.x, vec.y, zA);
		var offZ = new Vector3(rotateZ.x, rotateZ.y, vec.z);

		var rotateX = CoolUtil.rotate(offZ.z, offZ.y, xA);
		var offX = new Vector3(offZ.x, rotateX.y, rotateX.x);

		var rotateY = CoolUtil.rotate(offX.x, offX.z, yA);
		var offY = new Vector3(rotateY.x, offX.y, rotateY.y);

		return offY;

  }

  override function getPath(visualDiff:Float, pos:Vector3, data:Int, player:Int, timeDiff:Float){
    var origin:Vector3 = new Vector3(modMgr.state.getXPosition(timeDiff, data, player), FlxG.height / 2 - Note.swagWidth / 2);
    if(daOrigin!=null)origin=daOrigin;

    var diff = pos.subtract(origin);
    var scale = FlxG.height;
    diff.z *= scale;
    var out = rotateV3(diff, getPercent(player)*100, getSubmodPercent('${prefix}rotateY',player)*100, getSubmodPercent('${prefix}rotateZ',player)*100);
    out.z /= scale;
    return origin.add(out);
  }

  override function getSubmods(){
    return [];
  }
}
