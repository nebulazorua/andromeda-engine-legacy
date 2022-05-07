package;

import flixel.FlxCamera;
import flixel.math.FlxPoint;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import flixel.FlxG;
import Shaders;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import Options;

class FNFCamera extends FlxCamera {
  public var scrollOffset:FlxPoint = FlxPoint.get();
  public var offset:FlxPoint = FlxPoint.get();
  public var angleOffset(default, set):Float = 0;

  private var _scroll:FlxPoint = FlxPoint.get();

  public var yaw(default, set):Float = 0;
  public var pitch(default, set):Float = 0;
  public var filters( get, null ):Array<BitmapFilter> = [];
  public var useRaymarcher(default, set):Bool = true;
  public var baseWidth:Float = FlxG.width;
  public var baseHeight:Float = FlxG.height;
  var raymarcher:RaymarchEffect = new RaymarchEffect();
  var raymarcherShader:BitmapFilter;

  public function new(X:Int = 0, Y:Int = 0, Width:Int = 0, Height:Int = 0, Zoom:Float = 0){
    super(X,Y,Width,Height,Zoom);
    if(!OptionUtils.options.raymarcher)
      useRaymarcher=false;
    raymarcherShader = new ShaderFilter(raymarcher.shader);


    if(useRaymarcher){
      _filters = [raymarcherShader];
    }
  }

  public function addFilter(filter:BitmapFilter){
    _filters.push(filter);
  }

  public function delFilter(filter:BitmapFilter){
    _filters.remove(filter);
  }

  override function updateFollow(){
    // Either follow the object closely,
		// or double check our deadzone and update accordingly.
		if (deadzone == null)
		{
			target.getMidpoint(_point);
			_point.addPoint(targetOffset);
			focusOn(_point);
		}
		else
		{
			var edge:Float;
			var targetX:Float = target.x + targetOffset.x;
			var targetY:Float = target.y + targetOffset.y;

			if (style == SCREEN_BY_SCREEN)
			{
				if (targetX >= (_scroll.x + width))
				{
					_scrollTarget.x += width;
				}
				else if (targetX < _scroll.x)
				{
					_scrollTarget.x -= width;
				}

				if (targetY >= (_scroll.y + height))
				{
					_scrollTarget.y += height;
				}
				else if (targetY < _scroll.y)
				{
					_scrollTarget.y -= height;
				}
			}
			else
			{
				edge = targetX - deadzone.x;
				if (_scrollTarget.x > edge)
				{
					_scrollTarget.x = edge;
				}
				edge = targetX + target.width - deadzone.x - deadzone.width;
				if (_scrollTarget.x < edge)
				{
					_scrollTarget.x = edge;
				}

				edge = targetY - deadzone.y;
				if (_scrollTarget.y > edge)
				{
					_scrollTarget.y = edge;
				}
				edge = targetY + target.height - deadzone.y - deadzone.height;
				if (_scrollTarget.y < edge)
				{
					_scrollTarget.y = edge;
				}
			}

			if ((target is FlxSprite))
			{
				if (_lastTargetPosition == null)
				{
					_lastTargetPosition = FlxPoint.get(target.x, target.y); // Creates this point.
				}
				_scrollTarget.x += (target.x - _lastTargetPosition.x) * followLead.x;
				_scrollTarget.y += (target.y - _lastTargetPosition.y) * followLead.y;

				_lastTargetPosition.x = target.x;
				_lastTargetPosition.y = target.y;
			}

			if (followLerp >= 60 / FlxG.updateFramerate)
			{
				_scroll.copyFrom(_scrollTarget); // no easing
			}
			else
			{
				_scroll.x += (_scrollTarget.x - _scroll.x) * followLerp * FlxG.updateFramerate / 60;
				_scroll.y += (_scrollTarget.y - _scroll.y) * followLerp * FlxG.updateFramerate / 60;
			}
		}
  }

  override function updateScroll(){
    var zoom = this.zoom / FlxG.initialZoom;

    var minX:Null<Float> = minScrollX == null ? null : minScrollX - (zoom - 1) * width / (2 * zoom);
    var maxX:Null<Float> = maxScrollX == null ? null : maxScrollX + (zoom - 1) * width / (2 * zoom);
    var minY:Null<Float> = minScrollY == null ? null : minScrollY - (zoom - 1) * height / (2 * zoom);
    var maxY:Null<Float> = maxScrollY == null ? null : maxScrollY + (zoom - 1) * height / (2 * zoom);

    // Make sure we didn't go outside the camera's bounds
    _scroll.x = FlxMath.bound(_scroll.x, minX, (maxX != null) ? maxX - width : null);
    _scroll.y = FlxMath.bound(_scroll.y, minY, (maxY != null) ? maxY - height : null);

    scroll.x = _scroll.x;
    scroll.y = _scroll.y;

    scroll.addPoint(scrollOffset);

  }

  override function update(elapsed){
    super.update(elapsed);
    flashSprite.x += offset.x;
    flashSprite.y += offset.y;

  }

  public function set_useRaymarcher(val:Bool){
    if((_filters is Array)){
      if(!val && _filters.contains(raymarcherShader)){
        _filters.remove(raymarcherShader);
      }else if(val && !_filters.contains(raymarcherShader) ){
        _filters.push(raymarcherShader);
      }
    }else if(val){
      _filters = [raymarcherShader];
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

  override public function set_angle(val:Float){
    flashSprite.rotation = val + angleOffset;
    return angle = val;
  }

  public function set_angleOffset(val:Float){
    flashSprite.rotation = angle + val;
    return angleOffset = val;
  }

  public function get_filters(){
    return _filters;
  }

  override function setFilters(filters:Array<BitmapFilter>){
    super.setFilters(filters);
    if(useRaymarcher){
      if(_filters != null){
        _filters.push(raymarcherShader);
      }else{
        _filters =[raymarcherShader];
      }
    }
  }

  override function destroy(){
    offset.put();
    scrollOffset.put();
    _scroll.put();

    super.destroy();
  }
}
