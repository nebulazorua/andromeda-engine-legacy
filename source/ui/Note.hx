// some code for quants derived from https://github.com/openitg/openitg

// I'd derive from NotITG but its closed source
// sad.

package ui;

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
import states.*;
import Shaders;
import flixel.group.FlxGroup.FlxTypedGroup;

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
	@:optional var noHolds:Bool;
	@:optional var receptorAutoColor:Bool;
	@:optional var receptorAlpha:Float;
	@:optional var sustainAlpha:Float;
	@:optional var defaultAlpha:Float;
}

class Note extends NoteGraphic
{
	public static var skinManifest:Map<String,SkinManifest>=[];

	public var causesMiss:Bool=true;
	public var opponentMisses:Bool=false;
	public var canHold:Bool = true;
	public var strumTime:Float = 0;
	public var manualXOffset:Float = 0;
	public var manualYOffset:Float = 0;
	public var mustPress:Bool = false;
	public var shitId:Float = 0;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var isSustainNote:Bool = false;
	public var baseAlpha:Float = 1;
	public var desiredAlpha:Float = 1;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var nextNote:Note;
	public var hit:Bool = false;
	public var rating:String = "sick";
	public var lastSustainPiece = false;
	public var defaultX:Float = 0;
	public var sustainLength:Float = 0;
	public var rawNoteData:Int = 0;
	public var holdParent:Bool=false;
	public var noteType:String = 'default';
	public var beingCharted:Bool=false;
	public var initialPos:Float = 0;
	public var desiredZIndex:Float = 0;

	public var gcTime:Float = 200;
	public var garbage:Bool = false;

	public var isRoll:Bool = false;

	public var hitbox:Float = 166;

	public var beat:Float = 0;
	public static var defaultModifier:String = 'default';
	public static var noteBehaviour:NoteBehaviour;
	public static var behaviours:Map<String,Map<String,NoteBehaviour>>=[];
	public static var swagWidth:Float = 160 * 0.7;
	public var effect:NoteEffect;

	// holds v2
	public var parent:Note;
	public var tail:Array<Note> = [];
	public var unhitTail:Array<Note> = [];
	public var tripTimer:Float = 1;
	public var holdingTime:Float = 0;
	public var segment:Float = 0;

	public var causedMiss:Bool = false;
	public var beingHeld:Bool = false;

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
		var row = Conductor.beatToNoteRow(beat);
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

	public function new(strumTime:Float, noteData:Int, skin:String='default', modifier:String='base', type:String='default', ?prevNote:Note, ?sustainNote:Bool = false, ?rollNote:Bool = false, ?initialPos:Float=0, ?beingCharted=false)
	{

		this.noteType=type;
		isRoll = rollNote;
		hitbox = Conductor.safeZoneOffset;
		gcTime += hitbox;
		var graphicType:String = type;
		switch(noteType){
			case 'alt':
				trace("alt note");
				graphicType='default'; // makes it look like a normal note
			case 'mine':
				causesMiss=false;
				opponentMisses=true;
				canHold=false;
				hitbox = Conductor.safeZoneOffset*0.38; // should probably not scale but idk man
				gcTime *= 0.38;
		}
		var modBehaviours = Note.behaviours.get(graphicType);
		if(modBehaviours==null)modBehaviours = new Map<String,NoteBehaviour>();
		var behaviour = (modifier==Note.defaultModifier && type=='default')?Note.noteBehaviour:modBehaviours.get(graphicType);
		if(behaviour==null){
			behaviour = Json.parse(Paths.noteSkinText("behaviorData.json",'skins',skin,modifier,graphicType));
			modBehaviours.set(type,behaviour);
			Note.behaviours.set(modifier,modBehaviours);
		}
		//new(strumTime:Float=0,?modifier:String='base',?skin:String='default', type:String='default', behaviour:NoteBehaviour)

		super(strumTime,modifier,skin,graphicType,behaviour);

		if(!canHold && sustainNote){
			visible=false;
			kill();
			destroy();
			return;
		}


		this.beat = Conductor.getBeatInMeasure(strumTime);
		this.initialPos=initialPos;
		this.beingCharted=beingCharted;

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		var sustainType = 0;
		if(isSustainNote){
			sustainType=1;
			if(isRoll)sustainType=2;
		}

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;

		this.noteData = noteData;

		var daStage:String = PlayState.curStage;

		var colors = ["purple","blue","green","red"];

		x += swagWidth * noteData;
		setDir(noteData,0,false);

		// trace(prevNote);

		baseAlpha = behaviour.defaultAlpha!=null?behaviour.defaultAlpha:1;

		//y =  ((initialPos-Conductor.currentTrackPos) * PlayState.currentPState.scrollSpeed) - manualYOffset;

		effect = new NoteEffect();
		shader = effect.shader;

		if (isSustainNote && prevNote != null)
		{
			quantTexture = prevNote.quantTexture;
			if(behaviour.actsLike!='pixel')
				setTextures();

			prevNote.holdParent=true;
			baseAlpha = behaviour.sustainAlpha!=null?behaviour.sustainAlpha:0.6;

			//var off = -width;
			//x+=width/2;
			lastSustainPiece=true;

			manualXOffset = width/2;
			setDir(noteData,sustainType,true);
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
				prevNote.setDir(noteData,sustainType,false);
				if(!beingCharted){
					prevNote.scale.y *= (Conductor.stepCrochet / 100 * 1.5);
					prevNote.scale.y *= PlayState.getFNFSpeed(strumTime);
				}


				prevNote.scaleDefault.set(prevNote.scale.x,prevNote.scale.y);
				prevNote.updateHitbox();
			}
			scaleDefault.set(scale.x,scale.y);
		}

		if(prevNote!=null)
			prevNote.nextNote = this;

	}

	override function update(elapsed:Float)
	{
		alpha = CoolUtil.scale(desiredAlpha,0,1,0,baseAlpha);
		if(tooLate && !beingCharted)alpha*=.3;

		super.update(elapsed);

		if(isSustainNote && prevNote!=null && prevNote.isSustainNote){
			if(prevNote!=null && animation!=null && animation.curAnim!=null && prevNote.animation!=null && prevNote.animation.curAnim!=null) // WHY DO I HAVE TO DO THIS, HAXEFLIXEL??
				prevNote.animation.curAnim.curFrame = animation.curAnim.curFrame;
		}

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
		zIndex-=(mustPress==true?0:1);


		if (mustPress)
		{
			var diff = strumTime-Conductor.songPosition;
			var absDiff = Math.abs(diff);

			if(isSustainNote){
				if (absDiff <= hitbox*.5)
					canBeHit = true;
				else
					canBeHit = false;
			}else{
				if (absDiff<=hitbox)
					canBeHit = true;
				else
					canBeHit = false;
			}




			if (diff<-Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			var diff = strumTime-Conductor.songPosition;
			if (diff<-Conductor.safeZoneOffset && !wasGoodHit)
				tooLate=true;

			if(!opponentMisses){

				if(isSustainNote){
					if (diff <= 0)
						canBeHit = true;
					else
						canBeHit = false;
				}else{
					if (diff<=0)
						canBeHit = true;
					else
						canBeHit = false;
				}
			}else{
				canBeHit=false;
			}
		}

	}
}
