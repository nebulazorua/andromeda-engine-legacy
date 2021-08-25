package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup;
import flixel.addons.display.FlxTiledSprite;

#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end

using StringTools;

/*class LongNote extends FlxTiledSprite
// I HAVE NO FUCKING CLUE HOW INTERFACES WORK
// BUT IT SHOULD PROBABLY BE USED HERE LMAO
{
	public var strumTime:Float = 0;
	public var manualXOffset:Float = 0;
	public var manualYOffset:Float = 0;
	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var isSustainNote:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var hit:Bool = false;
	public var rating:String = "sick";
	public var lastSustainPiece = false;
	public var defaultX:Float = 0;
	public var sustainLength:Float = 0;
	public var rawNoteData:Int = 0;
	public var holdParent:Bool=false;
	public var noteType:Int = 0;
	public var beingCharted:Bool=false;
	public var initialPos:Float = 0;
	public static var swagWidth:Float = 160 * 0.7;

	public function new(strumTime:Float, noteData:Int, length:Float, beingCharted:Bool){

		var daStage:String = PlayState.curStage;

		switch (daStage)
		{
			case 'school' | 'schoolEvil':
				super(Paths.image('weeb/pixelUI/arrowEnds',"shared"),7,6);
			default:
				super(Paths.image('NOTE_assets',"shared"),50,44);
		}


		sustainLength=length;
		this.noteData=noteData;
		this.beingCharted=beingCharted;
		this.strumTime=strumTime;

		switch (daStage)
		{
			case 'school' | 'schoolEvil':
				loadGraphic(Paths.image('weeb/pixelUI/arrowEnds','shared'), true, 7, 6);

				animation.add('purpleholdend', [4]);
				animation.add('greenholdend', [6]);
				animation.add('redholdend', [7]);
				animation.add('blueholdend', [5]);

				animation.add('purplehold', [0]);
				animation.add('greenhold', [2]);
				animation.add('redhold', [3]);
				animation.add('bluehold', [1]);

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();

			default:
				frames = Paths.getSparrowAtlas('NOTE_assets','shared');

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

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		x += swagWidth * noteData;

		var colors = ["purple","blue","green","red"];
		width=44;
		height=50;
		repeatX=false;
		for(frame in frames.frames){
			trace(frame.name);
			if(frame.name == 'blue hold piece0000'){
				loadFrame(frame);
				break;
			}


		}
	}
}*/

class Note extends NoteGraphic
{
	public var strumTime:Float = 0;
	public var manualXOffset:Float = 0;
	public var manualYOffset:Float = 0;
	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var isSustainNote:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var hit:Bool = false;
	public var rating:String = "sick";
	public var lastSustainPiece = false;
	public var defaultX:Float = 0;
	public var sustainLength:Float = 0;
	public var rawNoteData:Int = 0;
	public var holdParent:Bool=false;
	public var noteType:Int = 0;
	public var beingCharted:Bool=false;
	public var initialPos:Float = 0;

	public static var swagWidth:Float = 160 * 0.7;

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

		var colors = ["purple","blue","green","red"];

		x += swagWidth * noteData;
		setDir(noteData,false,false);

		// trace(prevNote);

		if (isSustainNote && prevNote != null)
		{
			prevNote.holdParent=true;
			alpha = 0.6;

			//var off = -width;
			//x+=width/2;
			lastSustainPiece=true;

			manualXOffset = width/2;
			setDir(noteData,true,true);
			updateHitbox();

			if(!beingCharted){
				if(PlayState.currentPState.currentOptions.downScroll ){
					flipY=true;
				}
				if(PlayState.getSVFromTime(strumTime)<0){
					flipY=!flipY;
				}
			}


			//off -= width / 2;
			//x -= width / 2;

			manualXOffset -= width/ 2;
			//if (PlayState.curStage.startsWith('school'))
			//	manualX Offset += 30;
			if (prevNote.isSustainNote)
			{
				prevNote.lastSustainPiece=false;
				//prevNote.noteGraphic.animation.play('${colors[noteData]}hold');
				prevNote.setDir(noteData,true,false);
				if(!beingCharted)
					prevNote.scale.y *= Conductor.stepCrochet/100*1.5*PlayState.getFNFSpeed(strumTime);
				prevNote.updateHitbox();
			}
		}
	} 

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (mustPress)
		{
			var diff = strumTime-Conductor.songPosition;
			var absDiff = Math.abs(diff);

			if(isSustainNote){
				if (absDiff <= 60)
					canBeHit = true;
				else
					canBeHit = false;
			}else{
				if (absDiff<=Conductor.safeZoneOffset)
					canBeHit = true;
				else
					canBeHit = false;
			}




			if (diff<-Conductor.safeZoneOffset && !wasGoodHit)
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
