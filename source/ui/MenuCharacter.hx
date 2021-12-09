package ui;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

typedef MenuCharData = {
	var name:String;
	var xOffset:Int;
	var yOffset:Int;
	var scale:Float;
	var fps:Int;
	var flipped:Bool;
	var looped:Bool;
}

class MenuCharacter extends FlxSprite
{
	public var character:String;
	public var baseX:Float = 0;
	public var baseY:Float = 0;

	private static var settings:Map<String,MenuCharData> = [
		'bf'=>{name:"BF idle dance white",xOffset:0, yOffset:-20, scale:0.9, fps: 24, flipped: false, looped: true},
		'bfConfirm'=>{name:"BF HEY!!",xOffset:0, yOffset:0, scale:0.9, fps: 24, flipped: false,  looped: false},
		'gf'=>{name:"GF Dancing Beat WHITE",xOffset:50, yOffset:0, scale:1, fps: 24, flipped: false, looped: true  },
		'dad'=>{name:"Dad idle dance BLACK LINE",xOffset:0, yOffset:0, scale:.5, fps: 24, flipped: false, looped: true  },
		'spooky'=>{name:"spooky dance idle BLACK LINES",xOffset:0, yOffset:90, scale:.5, fps: 24, flipped: false, looped: true  },
		'pico'=>{name:"Pico Idle Dance",xOffset:0, yOffset:100, scale:.5, fps: 24, flipped: true, looped: true  },
		'mom'=>{name:"Mom Idle BLACK LINES",xOffset:0, yOffset:-20, scale:.5, fps: 24, flipped: false, looped: true  },
		'parents-christmas'=>{name:"Parent Christmas Idle",xOffset:-100, yOffset:50, scale:.8, fps: 24, flipped: false, looped: true  },
		'senpai'=>{name:"SENPAI idle Black Lines",xOffset:-50, yOffset:100, scale:.7, fps: 24, flipped: false, looped: true  },
	];

	public function setCharacter(char:String){
		if(char!=character){
			if(settings.exists(char)){
				frames = Paths.getSparrowAtlas('campaign_menu_UI_characters');
				var shit = settings.get(char);
				animation.addByPrefix(char, shit.name, shit.fps, shit.looped);
				animation.play(char,true);

				visible=true;

				setGraphicSize(Std.int(width*shit.scale));
				setPosition(baseX+shit.xOffset,baseY+shit.yOffset);

				updateHitbox();

				flipX = shit.flipped;
				character=char;
			}else{
				character='none';
				visible=false;
			}
		}
	}

	public function new(x:Float, character:String = 'bf')
	{
		super(x);
		y+=70;
		baseX = x;
		baseY = y;

		//animation.addByPrefix(char, shit.name, shit.fps, shit.looped);


		// Parent Christmas Idle

		setCharacter(character);
		updateHitbox();
	}
}
