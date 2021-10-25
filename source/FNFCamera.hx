package;

import flixel.FlxCamera;
import flixel.math.FlxPoint;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import flixel.FlxG;
import Shaders;

class FNFCamera extends FlxCamera {
  public var offset:FlxPoint = FlxPoint.get();

  public var yaw(default, set):Float = 0;
  public var pitch(default, set):Float = 0;

  public var useRaymarcher(default, set):Bool = true;

  var raymarcher:RaymarchEffect = new RaymarchEffect();
  var raymarcherShader:BitmapFilter;

  public function new(X:Int = 0, Y:Int = 0, Width:Int = 0, Height:Int = 0, Zoom:Float = 0){
    super(X,Y,Width,Height,Zoom);

    raymarcherShader = new ShaderFilter(raymarcher.shader);

    if(useRaymarcher){
      _filters = [raymarcherShader];
    }
  }


  override function updateScroll(){
    super.updateScroll();
    scroll.addPoint(offset);
  }

  public function set_useRaymarcher(val:Bool){
    if(!val && _filters.contains(raymarcherShader)){
      _filters.remove(raymarcherShader);
    }else if(val && !_filters.contains(raymarcherShader)){
      _filters.push(raymarcherShader);
    }
    return useRaymarcher = val;
  }

  public function set_yaw(val:Float){
    raymarcher.setYaw(val);
    return yaw = val;
  }

  public function set_pitch(val:Float){
    raymarcher.setPitch(val);
    return pitch = val;
  }

  override function setFilters(filters:Array<BitmapFilter>){
    super.setFilters(filters);
    if(useRaymarcher){
      _filters.push(raymarcherShader);
      trace("added raymarcher");
    }
  }

  override function destroy(){
    offset.put();

    super.destroy();
  }
}
