package ui;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.graphics.frames.FlxFrame;
import flash.display.BitmapData;
#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end
import flixel.graphics.frames.FlxFramesCollection;
import haxe.Json;
import haxe.format.JsonParser;
import haxe.macro.Type;
import lime.utils.Assets;
import ui.Note.NoteBehaviour;
import flixel.math.FlxPoint;
import states.*;

using StringTools;

class NoteGraphic extends FNFSprite
{
	public var modifier = 'base';
	public var skin='default';
	public var graphicType='';
	public var behaviour:NoteBehaviour;
	public static var noteframeCaches:Map<String,FlxFramesCollection>=[];
	public static var swagWidth:Float = 160 * 0.7;
	public var quantTexture:Int = 4;
	public var noteAngles:Array<Float>=[0,0,0,0];
	public var scaleDefault:FlxPoint;
	public var baseAngle:Float = 0;
	public var modAngle:Float = 0;
	public var graphicDir:Int=0;

	public var quantToGrid:Map<Int,Int>=[
		4=>0,
		8=>1,
		12=>2,
		16=>3,
		24=>4,
		32=>5,
		48=>6,
		64=>7,
		192=>8,
	];

	public var quantToIndex:Map<Int,String>=[
		4=>"4th",
		8=>"8th",
		12=>"12th",
		16=>"16th",
		24=>"24th",
		32=>"32nd",
		48=>"48th",
		64=>"64th",
		192=>"192nd",
	];

	// TODO: redo alot of this to have shit determined when you select the noteskin

	public function new(strumTime:Float=0,?modifier:String='base',?skin:String='default',type:String='default', behaviour:NoteBehaviour)
	{
		super();
		graphicType=type;
		scaleDefault = FlxPoint.get();

		var beat = Conductor.getBeatInMeasure(strumTime);
		this.quantTexture = Note.getQuant(beat);

		this.modifier=modifier;
		this.skin=skin;
		this.behaviour=behaviour;

		var daStage:String = PlayState.curStage;
		setTextures();

		animation.play("greenScroll");
	}

	public function setTextures(){
		switch (behaviour.actsLike)
		{
			case 'pixel':
				//loadGraphic(Paths.image('pixelUI/arrows-pixels',"shared"), true, 17, 17);
				loadGraphic(Paths.noteSkinImage(behaviour.arguments.note.sheet, 'skins', skin, modifier, graphicType),true,behaviour.arguments.note.gridSizeX,behaviour.arguments.note.gridSizeY);
				if(behaviour.arguments.note.quant){
					var index = Reflect.field(behaviour.arguments.note,quantToIndex.get(quantTexture) );
					if(index==null){
						animation.add('greenScroll', [behaviour.arguments.note.up+4*quantToGrid.get(quantTexture)]);
						animation.add('redScroll', [behaviour.arguments.note.right+4*quantToGrid.get(quantTexture)]);
						animation.add('blueScroll', [behaviour.arguments.note.down+4*quantToGrid.get(quantTexture)]);
						animation.add('purpleScroll', [behaviour.arguments.note.left+4*quantToGrid.get(quantTexture)]);
					}else{
						animation.add('greenScroll', index.up);
						animation.add('redScroll', index.right);
						animation.add('blueScroll', index.down);
						animation.add('purpleScroll', index.left);
					}
				}else{
					animation.add('greenScroll', behaviour.arguments.note.up );
					animation.add('redScroll', behaviour.arguments.note.right);
					animation.add('blueScroll', behaviour.arguments.note.down);
					animation.add('purpleScroll', behaviour.arguments.note.left);
				}
				var dirs = ["left","down","up","right"];

				for(i in 0...dirs.length){
					var dir = dirs[i];
				 	var angle:Null<Float>= Reflect.field(behaviour.arguments.note,'${dir}Angle');
					if(angle!=null){
						noteAngles[i]=angle;
					}else{
						noteAngles[i]=0;
					}
				}

				setGraphicSize(Std.int(width * behaviour.scale));
				updateHitbox();
				antialiasing = behaviour.antialiasing;
				scaleDefault.set(scale.x,scale.y);
			default:
				var setSize:Bool=false;
				var args = behaviour.arguments.notes;
				if(frames!=noteframeCaches.get(graphicType) || !noteframeCaches.exists(graphicType)){
					frames = !noteframeCaches.exists(graphicType)?Paths.noteSkinAtlas(args.sheet, 'skins', skin, modifier, graphicType):noteframeCaches.get(graphicType);
					noteframeCaches.set(graphicType,frames);
					setSize=true;
				}
				var quantIdx = quantToIndex.get(quantTexture);
				var field = Reflect.field(args.quants,quantIdx);
				if(args.quants!=null && field!=null ){
					var colors = [
						"purple",
						"blue",
						"green",
						"red"
					];
					var dirs = ["left","down","up","right"];

					for(i in 0...dirs.length){
						var dirData = Reflect.field(field,dirs[i]);
						var prefix = Reflect.field(dirData,"prefix");
						var longPrefix = Reflect.field(dirData,"longPrefix");
						var longEndPrefix = Reflect.field(dirData,"longEndPrefix");
						if(prefix==null)prefix=field.prefix;
						if(longPrefix==null)longPrefix=field.longPrefix;
						if(longEndPrefix==null)longEndPrefix=field.longEndPrefix;

						if(prefix==null)prefix=Reflect.field(args,dirs[i]).prefix;
						if(longPrefix==null)longPrefix=Reflect.field(args,dirs[i]).longPrefix;
						if(longEndPrefix==null)longEndPrefix=Reflect.field(args,dirs[i]).longEndPrefix;

						animation.addByPrefix('${colors[i]}Scroll', prefix);
						animation.addByPrefix('${colors[i]}hold', longPrefix);
						animation.addByPrefix('${colors[i]}holdend', longEndPrefix);

						noteAngles[i] = dirData.angle;
					}
				}else{
					animation.addByPrefix('greenScroll', args.up.prefix);
					animation.addByPrefix('redScroll', args.right.prefix);
					animation.addByPrefix('blueScroll', args.down.prefix);
					animation.addByPrefix('purpleScroll', args.left.prefix);

					animation.addByPrefix('greenhold', args.up.longPrefix);
					animation.addByPrefix('redhold', args.right.longPrefix);
					animation.addByPrefix('bluehold', args.down.longPrefix);
					animation.addByPrefix('purplehold', args.left.longPrefix);

					animation.addByPrefix('greenholdend', args.up.longEndPrefix);
					animation.addByPrefix('redholdend', args.right.longEndPrefix);
					animation.addByPrefix('blueholdend', args.down.longEndPrefix);
					animation.addByPrefix('purpleholdend', args.left.longEndPrefix);

					noteAngles[0] = args.left.angle;
					noteAngles[1] = args.down.angle;
					noteAngles[2] = args.up.angle;
					noteAngles[3] = args.right.angle;
				}

				if(setSize){
					setGraphicSize(Std.int(width * behaviour.scale));
					updateHitbox();
					scaleDefault.set(scale.x,scale.y);
				}
				antialiasing = behaviour.antialiasing;
		}
	}

	override function update(elapsed){
		angle = baseAngle + modAngle;
		super.update(elapsed);
	}

	public function setDir(dir:Int=0,?sussy:Bool=false,?end:Bool=false){
		var colors = ["purple","blue","green","red"];
		var suffix='Scroll';
		if(sussy){
			suffix='hold';
			if(end)suffix+='end';
		};
		var quant = quantToGrid.get(quantTexture);
		if(sussy && behaviour.actsLike=='pixel'){
			if(animation.curAnim!=null){
				if(end && !animation.curAnim.name.endsWith("end")){
					var args = behaviour.arguments.sustainEnd;

					loadGraphic(Paths.noteSkinImage(args.sheet, 'skins', skin, modifier, graphicType),true,args.gridSizeX,args.gridSizeY);
					// TODO: quantsz
					if(args.quant){
						var index = Reflect.field(args,quantToIndex.get(quantTexture) );
						var gridIndex=quantToGrid.get(quantTexture);
						if(index!=null){
							animation.add('purpleholdend', index);
							animation.add('greenholdend', index);
							animation.add('redholdend', index);
							animation.add('blueholdend', index);
						}else{
							gridIndex+=9;
							animation.add('purpleholdend', [gridIndex]);
							animation.add('greenholdend', [gridIndex]);
							animation.add('redholdend', [gridIndex]);
							animation.add('blueholdend', [gridIndex]);
						}
					}else{
						animation.add('purpleholdend', args.left);
						animation.add('greenholdend', args.up);
						animation.add('redholdend', args.right);
						animation.add('blueholdend', args.down);
					}

					setGraphicSize(Std.int(width * behaviour.scale));
					updateHitbox();
					scaleDefault.set(scale.x,scale.y);
				}else if(!end){
					var args = behaviour.arguments.sustain;

					loadGraphic(Paths.noteSkinImage(args.sheet, 'skins', skin, modifier, graphicType),true,args.gridSizeX,args.gridSizeY);
					// TODO: quants
					if(args.quant){
						var index = Reflect.field(args,quantToIndex.get(quantTexture) );
						var gridIndex=quantToGrid.get(quantTexture);
						if(index!=null){
							animation.add('purplehold', index);
							animation.add('greenhold', index);
							animation.add('redhold', index);
							animation.add('bluehold', index);
						}else{
							animation.add('purplehold', [gridIndex]);
							animation.add('greenhold', [gridIndex]);
							animation.add('redhold', [gridIndex]);
							animation.add('bluehold', [gridIndex]);
						}
					}else{
						animation.add('purplehold', args.left);
						animation.add('greenhold', args.up);
						animation.add('redhold', args.right);
						animation.add('bluehold', args.down);
					}
					setGraphicSize(Std.int(width * behaviour.scale));
					updateHitbox();
					scaleDefault.set(scale.x,scale.y);
				}
			}
		}else if(behaviour.actsLike=='pixel' && !sussy){
			loadGraphic(Paths.noteSkinImage(behaviour.arguments.note.sheet, 'skins', skin, modifier, graphicType),true,behaviour.arguments.note.gridSizeX,behaviour.arguments.note.gridSizeY);

			if(behaviour.arguments.note.quant){
				var addition  = 4*quantToGrid.get(quantTexture);
				var index = Reflect.field(behaviour.arguments.note,quantToIndex.get(quantTexture) );
				if(index==null){
					animation.add('greenScroll', [behaviour.arguments.note.up+addition]);
					animation.add('redScroll', [behaviour.arguments.note.right+addition]);
					animation.add('blueScroll', [behaviour.arguments.note.down+addition]);
					animation.add('purpleScroll', [behaviour.arguments.note.left+addition]);
				}else{
					animation.add('greenScroll', index.up);
					animation.add('redScroll', index.right);
					animation.add('blueScroll', index.down);
					animation.add('purpleScroll', index.left);
				}
			}else{
				animation.add('greenScroll', behaviour.arguments.note.up );
				animation.add('redScroll', behaviour.arguments.note.right);
				animation.add('blueScroll', behaviour.arguments.note.down);
				animation.add('purpleScroll', behaviour.arguments.note.left);
			}
			var dirs = ["left","down","up","right"];

			for(i in 0...dirs.length){
				var dir = dirs[i];
				var angle:Null<Float>= Reflect.field(behaviour.arguments.note,'${dir}Angle');
				if(angle!=null){
					noteAngles[i]=angle;
				}else{
					noteAngles[i]=0;
				}
			}

			setGraphicSize(Std.int(width * behaviour.scale));
			updateHitbox();
			scaleDefault.set(scale.x,scale.y);
		}

		graphicDir=dir;

		if(colors[dir]!=null){
			animation.play('${colors[dir]}${suffix}',true);
			if(!sussy)
				baseAngle = noteAngles[dir];
			else
				baseAngle = 0;
		}
	}
}
