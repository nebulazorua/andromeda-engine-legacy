package modchart.modifiers;

import ui.*;
import modchart.*;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.FlxG;
import math.Vector3;
import math.*;

typedef PathInfo =
{
	var position:Vector3;
	var dist:Float;
	var start:Float;
	var end:Float;
}

class PathModifier extends Modifier
{
	var moveSpeed:Float;
	var pathData:Array<Array<PathInfo>> = [];
	var totalDists:Array<Float> = [];

	public function new(modMgr:ModManager, path:Array<Array<Vector3>>, moveSpeed:Float = 5000)
	{
		super(modMgr);
		this.moveSpeed = moveSpeed;
		var dir:Int = 0;
		// ridiculous that haxe doesnt have a numeric for loop

		// neb from the future here
		// .. it fucking does
		// I forgot about (for start...end)
		// You just can't set the interval.
		// how did i forget it fucking has a numeric for loop im gonna kms.

		// TODO: rewrite this.

		while (dir < path.length)
		{
			var idx = 0;
			totalDists[dir] = 0;
			pathData[dir] = [];
			while (idx < path[dir].length)
			{
				var pos = path[dir][idx];

				if (idx != 0)
				{
					var last = pathData[dir][idx - 1];
					totalDists[dir] += Math.abs(Vector3.distance(last.position, pos)); // idk if haxeflixel will for some reason ever return negative distance
					var totalDist = totalDists[dir];
					// roblox doesnt so im just making sure
					last.end = totalDist;
					last.dist = last.start - totalDist; // used for interpolation
				}

				pathData[dir].push({
					position: pos.add(new Vector3(-Note.swagWidth / 2, -Note.swagWidth / 2)),
					start: totalDists[dir],
					end: 0,
					dist: 0
				});
				idx++;
			}
			dir++;
		}

		for (dir in 0...totalDists.length)
		{
			trace(dir, totalDists[dir]);
		}
	}

	override function getPath(visualDiff:Float, pos:Vector3, data:Int, player:Int, timeDiff:Float)
	{
		if (getPercent(player) == 0)
			return pos;
		// var vDiff = Math.abs(timeDiff);
		var vDiff = timeDiff;
		// tried to use visualDiff but didnt work :(
		// will get it working later

		var progress = (vDiff / -moveSpeed) * totalDists[data];
		var outPos = pos.clone();
		var daPath = pathData[data];
		if (progress <= 0)
			return pos.lerp(daPath[0].position, getPercent(player));

		var idx:Int = 0;
		// STILL ridiculous
		// no its not im just dumb

		while (idx < daPath.length)
		{
			var cData = daPath[idx];
			var nData = daPath[idx + 1];
			if (nData != null && cData != null)
			{
				if (progress > cData.start && progress < cData.end)
				{
					var alpha = (cData.start - progress) / cData.dist;
					var interpPos:Vector3 = cData.position.lerp(nData.position, alpha);
					outPos = pos.lerp(interpPos, getPercent(player));
				}
			}
			idx++;
		}
		return outPos;
	}

	override function getSubmods()
	{
		return [];
	}
}
