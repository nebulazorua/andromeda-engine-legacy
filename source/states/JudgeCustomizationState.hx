package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import Options;
import ui.*;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class JudgeCustomizationState extends MusicBeatState {
  var stage:Stage;
  var judge:FlxSprite;
  var judgePlacementPos:FlxPoint;
  var defaultPos:FlxPoint;
  var draggingJudge:Bool=false;
  override function destroy(){
    defaultPos.put();
    judgePlacementPos.put();
    return super.destroy();
  }

  override function create(){
    super.create();
    FlxG.mouse.visible=true;

    defaultPos = FlxPoint.get();
    judgePlacementPos = FlxPoint.get(EngineData.options.judgeX,EngineData.options.judgeY);
    stage = new Stage('stage',EngineData.options);
    add(stage);

    add(stage.layers.get("gf"));
    add(stage.layers.get("dad"));
    add(stage.layers.get("boyfriend"));
    add(stage.foreground);

    add(stage.overlay);

    var coolText:FlxText = new FlxText(0, 0, 0, '100', 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;

    judge = new FlxSprite();
		judge.loadGraphic(Paths.image('sick','shared'));
    judge.screenCenter();
    judge.antialiasing=true;
    judge.x = coolText.x - 40;
    judge.y -= 60;
    judge.setGraphicSize(Std.int(judge.width * 0.7));
    judge.updateHitbox();

    if(EngineData.options.ratingInHUD){
      coolText.scrollFactor.set(0,0);
      judge.scrollFactor.set(0,0);

      judge.screenCenter();
      coolText.screenCenter();
      judge.y -= 25;
    }

    FlxG.camera.focusOn(judge.getPosition());

		add(judge);
    defaultPos.set(judge.x,judge.y);
    judge.x += EngineData.options.judgeX;
    judge.y += EngineData.options.judgeY;

    var title:FlxText = new FlxText(0, 20, 0, "Judgement Movement", 32);
    title.scrollFactor.set(0,0);
    title.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    title.screenCenter(X);
    add(title);

    var instructions:FlxText = new FlxText(0, 60, 0, "Click and drag the judgement around to move it\nPress R to place the judgement in its default position\nPress C to show the combo\nPress Enter to exit and save\nPress Escape to exit without saving", 24);
    instructions.scrollFactor.set(0,0);
    instructions.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    instructions.screenCenter(X);
    add(instructions);


  }

  var prevComboNums:Array<String> = [];
  var comboSprites:Array<FlxSprite> = [];

  private function showCombo (combo:Int=100){
    var seperatedScore:Array<String> = Std.string(combo).split("");

    // WHY DOES HAXE NOT HAVE A DECREMENTING FOR LOOP
    // WHAT THE FUCK
    while(comboSprites.length>0){
      comboSprites[0].kill();
      comboSprites.remove(comboSprites[0]);
    }
    var placement:String = Std.string(combo);
    var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		if(EngineData.options.ratingInHUD){
			coolText.scrollFactor.set(0,0);
			coolText.screenCenter();
		}

    var daLoop:Float = 0;
    var idx:Int = -1;
    for (i in seperatedScore)
    {
      idx++;
      if(i=='-'){
        i='Negative';
      }
      var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('num' + i));
      numScore.screenCenter(XY);
      numScore.x = coolText.x + (43 * daLoop) - 90;
      numScore.y += 25;

      numScore.antialiasing = true;
      numScore.setGraphicSize(Std.int(numScore.width * 0.5));
      numScore.updateHitbox();

      if(EngineData.options.ratingInHUD){
        numScore.scrollFactor.set(0,0);
        numScore.y += 50;
        numScore.x -= 50;
      }

      numScore.x += judgePlacementPos.x;
      numScore.y += judgePlacementPos.y;

      add(numScore);
      FlxTween.tween(numScore, {alpha: 0}, 0.2, {
        onComplete: function(tween:FlxTween)
        {
          numScore.destroy();
        },
        startDelay: Conductor.calculateCrochet(100) * 0.002
      });
      numScore.acceleration.y = FlxG.random.int(200, 300);
      numScore.velocity.y -= FlxG.random.int(140, 160);
      numScore.velocity.x = FlxG.random.float(-5, 5);


      daLoop++;
    }

    prevComboNums = seperatedScore;

  }

  var mouseX:Float;
  var mouseY:Float;
  override function update(elapsed){
    var deltaX = mouseX-FlxG.mouse.screenX;
    var deltaY = mouseY-FlxG.mouse.screenY;
    mouseX = FlxG.mouse.screenX;
    mouseY = FlxG.mouse.screenY;
    if(FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.ENTER){
      if(FlxG.keys.justPressed.ENTER){
        EngineData.options.judgeX = judgePlacementPos.x;
        EngineData.options.judgeY = judgePlacementPos.y;
        OptionUtils.saveOptions(OptionUtils.options);
      }
      FlxG.switchState(new OptionsState());
    }


    if(FlxG.mouse.overlaps(judge) && FlxG.mouse.justPressed){
      draggingJudge=true;
    }

    if(FlxG.mouse.justReleased){
      draggingJudge=false;
    }

    if(FlxG.keys.justPressed.R){
      judgePlacementPos.set(0,0);
    }

    judge.x = defaultPos.x + judgePlacementPos.x;
    judge.y = defaultPos.y + judgePlacementPos.y;

    if(FlxG.keys.justPressed.C){
      showCombo();
    }

    if(draggingJudge){
      if(FlxG.mouse.pressed){
        judgePlacementPos.x -= deltaX;
  			judgePlacementPos.y -= deltaY;
      }else{
        draggingJudge=false;
      }
    }


    super.update(elapsed);
  }
}
