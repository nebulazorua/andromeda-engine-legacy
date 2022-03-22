package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxTimer;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.FlxObject;
import flixel.FlxBasic;
import states.*;
import Options;
import Shaders;

class Stage extends FlxTypedGroup<FlxBasic> {
  public static var songStageMap:Map<String,String> = [
    "pico"=>"philly",
    "philly-nice"=>"philly",
    "blammed"=>"philly",
    "spookeez"=>"spooky",
    "south"=>"spooky",
    "monster"=>"spooky",
    "satin-panties"=>"limo",
    "high"=>"limo",
    "milf"=>"limo",
    "eggnog"=>"mall",
    "cocoa"=>"mall",
    "winter-horrorland"=>"mallEvil",
    "senpai"=>"school",
    "roses"=>"school",
    "thorns"=>"schoolEvil",
    "bopeebo"=>"stage",
    "fresh"=>"stage",
    "dadbattle"=>"stage",
    "tutorial"=>"stage",
  ];

  public static var stageNames:Array<String> = [
    "stage",
    "spooky",
    "philly",
    "limo",
    "mall",
    "mallEvil",
    "school",
    "schoolEvil",
    "blank"
  ];

  public var doDistractions:Bool = true;

  // spooky bg
  public var halloweenBG:FlxSprite;
  var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;


  // philly bg
  public var lightFadeShader:BuildingEffect;
  public var phillyCityLights:FlxTypedGroup<FlxSprite>;
  public var phillyTrain:FlxSprite;
  public var trainSound:FlxSound;
  public var curLight:Int = 0;

  public var trainMoving:Bool = false;
	public var trainFrameTiming:Float = 0;

	public var trainCars:Int = 8;
	public var trainFinishing:Bool = false;
	public var trainCooldown:Int = 0;

  // limo bg
  public var fastCar:FlxSprite;
  public var limo:FlxSprite;
  var fastCarCanDrive:Bool=true;

  // misc, general bg stuff

  public var bfPosition:FlxPoint = FlxPoint.get(770,450);
  public var dadPosition:FlxPoint = FlxPoint.get(100,100);
  public var gfPosition:FlxPoint = FlxPoint.get(400,130);
  public var camPos:FlxPoint = FlxPoint.get(100,100);
  public var camOffset:FlxPoint = FlxPoint.get(100,100);

  public var layers:Map<String,FlxTypedGroup<FlxBasic>> = [
    "boyfriend"=>new FlxTypedGroup<FlxBasic>(), // stuff that should be layered infront of all characters, but below the foreground
    "dad"=>new FlxTypedGroup<FlxBasic>(), // stuff that should be layered infront of the dad and gf but below boyfriend and foreground
    "gf"=>new FlxTypedGroup<FlxBasic>(), // stuff that should be layered infront of the gf but below the other characters and foreground
  ];
  public var foreground:FlxTypedGroup<FlxBasic> = new FlxTypedGroup<FlxBasic>(); // stuff layered above every other layer
  public var overlay:FlxSpriteGroup = new FlxSpriteGroup(); // stuff that goes into the HUD camera. Layered before UI elements, still

  public var boppers:Array<Array<Dynamic>> = []; // should contain [sprite, bopAnimName, whichBeats]
  public var dancers:Array<Dynamic> = []; // Calls the 'dance' function on everything in this array every beat

  public var defaultCamZoom:Float = 1.05;

  public var curStage:String = '';

  // other vars
  public var gfVersion:String = 'gf';
  public var gf:Character;
  public var boyfriend:Character;
  public var dad:Character;
  public var currentOptions:Options;
  public var centerX:Float = -1;
  public var centerY:Float = -1;

  override public function destroy(){
    bfPosition = FlxDestroyUtil.put(bfPosition);
    dadPosition = FlxDestroyUtil.put(dadPosition);
    gfPosition = FlxDestroyUtil.put(gfPosition);
    camOffset =  FlxDestroyUtil.put(camOffset);

    super.destroy();
  }

  function lightningStrikeShit():Void
  {
    FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
    halloweenBG.animation.play('lightning');

    lightningOffset = FlxG.random.int(8, 24);

    boyfriend.noIdleTimer = 1000;
    gf.noIdleTimer = 1000;
    boyfriend.playAnim('scared', true);
    gf.playAnim('scared', true);
  }

  function resetFastCar():Void
  {
    fastCar.x = -12600;
    fastCar.y = FlxG.random.int(140, 250);
    fastCar.velocity.x = 0;
    fastCarCanDrive = true;
  }

  function fastCarDrive()
  {
    FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

    fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
    fastCarCanDrive = false;
    new FlxTimer().start(2, function(tmr:FlxTimer)
    {
      resetFastCar();
    });
  }



  public function setPlayerPositions(?p1:Character,?p2:Character,?gf:Character){

    if(p1!=null)p1.setPosition(bfPosition.x,bfPosition.y);
    if(gf!=null)gf.setPosition(gfPosition.x,gfPosition.y);
    if(p2!=null){
      p2.setPosition(dadPosition.x,dadPosition.y);
      camPos.set(p2.getGraphicMidpoint().x, p2.getGraphicMidpoint().y);
    }

    if(p1!=null){
      switch(p1.curCharacter){

      }
    }

    if(p2!=null){

      switch(p2.curCharacter){
        case 'gf':
          if(gf!=null){
            p2.setPosition(gf.x, gf.y);
            gf.visible = false;
          }
        case 'dad':
          camPos.x += 400;
        case 'pico':
          camPos.x += 600;
        case 'senpai' | 'senpai-angry':
          camPos.set(p2.getGraphicMidpoint().x + 300, p2.getGraphicMidpoint().y);
        case 'spirit':
          camPos.set(p2.getGraphicMidpoint().x + 300, p2.getGraphicMidpoint().y);
        case 'bf-pixel':
          camPos.set(p2.getGraphicMidpoint().x, p2.getGraphicMidpoint().y);
      }
    }

    if(p1!=null){
      p1.x += p1.posOffset.x;
      p1.y += p1.posOffset.y;
    }
    if(p2!=null){
      p2.x += p2.posOffset.x;
      p2.y += p2.posOffset.y;
    }


  }

  public function new(stage:String,currentOptions:Options){
    super();
    if(stage=='halloween')stage='spooky'; // for kade engine shenanigans
    curStage=stage;
    this.currentOptions=currentOptions;

    overlay.scrollFactor.set(0,0); // so the "overlay" layer stays static

    switch (stage){
      case 'philly':
        var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky','week3'));
        bg.scrollFactor.set(0.1, 0.1);
        add(bg);

        var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city','week3'));
        city.scrollFactor.set(0.3, 0.3);
        city.setGraphicSize(Std.int(city.width * 0.85));
        city.updateHitbox();
        add(city);
        lightFadeShader = new BuildingEffect();

        //modchart.addCamEffect(rainShader);

        phillyCityLights = new FlxTypedGroup<FlxSprite>();
        add(phillyCityLights);

        for (i in 0...5)
        {
                var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i,'week3'));
                light.scrollFactor.set(0.3, 0.3);
                light.visible = false;
                light.setGraphicSize(Std.int(light.width * 0.85));
                light.updateHitbox();
                light.antialiasing = true;
                light.shader=lightFadeShader.shader;
                phillyCityLights.add(light);
        }

        var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain','week3'));
        add(streetBehind);

        phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train','week3'));
        add(phillyTrain);

        trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
        FlxG.sound.list.add(trainSound);

        // var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

        var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street','week3'));
        add(street);

        centerX = city.getMidpoint().x;
        centerY = city.getMidpoint().y;
      case 'spooky':
        var hallowTex = Paths.getSparrowAtlas('halloween_bg','week2');

        halloweenBG = new FlxSprite(-200, -100);
        halloweenBG.frames = hallowTex;
        halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
        halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
        halloweenBG.animation.play('idle');
        halloweenBG.antialiasing = true;
        add(halloweenBG);

        centerX = halloweenBG.getMidpoint().x;
        centerY = halloweenBG.getMidpoint().y;

      case 'school':
          gfVersion = 'gf-pixel';
          camOffset.x = 200;
          camOffset.y = 200;

          bfPosition.x += 200;
          bfPosition.y += 220;
          gfPosition.x += 180;
          gfPosition.y += 300;

          var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky','week6'));
          bgSky.scrollFactor.set(0.1, 0.1);
          add(bgSky);

          var repositionShit = -200;

          var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool','week6'));
          bgSchool.scrollFactor.set(0.6, 0.90);
          add(bgSchool);

          var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet','week6'));
          bgStreet.scrollFactor.set(0.95, 0.95);
          add(bgStreet);

          var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack','week6'));
          fgTrees.scrollFactor.set(0.9, 0.9);
          add(fgTrees);

          var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
          var treetex = Paths.getPackerAtlas('weeb/weebTrees','week6');
          bgTrees.frames = treetex;
          bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
          bgTrees.animation.play('treeLoop');
          bgTrees.scrollFactor.set(0.85, 0.85);
          add(bgTrees);

          var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
          treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals','week6');
          treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
          treeLeaves.animation.play('leaves');
          treeLeaves.scrollFactor.set(0.85, 0.85);
          add(treeLeaves);

          var widShit = Std.int(bgSky.width * 6);

          bgSky.setGraphicSize(widShit);
          bgSchool.setGraphicSize(widShit);
          bgStreet.setGraphicSize(widShit);
          bgTrees.setGraphicSize(Std.int(widShit * 1.4));
          fgTrees.setGraphicSize(Std.int(widShit * 0.8));
          treeLeaves.setGraphicSize(widShit);

          fgTrees.updateHitbox();
          bgSky.updateHitbox();
          bgSchool.updateHitbox();
          bgStreet.updateHitbox();
          bgTrees.updateHitbox();
          treeLeaves.updateHitbox();

          centerX = bgSchool.getMidpoint().x;
          centerY = bgSchool.getMidpoint().y;

          //centerX = 580;
          //centerY = 380;

          var bgGirls = new BackgroundGirls(-100, 190);
          bgGirls.scrollFactor.set(0.9, 0.9);

          if(PlayState.SONG.song.toLowerCase() == 'roses'){
            bgGirls.getScared();
          }

          bgGirls.setGraphicSize(Std.int(bgGirls.width * PlayState.daPixelZoom));
          bgGirls.updateHitbox();
          add(bgGirls);
          dancers.push(bgGirls);
      case 'schoolEvil':
        gfVersion = 'gf-pixel';
        camOffset.x = 200;
        camOffset.y = 200;

        bfPosition.x += 200;
        bfPosition.y += 220;
        gfPosition.x += 180;
        gfPosition.y += 300;

        var posX = 400;
        var posY = 200;

        var bg:FlxSprite = new FlxSprite(posX, posY);
        bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool','week6');
        bg.animation.addByPrefix('idle', 'background 2', 24);
        bg.animation.play('idle');
        bg.scrollFactor.set(0.8, 0.9);
        bg.scale.set(6, 6);
        add(bg);

        centerX = bg.getMidpoint().x;
        centerY = bg.getMidpoint().y;
      case 'mall':
        gfVersion = 'gf-christmas';
        camOffset.x = 200;
        defaultCamZoom = 0.80;
        bfPosition.x += 200;

        var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls','week5'));
        bg.antialiasing = true;
        bg.scrollFactor.set(0.2, 0.2);
        bg.active = false;
        bg.setGraphicSize(Std.int(bg.width * 0.8));
        bg.updateHitbox();
        add(bg);

        var upperBoppers = new FlxSprite(-240, -90);
        upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop','week5');
        upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
        upperBoppers.antialiasing = true;
        upperBoppers.scrollFactor.set(0.33, 0.33);
        upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
        upperBoppers.updateHitbox();
        add(upperBoppers);
        boppers.push([upperBoppers,"bop",1]);

        var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator','week5'));
        bgEscalator.antialiasing = true;
        bgEscalator.scrollFactor.set(0.3, 0.3);
        bgEscalator.active = false;
        bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
        bgEscalator.updateHitbox();
        add(bgEscalator);

        var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree','week5'));
        tree.antialiasing = true;
        tree.scrollFactor.set(0.40, 0.40);
        add(tree);

        var bottomBoppers = new FlxSprite(-300, 140);
        bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop','week5');
        bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
        bottomBoppers.antialiasing = true;
        bottomBoppers.scrollFactor.set(0.9, 0.9);
        bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
        bottomBoppers.updateHitbox();
        add(bottomBoppers);
        boppers.push([bottomBoppers,"bop",1]);

        var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow','week5'));
        fgSnow.active = false;
        fgSnow.antialiasing = true;
        add(fgSnow);

        var santa = new FlxSprite(-840, 150);
        santa.frames = Paths.getSparrowAtlas('christmas/santa','week5');
        santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
        santa.antialiasing = true;
        add(santa);
        boppers.push([santa,"idle",1]);

        centerX = bg.getMidpoint().x;
        centerY = bg.getMidpoint().y;
      case 'mallEvil':
        gfVersion = 'gf-christmas';

        bfPosition.x += 320;
        dadPosition.y -= 80;
        var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG','week5'));
        bg.antialiasing = true;
        bg.scrollFactor.set(0.2, 0.2);
        bg.active = false;
        bg.setGraphicSize(Std.int(bg.width * 0.8));
        bg.updateHitbox();
        add(bg);

        var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree','week5'));
        evilTree.antialiasing = true;
        evilTree.scrollFactor.set(0.2, 0.2);
        add(evilTree);

        var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow",'week5'));
        evilSnow.antialiasing = true;
        add(evilSnow);

        centerX = bg.getMidpoint().x;
        centerY = bg.getMidpoint().y+200;
      case 'limo':
        gfVersion = 'gf-car';
        camOffset.x = 300;

        bfPosition.y -= 220;
        bfPosition.x += 260;

        defaultCamZoom = 0.90;

        var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset','week4'));
        skyBG.scrollFactor.set(0.1, 0.1);
        add(skyBG);

        var bgLimo:FlxSprite = new FlxSprite(-200, 480);
        bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo','week4');
        bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
        bgLimo.animation.play('drive');
        bgLimo.scrollFactor.set(0.4, 0.4);
        add(bgLimo);
        for (i in 0...5)
        {
                var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
                dancer.scrollFactor.set(0.4, 0.4);
                dancers.push(dancer);
                add(dancer);
        }

        var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay','week4'));
        overlayShit.alpha = 0.5;
        // add(overlayShit);

        // var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

        // FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

        // overlayShit.shader = shaderBullshit;

        var limoTex = Paths.getSparrowAtlas('limo/limoDrive','week4');

        limo = new FlxSprite(-120, 550);
        limo.frames = limoTex;
        limo.animation.addByPrefix('drive', "Limo stage", 24);
        limo.animation.play('drive');
        limo.antialiasing = true;
        layers.get("gf").add(limo);

        fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol','week4'));
        add(fastCar);
        resetFastCar();

        centerX = skyBG.getMidpoint().x+100;
        centerY = skyBG.getMidpoint().y-100;
      case 'blank':

      default:
        defaultCamZoom = 1;
        curStage = 'stage';
        var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback','shared'));
        bg.antialiasing = true;
        bg.scrollFactor.set(0.9, 0.9);
        bg.active = false;
        add(bg);

        var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront','shared'));
        stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
        stageFront.updateHitbox();
        stageFront.antialiasing = true;
        stageFront.scrollFactor.set(0.9, 0.9);
        stageFront.active = false;
        add(stageFront);

        var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains','shared'));
        stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
        stageCurtains.updateHitbox();
        stageCurtains.antialiasing = true;
        stageCurtains.scrollFactor.set(1.3, 1.3);
        stageCurtains.active = false;

        centerX = bg.getMidpoint().x;
        centerY = bg.getMidpoint().y;

        foreground.add(stageCurtains);
      }
  }


  public function beatHit(beat){
    for(b in boppers){
      if(beat%b[2]==0){
        b[0].animation.play(b[1],true);
      }
    }
    for(d in dancers){
      d.dance();
    }

    if(doDistractions){

      switch(curStage){
        case 'limo':
          if (FlxG.random.bool(10) && fastCarCanDrive)
            fastCarDrive();
        case 'spooky':
          if (FlxG.random.bool(10) && beat > lightningStrikeBeat + lightningOffset)
          {
            lightningStrikeBeat = beat;
            lightningStrikeShit();
          }
        case 'philly':
          if (!trainMoving)
            trainCooldown += 1;

          if (beat%4== 0)
          {
            phillyCityLights.forEach(function(light:FlxSprite)
            {
              light.visible = false;
            });

            curLight = FlxG.random.int(0, phillyCityLights.length - 1);

            phillyCityLights.members[curLight].visible = true;
            phillyCityLights.members[curLight].alpha = 1;
            lightFadeShader.setAlpha(0);
          }

          if (beat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
          {
            trainCooldown = FlxG.random.int(-4, 0);
            trainStart();
          }
      }
    }
  }

  override function update(elapsed:Float){
    switch(curStage){
      case 'philly':
        if (trainMoving)
        {
          trainFrameTiming += elapsed;

          if (trainFrameTiming >= 1 / 24)
          {
            updateTrainPos();
            trainFrameTiming = 0;
          }
        }
        lightFadeShader.addAlpha((Conductor.crochet / 1000) * FlxG.elapsed * 1.5);
    }


    super.update(elapsed);
  }

  function trainStart():Void
  {
    trainMoving = true;
    trainSound.play(true,0);
  }

  var startedMoving:Bool = false;

  function updateTrainPos():Void
  {
    if (trainSound.time >= 4700)
    {
      startedMoving = true;
      gf.playAnim('hairBlow');
    }

    if (startedMoving)
    {
      if(currentOptions.picoCamshake)
        PlayState.currentPState.camGame.shake(.0025,.1,null,true,X);

      phillyTrain.x -= 400;

      if (phillyTrain.x < -2000 && !trainFinishing)
      {
        phillyTrain.x = -1150;
        trainCars -= 1;

        if (trainCars <= 0)
          trainFinishing = true;
      }

      if (phillyTrain.x < -4000 && trainFinishing)
        trainReset();
    }
  }

  function trainReset():Void
  {
    gf.playAnim('hairFall');
    phillyTrain.x = FlxG.width + 200;
    trainMoving = false;
    // trainSound.stop();
    // trainSound.time = 0;
    trainCars = 8;
    trainFinishing = false;
    startedMoving = false;
  }

  override function add(obj:FlxBasic){
    if(OptionUtils.options.antialiasing==false){
      if((obj is FlxSprite)){
        var sprite:FlxSprite = cast obj;
        sprite.antialiasing=false;
      }else if((obj is FlxTypedGroup)){
        var group:FlxTypedGroup<FlxSprite> = cast obj;
        for(o in group.members){
          if((o is FlxSprite)){
            var sprite:FlxSprite = cast o;
            sprite.antialiasing=false;
          }
        }
      }
    }
    return super.add(obj);
  }

}
