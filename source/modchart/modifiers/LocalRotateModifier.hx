package modchart.modifiers;
import ui.*;
import modchart.*;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.FlxG;
import math.Vector3;
import math.*;

class LocalRotateModifier extends Modifier { // this'll be rotateX in ModManager
  inline function lerp(a:Float,b:Float,c:Float){
    return a+(b-a)*c;
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
    var x:Float = (FlxG.width/2) - Note.swagWidth - 54 + Note.swagWidth*1.5;
		if(!modMgr.state.currentOptions.middleScroll){
			switch(player){
				case 0:
					x += FlxG.width/2 - Note.swagWidth*2 - 100;
				case 1:
					x -= FlxG.width/2 - Note.swagWidth*2 - 100;
			}
		}
		x -= 56;


    var origin:Vector3 = new Vector3(x, FlxG.height / 2 - Note.swagWidth / 2);

    var diff = pos.subtract(origin);
    var scale = FlxG.height;
    diff.z *= scale;
    var out = rotateV3(diff, getPercent(player)*100, getSubmodPercent('localrotateY',player)*100, getSubmodPercent('localrotateZ',player)*100);
    out.z /= scale;
    return origin.add(out);
  }

  override function getSubmods(){
    return ['localrotateY','localrotateZ'];
  }
}
