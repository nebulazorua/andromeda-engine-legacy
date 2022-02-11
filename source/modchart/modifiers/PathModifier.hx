package modchart.modifiers;
import ui.*;
import modchart.*;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.FlxG;
import math.Vector3;
import math.*;

typedef PathInfo = {
  var position:Vector3;
  var dist:Float;
  var start:Float;
  var end:Float;
}

class PathModifier extends Modifier {
  var moveSpeed:Float;
  var pathData:Array<PathInfo>=[];
  var totalDist:Float = 0;
  public function new(modMgr:ModManager, path:Array<Vector3>, moveSpeed:Float=5000){
    super(modMgr);
    this.moveSpeed=moveSpeed;
    var idx:Int = 0;
    // ridiculous that haxe doesnt have a numeric for loop

    while(idx<path.length){
      var pos = path[idx];
      if(idx!=0){
        var last = pathData[idx-1];
        totalDist += Math.abs(Vector3.distance(last.position, pos)); // idk if haxeflixel will for some reason ever return negative distance
        // roblox doesnt so im just making sure
        last.end = totalDist;
        last.dist = last.start - totalDist; // used for interpolation
      }

      pathData.push({
        position: pos,
        start: totalDist,
        end: 0,
        dist: 0
      });
      idx++;
    }
  }


  override function getPath(visualDiff:Float, pos:Vector3, data:Int, player:Int, timeDiff:Float){
    if(getPercent(player)==0)return pos;
    //var vDiff = Math.abs(timeDiff);
    var vDiff = timeDiff;
    // tried to use visualDiff but didnt work :(
    // will get it working later

    var progress  = (vDiff / -moveSpeed) * totalDist;
    if(progress<=0)return pos.lerp(pathData[0].position,getPercent(player));

    var idx:Int = 0;
    // STILL ridiculous
    while(idx<pathData.length){
      var cData = pathData[idx];
      var nData = pathData[idx+1];
      if(nData!=null && cData!=null){
        if(progress>cData.start && progress<cData.end){
          var alpha = (cData.start - progress)/cData.dist;
          var interpPos:Vector3 = cData.position.lerp(nData.position,alpha);
          return pos.lerp(interpPos,getPercent(player));
        }
      }
      idx++;
    }
    return pos;
  }

  override function getSubmods(){
    return [];
  }
}
