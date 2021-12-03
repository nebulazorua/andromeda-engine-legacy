package ui;

import flash.geom.Rectangle;
import flixel.addons.ui.interfaces.IEventGetter;
import flixel.addons.ui.interfaces.IFlxUIButton;
import flixel.addons.ui.interfaces.IFlxUIClickable;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.interfaces.IResizable;
import flixel.FlxSprite;
import flixel.system.FlxAssets;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxArrayUtil;
import flixel.math.FlxPoint;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import flixel.addons.ui.FlxUIGroup;
import flixel.addons.ui.FlxUIAssets;
import flixel.addons.ui.FlxUI9SliceSprite;

/**
 * @author Lars Doucet
 */

 // Modified from FlxUITabMenu for Andromeda

class UIGroup extends FlxUIGroup implements IResizable implements IFlxUIClickable implements IEventGetter
{
	public static inline var CLICK_EVENT:String = "menu_click";

	public static inline var STACK_FRONT:String = "front"; // button goes in front of backing
	public static inline var STACK_BACK:String = "back"; // buton goes behind backing


	/**To make IEventGetter happy**/
	public function getEvent(name:String, sender:IFlxUIWidget, data:Dynamic, ?params:Array<Dynamic>):Void
	{
		// donothing
	}

	public function getRequest(name:String, sender:IFlxUIWidget, data:Dynamic, ?params:Array<Dynamic>):Dynamic
	{
		// donothing
		return null;
	}

	/**For IFlxUIClickable**/
	public var skipButtonUpdate(default, set):Bool;

	private function set_skipButtonUpdate(b:Bool):Bool
	{
		skipButtonUpdate = b;
		for (sprite in members)
		{
			if ((sprite is IFlxUIClickable))
			{
				var widget:IFlxUIClickable = cast sprite;
				widget.skipButtonUpdate = b;
			}
		}

		return b;
	}

	/**For IResizable**/
	private override function get_width():Float
	{
		return _back.width;
	}

	private override function get_height():Float
	{
		return _back.height;
	}

	/***PUBLIC***/
	public function new(?back_:FlxSprite)
	{
		super();

		if (back_ == null)
		{
			// default, make this:
			back_ = new FlxUI9SliceSprite(0, 0, FlxUIAssets.IMG_CHROME_FLAT, new Rectangle(0, 0, 200, 200));
		}

		_back = back_;
		add(_back);

	}

	public override function destroy():Void
	{
		super.destroy();
		_back = null;
	}

	public function getBack():FlxSprite
	{
		return _back;
	}

	public function resize(W:Float, H:Float):Void
	{
		var ir:IResizable;
		if ((_back is IResizable))
		{
			ir = cast _back;
			ir.resize(W, H);

		}
	}

	public function replaceBack(newBack:FlxSprite):Void
	{
		var i:Int = members.indexOf(_back);
		if (i != -1)
		{
			var oldBack = _back;
			if ((newBack is IResizable))
			{
				var ir:IResizable = cast newBack;
				ir.resize(oldBack.width, oldBack.height);
			}
			members[i] = newBack;
			newBack.x = oldBack.x;
			newBack.y = oldBack.y;
			oldBack.destroy();
		}
	}

	/***PRIVATE***/
	private var _back:FlxSprite;


}
