package;

import flixel.util.typeLimit.OneOfTwo;

typedef Event = {
	var time: Float;
	@:optional var name: String; // old system
	@:optional var args: Array<Dynamic>; // old system
	@:optional var events: Array<Event>; // new system
}

typedef SwagSection =
{
	var sectionNotes:Array<Array<Dynamic>>;
	var lengthInSteps:Int;
	var typeOfSection:Int;
	var mustHitSection:Bool;
	var bpm:Int;
	var changeBPM:Bool;
	var altAnim:Bool;
	@:optional var events:Array<Event>;
}

class Section
{
	public var sectionNotes:Array<Array<Dynamic>> = [];

	public var lengthInSteps:Int = 16;
	public var typeOfSection:Int = 0;
	public var mustHitSection:Bool = true;

	/**
	 *	Copies the first section into the second section!
	 */
	public static var COPYCAT:Int = 0;

	public function new(lengthInSteps:Int = 16)
	{
		this.lengthInSteps = lengthInSteps;
	}
}
