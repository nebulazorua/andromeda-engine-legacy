package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end

using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var manualXOffset:Float = 0;
	public var manualYOffset:Float = 0;
	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var hit:Bool = false;
	public var rating:String = "sick";
	public var lastSustainPiece = false;
	public var defaultX:Float = 0;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var rawNoteData:Int = 0; // for charting shit and thats it LOL
	public var holdParent:Bool=false;
	public var noteType:Int = 0;
	public var beingCharted:Bool=false;
	public var initialPos:Float = 0;

	public var noteScore:Float = 1;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?initialPos:Float=0, ?beingCharted=false)
	{
		super();

		this.initialPos=initialPos;
		this.beingCharted=beingCharted;
		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;

		this.noteData = noteData;

		var daStage:String = PlayState.curStage;

		switch (daStage)
		{
			case 'school' | 'schoolEvil':
				loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);

				animation.add('greenScroll', [6]);
				animation.add('redScroll', [7]);
				animation.add('blueScroll', [5]);
				animation.add('purpleScroll', [4]);

				if (isSustainNote)
				{
					loadGraphic(Paths.image('weeb/pixelUI/arrowEnds'), true, 7, 6);

					animation.add('purpleholdend', [4]);
					animation.add('greenholdend', [6]);
					animation.add('redholdend', [7]);
					animation.add('blueholdend', [5]);

					animation.add('purplehold', [0]);
					animation.add('greenhold', [2]);
					animation.add('redhold', [3]);
					animation.add('bluehold', [1]);
				}

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();

			default:
				frames = Paths.getSparrowAtlas('NOTE_assets');

				animation.addByPrefix('greenScroll', 'green0');
				animation.addByPrefix('redScroll', 'red0');
				animation.addByPrefix('blueScroll', 'blue0');
				animation.addByPrefix('purpleScroll', 'purple0');

				animation.addByPrefix('purpleholdend', 'pruple end hold');
				animation.addByPrefix('greenholdend', 'green hold end');
				animation.addByPrefix('redholdend', 'red hold end');
				animation.addByPrefix('blueholdend', 'blue hold end');

				animation.addByPrefix('purplehold', 'purple hold piece');
				animation.addByPrefix('greenhold', 'green hold piece');
				animation.addByPrefix('redhold', 'red hold piece');
				animation.addByPrefix('bluehold', 'blue hold piece');

				setGraphicSize(Std.int(width * 0.7));
				updateHitbox();
				antialiasing = true;
		}

		var colors = ["purple","blue","green","red"];

		x += swagWidth * noteData;
		animation.play('${colors[noteData]}Scroll');

		// trace(prevNote);

		if (isSustainNote && prevNote != null)
		{
			prevNote.holdParent=true;
			noteScore * 0.2;
			alpha = 0.6;

			//var off = -width;
			var off = -width/4;
			//x+=width/2;
			lastSustainPiece=true;

			manualXOffset = width/2;
			animation.play('${colors[noteData]}holdend');
			updateHitbox();

			if(PlayState.currentPState.currentOptions.downScroll){
				flipY=true;
			}

			//off -= width / 2;
			//x -= width / 2;

			manualXOffset -= width/ 2;
			if (PlayState.curStage.startsWith('school'))
				manualXOffset += 30;
			else
				manualXOffset += 2;

			if (prevNote.isSustainNote)
			{
				prevNote.lastSustainPiece=false;
				prevNote.animation.play('${colors[noteData]}hold');
				if(!beingCharted)
					prevNote.scale.y *= ((.45*Conductor.stepCrochet*PlayState.getFNFSpeed(strumTime))+1)/prevNote.height;
				prevNote.updateHitbox();

				prevNote.offset.y += -prevNote.offset.y;

				offset.y += -offset.y;
				// prevNote.setGraphicSize();
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			if(isSustainNote){
				if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * 1.5)
					&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * .25))
					canBeHit = true;
				else
					canBeHit = false;
			}else{
				if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * 1.5)
					&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 1))
					canBeHit = true;
				else
					canBeHit = false;
			}




			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			if (strumTime <= Conductor.songPosition)
				canBeHit = true;
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}
