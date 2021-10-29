package parsers;

// https://github.com/ShadowMario/FNF-PsychEngine/blob/main/source/Character.hx
// shadowmario, if you dont want this here, tell me and I'll remove it!

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flash.display.BitmapData;
import sys.io.File;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxPoint;
import sys.FileSystem;
import haxe.Json;
using StringTools;

typedef PsychAnim = {
  var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
}

typedef PsychChar = {
  var animations:Array<PsychAnim>;
	var image:String;
	var scale:Float;
	var sing_duration:Float;
	var healthicon:String;

	var position:Array<Float>;
	var camera_position:Array<Float>;

	var flip_x:Bool;
	var no_antialiasing:Bool;
	var healthbar_colors:Array<Int>;
}

class PsychParsers {

  /*public static function toChar(){ // andromeda to psych
    var obj:PsychChar = {};

    return obj;
  }*/

  public static function fromChar(char:PsychChar){ // psych to andromeda
    var beatDancer = false;
    var colour = FlxColor.fromRGB(char.healthbar_colors[0],char.healthbar_colors[1],char.healthbar_colors[2]);
    var newAnims:Array<Character.AnimShit>= [];
    for(anim in char.animations){
      newAnims.push({
        prefix: anim.name,
        name: anim.anim,
        fps: anim.fps,
        looped: anim.loop,
        // DOES HAXEFLIXEL NOT HAVE AN EASY WAY
        // TO GO FROM INT TO FLOAT???
        // so fucking weird
        offsets: [Std.parseFloat(Std.string(anim.offsets[0])),Std.parseFloat(Std.string(anim.offsets[1]))],
        indices: anim.indices.length>0?anim.indices:null,
      });
    }
    var obj:Character.CharJson = {
      anims: newAnims,
      spritesheet: char.image.replace("characters/",""),
      singDur: char.sing_duration, // dadVar
      iconName: char.healthicon,
      healthColor: colour.toHexString(),
      charOffset: char.position,
      beatDancer: beatDancer,
      flipX: char.flip_x,
      antialiasing: !char.no_antialiasing,
      scale: char.scale,
      camOffset: char.camera_position
    }

    return obj;
  }
}
