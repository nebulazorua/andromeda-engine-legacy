package modchart.modifiers;
import ui.*;
import modchart.*;
import flixel.math.FlxPoint;
import math.Vector3;
import flixel.math.FlxMath;
import flixel.FlxG;
using StringTools;

// NOTE: THIS SHOULDNT HAVE ITS PERCENTAGE MODIFIED
// THIS IS JUST HERE TO ALLOW OTHER MODIFIERS TO HAVE PERSPECTIVE

// did my research
// i now know what a frustrum is lmao
// stuff ill forget after tonight

// its the next day and yea i forgot already LOL
// something somethng clipping idk

// either way
// perspective projection woo

class PerspectiveModifier extends Modifier {
  var fov = Math.PI/2;
  var near = 0;
  var far = 2;

  function FastTan(rad:Float) // thanks schmoovin
  {
    return FlxMath.fastSin(rad) / FlxMath.fastCos(rad);
  }


  public function getVector(curZ:Float,pos:FlxPoint):Vector3{
    var oX = pos.x;
    var oY = pos.y;

    // should I be using a matrix?
    // .. nah im sure itll be fine just doing this manually
    // instead of doing a proper perspective projection matrix

    //var aspect = FlxG.width/FlxG.height;
    var aspect = 1;

    var shit = curZ-1;
    if(shit>0)shit=0; // thanks schmovin!!

    var ta = FastTan(fov/2);
    var x = oX * aspect/ta;
    var y = oY/ta;
    var a = (near+far)/(near-far);
    var b = 2*near*far/(near-far);
    var z = (a*shit+b);
    var returnedVector = new Vector3(x/z,y/z,z);

    return returnedVector;
  }

  override function getReceptorPos(receptor:Receptor, pos:FlxPoint, data:Int, player:Int){ // maybe replace FlxPoint with a Vector3?
    // HI 4MBR0S3 IM SORRY :(( I GENUINELY FUCKIN FORGOT TO CREDIT PLEASEDONTHATEMEILOVEYOURSTUFF:(
    var vec = getVector(receptor.z,pos);
    pos.x=vec.x;
    pos.y=vec.y;

    return pos;
  }

  override function updateReceptor(pos:FlxPoint, scale:FlxPoint, receptor:Receptor){
    var vec = getVector(receptor.z,pos);

    scale.scale(1/vec.z);
  }

  override function updateNote(pos:FlxPoint, scale:FlxPoint, note:Note){
    var vec = getVector(note.z,pos);

    if(note.isSustainNote){
      scale.set(scale.x*(1/vec.z),scale.y);
    }else{
      scale.scale(1/vec.z);
    }
  }

}
