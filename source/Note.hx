// some code for quants derived from https://github.com/openitg/openitg

// I'd derive from NotITG but its closed source
// sad.

package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup;
import flixel.addons.display.FlxTiledSprite;
import haxe.Json;
import haxe.format.JsonParser;
import haxe.macro.Type;
import lime.utils.Assets;

#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end

using StringTools;

typedef SkinManifest = {
	var name:String;
	var desc:String;
	var author:String;
	var format:String;
}

typedef NoteBehaviour = {
	var actsLike:String;
	var antialiasing:Bool;
	var scale:Float;
	var arguments:Dynamic;
	@:optional var receptorAutoColor:Bool;
	@:optional var receptorAlpha:Float;
	@:optional var sustainAlpha:Float;
	@:optional var defaultAlpha:Float;
}

class Note extends NoteGraphic
{
	public static var skinManifest:Map<String,SkinManifest>=[];


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
	public var noteType:String = 'tap';
	public var beingCharted:Bool=false;
	public var initialPos:Float = 0;

	public var desiredZIndex:Float = 0;
	public var zIndex:Float = 0;

	public var z:Float = 0;
	public var beat:Float = 0;
	public static var noteBehaviour:NoteBehaviour;

	public static var swagWidth:Float = 160 * 0.7;

	public static var quants:Array<Int> = [
		4, // quarter note
		8, // eight
		12, // etc
		16,
		24,
		32,
		48,
		64,
		192
	];

	// TODO: determine based on noteskin

	public static function getQuant(beat:Float){
		var row = Conductor.beatToNoteRow(CoolUtil.truncateFloat(beat,2));
		for(data in quants){
			if(row%(Conductor.ROWS_PER_MEASURE/data) == 0){
				return data;
			}
		}
		return quants[quants.length-1]; // invalid
	}

	public function isSustainEnd():Bool{
		if(isSustainNote && animation!=null && animation.curAnim!=null && animation.curAnim.name!=null && animation.curAnim.name.endsWith("end"))
			return true;

		return false;
	}

	public function new(strumTime:Float, noteData:Int, skin:String='default', modifier:String='base', ?prevNote:Note, ?sustainNote:Bool = false, ?initialPos:Float=0, ?beingCharted=false)
	{
		super(strumTime,modifier,skin,Note.noteBehaviour);

		this.beat = CoolUtil.truncateFloat(Conductor.getBeat(strumTime),2);

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

		alpha = Note.noteBehaviour.defaultAlpha!=null?Note.noteBehaviour.defaultAlpha:1;

		y =  ((initialPos-Conductor.currentTrackPos) * PlayState.currentPState.scrollSpeed) - manualYOffset;

		if (isSustainNote && prevNote != null)
		{
			quantTexture = prevNote.quantTexture;
			if(Note.noteBehaviour.actsLike!='pixel')
				setTextures();

			prevNote.holdParent=true;
			alpha = Note.noteBehaviour.sustainAlpha!=null?Note.noteBehaviour.sustainAlpha:0.6;

			//var off = -width;
			//x+=width/2;
			lastSustainPiece=true;

			manualXOffset = width/2;
			setDir(noteData,true,true);
			updateHitbox();



			if(!beingCharted){
				if(PlayState.getSVFromTime(strumTime)<0){
					flipY=!flipY;
				}
			}


			//off -= width / 2;
			//x -= width / 2;

			manualXOffset -= width/ 2;
			//if (PlayState.curStage.startsWith('school'))
				//manualXOffset += 51;
			if (prevNote.isSustainNote)
			{
				prevNote.lastSustainPiece=false;
				//prevNote.noteGraphic.animation.play('${colors[noteData]}hold');
				prevNote.setDir(noteData,true,false);
				if(!beingCharted)
					prevNote.scale.y *= Conductor.stepCrochet/100*1.5*PlayState.getFNFSpeed(strumTime);//prevNote.scale.y *= Math.abs(prevNote.y-y)/(prevNote.frameHeight);


				prevNote.scaleDefault.set(prevNote.scale.x,prevNote.scale.y);
				prevNote.updateHitbox();


			}
			scaleDefault.set(scale.x,scale.y);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(isSustainNote){
			if(prevNote!=null && prevNote.isSustainNote){
				zIndex=z + prevNote.zIndex;
			}else if(prevNote!=null && !prevNote.isSustainNote){
				zIndex=z + prevNote.zIndex-1;
			}
		}else{
			zIndex=z;
		}

		zIndex+=desiredZIndex;

		if (mustPress)
		{
			var diff = strumTime-Conductor.songPosition;
			var absDiff = Math.abs(diff);

			if(isSustainNote){
				if (absDiff <= Conductor.safeZoneOffset*.5)
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

	}
}
