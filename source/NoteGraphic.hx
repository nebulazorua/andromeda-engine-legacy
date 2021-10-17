package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end
import haxe.Json;
import haxe.format.JsonParser;
import haxe.macro.Type;
import lime.utils.Assets;
import Note.NoteBehaviour;

using StringTools;

class NoteGraphic extends FlxSprite
{
	public var modifier = 'base';
	public var skin='default';
	public var behaviour:NoteBehaviour;
	public static var swagWidth:Float = 160 * 0.7;
	public var quantTexture:Int = 4;

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

	public function new(strumTime:Float=0,?modifier='base',?skin='default', behaviour:NoteBehaviour) // TODO: NoteType
	{
		super();

		var beat = Conductor.getBeat(strumTime);
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
				loadGraphic(Paths.noteSkinImage(behaviour.arguments.note.sheet, 'skins', skin, modifier),true,behaviour.arguments.note.gridSizeX,behaviour.arguments.note.gridSizeY);

				if(behaviour.arguments.note.quant){
					animation.add('greenScroll', [behaviour.arguments.note.up+4*quantToGrid.get(quantTexture)]);
					animation.add('redScroll', [behaviour.arguments.note.right+4*quantToGrid.get(quantTexture)]);
					animation.add('blueScroll', [behaviour.arguments.note.down+4*quantToGrid.get(quantTexture)]);
					animation.add('purpleScroll', [behaviour.arguments.note.left+4*quantToGrid.get(quantTexture)]);
				}else{
					animation.add('greenScroll', behaviour.arguments.note.up );
					animation.add('redScroll', behaviour.arguments.note.right);
					animation.add('blueScroll', behaviour.arguments.note.down);
					animation.add('purpleScroll', behaviour.arguments.note.left);
				}


				setGraphicSize(Std.int(width * behaviour.scale));
				updateHitbox();
				antialiasing = behaviour.antialiasing;

			default:
				frames = Paths.noteSkinAtlas(behaviour.arguments.spritesheet, 'skins', skin, modifier);

				animation.addByPrefix('greenScroll', behaviour.arguments.upPrefix);
				animation.addByPrefix('redScroll', behaviour.arguments.rightPrefix);
				animation.addByPrefix('blueScroll', behaviour.arguments.downPrefix);
				animation.addByPrefix('purpleScroll', behaviour.arguments.leftPrefix);

				animation.addByPrefix('greenhold', behaviour.arguments.upLongPrefix);
				animation.addByPrefix('redhold', behaviour.arguments.rightLongPrefix);
				animation.addByPrefix('bluehold', behaviour.arguments.downLongPrefix);
				animation.addByPrefix('purplehold', behaviour.arguments.leftLongPrefix);

				animation.addByPrefix('greenholdend', behaviour.arguments.upLongEndPrefix);
				animation.addByPrefix('redholdend', behaviour.arguments.rightLongEndPrefix);
				animation.addByPrefix('blueholdend', behaviour.arguments.downLongEndPrefix);
				animation.addByPrefix('purpleholdend', behaviour.arguments.leftLongEndPrefix);

				setGraphicSize(Std.int(width * behaviour.scale));
				updateHitbox();
				antialiasing = behaviour.antialiasing;
		}
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
			if(end && !animation.curAnim.name.endsWith("end")){
				var args = behaviour.arguments.sustainEnd;

				loadGraphic(Paths.noteSkinImage(args.sheet, 'skins', skin, modifier),true,args.gridSizeX,args.gridSizeY);
				// TODO: quantsz
				if(args.quant){
					animation.add('purpleholdend', [quantToGrid.get(quantTexture)+9 ]);
					animation.add('greenholdend', [quantToGrid.get(quantTexture)+9 ]);
					animation.add('redholdend', [quantToGrid.get(quantTexture)+9 ]);
					animation.add('blueholdend', [quantToGrid.get(quantTexture)+9 ]);
				}else{
					animation.add('purpleholdend', args.left);
					animation.add('greenholdend', args.up);
					animation.add('redholdend', args.right);
					animation.add('blueholdend', args.down);
				}

				setGraphicSize(Std.int(width * behaviour.scale));
				updateHitbox();
			}else if(!end){
				var args = behaviour.arguments.sustain;

				loadGraphic(Paths.noteSkinImage(args.sheet, 'skins', skin, modifier),true,args.gridSizeX,args.gridSizeY);
				// TODO: quants
				if(args.quant){
					animation.add('purplehold', [quantToGrid.get(quantTexture) ]);
					animation.add('greenhold', [quantToGrid.get(quantTexture) ]);
					animation.add('redhold', [quantToGrid.get(quantTexture) ]);
					animation.add('bluehold', [quantToGrid.get(quantTexture) ]);
				}else{
					animation.add('purplehold', args.left);
					animation.add('greenhold', args.up);
					animation.add('redhold', args.right);
					animation.add('bluehold', args.down);
				}
				setGraphicSize(Std.int(width * behaviour.scale));
				updateHitbox();
			}
		}else if(behaviour.actsLike=='pixel' && !sussy){
			loadGraphic(Paths.noteSkinImage(behaviour.arguments.note.sheet, 'skins', skin, modifier),true,behaviour.arguments.note.gridSizeX,behaviour.arguments.note.gridSizeY);

			if(behaviour.arguments.note.quant){
				animation.add('greenScroll', [behaviour.arguments.note.up + 4*quantToGrid.get(quantTexture) ]);
				animation.add('redScroll', [behaviour.arguments.note.right + 4*quantToGrid.get(quantTexture) ]);
				animation.add('blueScroll', [behaviour.arguments.note.down + 4*quantToGrid.get(quantTexture) ]);
				animation.add('purpleScroll', [behaviour.arguments.note.left + 4*quantToGrid.get(quantTexture) ]);
			}else{
				animation.add('greenScroll', behaviour.arguments.note.up);
				animation.add('redScroll', behaviour.arguments.note.right);
				animation.add('blueScroll', behaviour.arguments.note.down);
				animation.add('purpleScroll', behaviour.arguments.note.left);
			}

			setGraphicSize(Std.int(width * behaviour.scale));
			updateHitbox();
		}
		if(colors[dir]!=null){
			animation.play('${colors[dir]}${suffix}',true);
		}
	}
}
