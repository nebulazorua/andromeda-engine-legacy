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
import flixel.math.FlxMath;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxInputText;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import flixel.ui.FlxButton;
import openfl.net.FileReference;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import haxe.Json;
import flixel.addons.ui.FlxUIState;
using StringTools;

class CharacterEditorState extends MusicBeatState {
  var previousState:FlxUIState;
  var stage:Stage;
  var dad:Character;
  var boyfriend:Boyfriend;
  var layering:FlxTypedGroup<FlxSprite>;
  var camFollow:FlxObject;
  var char:String='bf';
  var camOffset:FlxObject;
  var zoomOffset:Float = 0;
  var curCharacter:Character;
  var ghost:Character;
  var camHUD:FlxCamera;
  var camGame:FlxCamera;
  var zoom:Float = 1;

  var animNames:Array<String> = [];
  var ghostAnims:Array<String> = [];
  var animData:Map<String,Character.AnimShit> = [];
  var healthBar:Healthbar;

  // char ui
  var idleCheckbox:Checkbox;
  var playerCheckbox:Checkbox;
  var flipCheckbox:Checkbox;
  var antialiasingCheckbox:Checkbox;
  var scaleBox:Inputbox;
  var singDurBox:Inputbox;
  var sheetBox:Inputbox;
  var charXBox:Inputbox;
  var charYBox:Inputbox;
  var camXBox:Inputbox;
  var camYBox:Inputbox;
  var saveButton:FlxButton;
  var charDropdown:FlxUIDropDownMenu;
  // hp ui
  var iconBox:Inputbox;
  var hpBox:Inputbox;
  var redBox:Inputbox;
  var greenBox:Inputbox;
  var blueBox:Inputbox;

  // anim ui
  var nameBox:Inputbox;
  var prefixBox:Inputbox;
  var fpsBox:Inputbox;
  var loopCheckbox:Checkbox;
  var offsetXBox:Inputbox;
  var offsetYBox:Inputbox;
  var indiceBox:Inputbox;
  var addAnimButton:FlxButton;
  var delAnimButton:FlxButton;
  var animDropdown:FlxUIDropDownMenu;
  var ghostDropdown:FlxUIDropDownMenu;

  // groups
  var charUI:UIGroup;
  var healthUI:UIGroup;
  var animUI:UIGroup;

  var _file:FileReference;

  private function save(data:String,name:String)
  {
    if ((data != null) && (data.length > 0))
    {
      _file = new FileReference();
      _file.addEventListener(Event.COMPLETE, onSaveComplete);
      _file.addEventListener(Event.CANCEL, onSaveCancel);
      _file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
      _file.save(data.trim(), name);
    }
  }

  function onSaveComplete(_):Void
  {
    _file.removeEventListener(Event.COMPLETE, onSaveComplete);
    _file.removeEventListener(Event.CANCEL, onSaveCancel);
    _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
    _file = null;
    FlxG.log.notice("Successfully saved LEVEL DATA.");
    refreshCharList();
  }

  function onSaveCancel(_):Void
  {
    _file.removeEventListener(Event.COMPLETE, onSaveComplete);
    _file.removeEventListener(Event.CANCEL, onSaveCancel);
    _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
    _file = null;
    refreshCharList();
  }

  function onSaveError(_):Void
  {
    _file.removeEventListener(Event.COMPLETE, onSaveComplete);
    _file.removeEventListener(Event.CANCEL, onSaveCancel);
    _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
    _file = null;
    FlxG.log.error("Problem saving Level data");
    refreshCharList();
  }

  function showCharacter(resetVars:Bool=true){

    remove(stage.layers.get("gf"));
    remove(dad);
    remove(stage.layers.get("dad"));
    remove(boyfriend);
    remove(stage.layers.get("boyfriend"));
    remove(stage.foreground);
    remove(stage.overlay);

    if(curCharacter!=null)curCharacter.kill();

    if(!playerCheckbox.state){
      dad = new Character(100,100,char);
      curCharacter=dad;
    }else{
      boyfriend = new Boyfriend(100,100,char);
      curCharacter=boyfriend;
    }
    if(resetVars){
      idleCheckbox.changeState(curCharacter.beatDancer,false);
  		flipCheckbox.changeState(curCharacter.charData.flipX,false);
      if(curCharacter.charData.antialiasing==null){
        antialiasingCheckbox.changeState(true,false);
      }else{
        antialiasingCheckbox.changeState(curCharacter.charData.antialiasing,false);
      }

      if(curCharacter.charData.scale!=null){
        scaleBox.text = Std.string(curCharacter.charData.scale);
      }else{
        scaleBox.text = '1';
      }
      singDurBox.text = Std.string(curCharacter.dadVar);
      sheetBox.text = curCharacter.charData.spritesheet;
      charXBox.text = Std.string(curCharacter.posOffset.x);
      charYBox.text = Std.string(curCharacter.posOffset.y);
      camXBox.text = Std.string(curCharacter.camOffset.x);
      camYBox.text = Std.string(curCharacter.camOffset.y);
      iconBox.text = Std.string(curCharacter.iconName);
      hpBox.text = curCharacter.iconColor.toWebString();
      redBox.text = Std.string(curCharacter.iconColor.red);
      greenBox.text = Std.string(curCharacter.iconColor.green);
      blueBox.text = Std.string(curCharacter.iconColor.blue);
    }else{
      for(shit in layering.members){
        if((shit is UIGroup)){
          var shit:UIGroup = cast shit;
          for(cum in shit.members){
            if((cum is Inputbox)){
              var cum:Inputbox = cast cum;
              cum.callback(cum.text,'enter');
            }else if((cum is Checkbox)){
              var cum:Checkbox = cast cum;
              cum.callback(cum.state);
            }
          }
        }
      }
    }
    refreshHP();
    if(ghost!=null){
      ghost.kill();
    }

    ghost = new Character(100,100,char,playerCheckbox.state);
    ghost.alpha = 0.5;
    ghost.debugMode=true;
    curCharacter.debugMode=true;

    resetAnims();

    add(stage.layers.get("gf"));
    if(dad!=null){add(ghost);add(dad);};
		add(stage.layers.get("dad"));
		if(boyfriend!=null){add(ghost);add(boyfriend);};
		add(stage.layers.get("boyfriend"));
		add(stage.foreground);

		add(stage.overlay);

    stage.setPlayerPositions(boyfriend,dad);
    ghost.x = curCharacter.x;
    ghost.y = curCharacter.y;
  }

  function updateGhost(){
    if(ghost!=null){
      for(prop in Reflect.fields(curCharacter.charData)){
        var val = Reflect.field(curCharacter.charData,prop);
        Reflect.setProperty(ghost.charData,prop,val);
      }
      ghost.setCharData();
      ghost.x = curCharacter.x;
      ghost.y = curCharacter.y;
    }
  }

  public function new(defaultChar:String='bf',?state:FlxUIState){
    if(state==null)state=new TitleState();
    previousState=state;
    char=defaultChar;
    super();
  }

  override function destroy(){
    super.destroy();
  }

  override function beatHit()
  {
    super.beatHit();
    stage.beatHit(curBeat);
    healthBar.beatHit(curBeat);


    if(curCharacter.animation.curAnim!=null)
      if (animDropdown.selectedId=='0' && nameBox.text=='' && prefixBox.text=='')
        curCharacter.dance();
  }

  override function create(){
    super.create();
    InitState.getCharacters();

    camHUD = new FlxCamera();
    camHUD.bgColor.alpha = 0;
    camGame = new FlxCamera();

    FlxG.mouse.visible=true;

    FlxG.cameras.add(camGame);
    FlxG.cameras.add(camHUD);
    FlxCamera.defaultCameras = [camGame];
    Conductor.changeBPM(160);
    FlxG.sound.playMusic(Paths.music('breakfast','shared'));
    stage = new Stage('stage',EngineData.options);
    add(stage);
    stage.doDistractions=false;

    healthBar = new Healthbar(0,FlxG.height*.9,'bf','bf');
    healthBar.value = 2;
		healthBar.scrollFactor.set();
		healthBar.screenCenter(X);

    camGame.zoom = stage.defaultCamZoom;
    zoom=camGame.zoom;
    camFollow = new FlxObject(stage.centerX,stage.centerY);
    camOffset = new FlxObject(0,0);
    add(camOffset);
    add(camFollow);
    camGame.follow(camFollow, LOCKON, Main.adjustFPS(.1));
    camGame.focusOn(camFollow.getPosition());

    layering = new FlxTypedGroup<FlxSprite>();

    charUI = new UIGroup();
    charUI.resize(370,520);
    charUI.scrollFactor.set(0,0);
    populateCharUI(charUI);

    healthUI = new UIGroup();
    healthUI.y = 522;
    healthUI.resize(246,195);
    healthUI.scrollFactor.set(0,0);
    populateHPUI(healthUI);

    animUI = new UIGroup();
    animUI.x = 835;
    animUI.y = 0;
    animUI.resize(435,340);
    populateAnimUI(animUI);

    showCharacter();
    add(layering);
    layering.cameras=[camHUD];
    layering.add(healthBar);
    layering.add(healthUI);
    layering.add(charUI);
    layering.add(animUI);

  }

  var pressedOffsetShit:Array<Float>=[0,0,0,0];

  override function update(elapsed:Float){
    Conductor.songPosition = FlxG.sound.music.time;
    var shitFocused:Bool = false;
    var boxes:Array<Inputbox> = [camXBox, camYBox, charXBox, charYBox, sheetBox, singDurBox, scaleBox, iconBox, nameBox, hpBox, redBox, blueBox, greenBox, offsetXBox, offsetYBox, indiceBox, prefixBox, fpsBox];
    for(shit in boxes){
      if(shit.hasFocus){
        shitFocused=true;
        break;
      }
    }
    var droppedDown:Bool = false;
    var dropdowns = [animDropdown,charDropdown,ghostDropdown];
    for(shit in dropdowns){
      if(shit.dropPanel.visible){
        droppedDown=true;
        break;
      }
    }
    canChangeVolume=!shitFocused;
    if(!shitFocused){
      if(FlxG.keys.justPressed.ESCAPE && !droppedDown){
        FlxG.sound.music.stop();
        Conductor.changeBPM(0);
        FlxG.switchState(previousState);
      }
      if (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L)
  		{
  			if (FlxG.keys.pressed.I)
  				camOffset.velocity.y = -180;
  			else if (FlxG.keys.pressed.K)
  				camOffset.velocity.y = 180;
  			else
  				camOffset.velocity.y = 0;

  			if (FlxG.keys.pressed.J)
  				camOffset.velocity.x = -180;
  			else if (FlxG.keys.pressed.L)
  				camOffset.velocity.x = 180;
  			else
  				camOffset.velocity.x = 0;
  		}
  		else
  		{
  			camOffset.velocity.set();
  		}

      if(FlxG.keys.justPressed.W){
        var id = Std.parseInt(animDropdown.selectedId)-1;
        if(id<0)id=animDropdown.list.length-1;
        if(id>=animDropdown.list.length)id=0;
        @:privateAccess
        animDropdown.onClickItem(id);
      }

      if(FlxG.keys.justPressed.S){
        var id = Std.parseInt(animDropdown.selectedId)+1;
        if(id<0)id=animDropdown.list.length-1;
        if(id>=animDropdown.list.length)id=0;
        @:privateAccess
        animDropdown.onClickItem(id);
      }

      var offsetKeys:Array<Bool> = [
        FlxG.keys.justPressed.LEFT,
        FlxG.keys.justPressed.DOWN,
        FlxG.keys.justPressed.UP,
        FlxG.keys.justPressed.RIGHT,
      ];

      var offsetHeld:Array<Bool> = [
        FlxG.keys.pressed.LEFT,
        FlxG.keys.pressed.DOWN,
        FlxG.keys.pressed.UP,
        FlxG.keys.pressed.RIGHT,
      ];

      var offsets = [
        [1,0],
        [0,-1],
        [0,1],
        [-1,0]
      ];

      for(offIdx in 0...offsetKeys.length){
        if(offsetHeld[offIdx]){
          pressedOffsetShit[offIdx]+=elapsed;
        }else{
          pressedOffsetShit[offIdx]=0;
        }
        if(offsetKeys[offIdx] || pressedOffsetShit[offIdx]>=.3){
          curCharacter.offset.x += offsets[offIdx][0];
          curCharacter.offset.y += offsets[offIdx][1];

          offsetXBox.text = Std.string(curCharacter.offset.x);
          offsetYBox.text = Std.string(curCharacter.offset.y);
        }
      }


      if(FlxG.keys.justPressed.R)
        showCharacter();

      if(FlxG.keys.justPressed.O)
        camOffset.setPosition(0,0);

      if(FlxG.keys.justPressed.H)
        layering.visible=!layering.visible;

    }

    ghost.flipX = curCharacter.flipX;

    zoom = FlxMath.lerp(zoom, stage.defaultCamZoom, Main.adjustFPS(0.1));
    camGame.zoom=zoom;
    var mid =curCharacter.getMidpoint();
    if((curCharacter is Boyfriend)){
      camFollow.setPosition(mid.x - stage.camOffset.x  + curCharacter.camOffset.x, mid.y - stage.camOffset.y + curCharacter.camOffset.y);
    }else{
      camFollow.setPosition(mid.x + curCharacter.camOffset.x, mid.y + curCharacter.camOffset.y);
    }


    camFollow.x += camOffset.x;
    camFollow.y += camOffset.y;

    ghost.visible = ghostDropdown.selectedId!='0';
    super.update(elapsed);
  }

  function refreshAnims(){
    //var anim = animData.get(curCharacter.animation.curAnim.name);
    var anim = animData.get(animDropdown.selectedLabel);
    if(anim!=null){
      nameBox.text = anim.name;
      prefixBox.text = anim.prefix;
      fpsBox.text = Std.string(anim.fps);
      if(anim.indices!=null){
        var indices = anim.indices.toString();
        indiceBox.text = indices.substring(1, indices.length-1);
      }else{
        indiceBox.text = '';
      }
      loopCheckbox.changeState(anim.looped,false);
      offsetXBox.text = Std.string(anim.offsets[0]);
      offsetYBox.text = Std.string(anim.offsets[1]);
    }else{
      nameBox.text = '';
      prefixBox.text = '';
      fpsBox.text = '';
      indiceBox.text = '';
      offsetXBox.text = '0';
      offsetYBox.text = '0';
      loopCheckbox.changeState(false,false);
    }
  }

  function resetAnims(){
    updateDropdown();
    animDropdown.selectedLabel = animNames[0];
    ghostDropdown.selectedLabel = ghostAnims[0];

    refreshAnims();
  }

  function updateDropdown(){
    var gLabel = ghostDropdown.selectedLabel;
    var aLabel = animDropdown.selectedLabel;
    animNames = [''];
    animData.clear();
    ghostAnims = [''];
    for(anim in curCharacter.charData.anims){
      animNames.push(anim.name);
      animData.set(anim.name,anim);
      ghostAnims.push(anim.name);
    }
    animDropdown.setData(FlxUIDropDownMenu.makeStrIdLabelArray(animNames,true));
    ghostDropdown.setData(FlxUIDropDownMenu.makeStrIdLabelArray(ghostAnims,true));
    if(animNames.indexOf(aLabel)!=-1){
      animDropdown.selectedLabel=aLabel;
    }
    if(ghostAnims.indexOf(gLabel)!=-1){
      ghostDropdown.selectedLabel=gLabel;
    }
  }

  function refreshHP(){
    hpBox.text = curCharacter.iconColor.toWebString();
    redBox.text = Std.string(curCharacter.iconColor.red);
    greenBox.text = Std.string(curCharacter.iconColor.green);
    blueBox.text = Std.string(curCharacter.iconColor.blue);

    healthBar.setColors(curCharacter.iconColor,curCharacter.iconColor);
    healthBar.setIcons(curCharacter.iconName,curCharacter.iconName);
  }
  // UI POPULATION

  function populateAnimUI(ui:UIGroup){
    var mid = ui.getMidpoint().x-ui.x;
    var title = new Alphabet(0,0,"Animation",false,false,.4);
    title.x = mid-title.width/2;
    title.y = -80;
    ui.add(title);

    var animLabel = new Alphabet(0,0,"Animations",false,false,.35);
    animLabel.x = 35;
    animLabel.y = -45;

    animDropdown = new FlxUIDropDownMenu(27, 70, FlxUIDropDownMenu.makeStrIdLabelArray(['idle'], true), function(anim:String)
		{
      curCharacter.playAnim(animNames[Std.parseInt(anim)],true);
      refreshAnims();
		});
    animDropdown.dropDirection = FlxUIDropDownMenuDropDirection.Down;
		animDropdown.selectedLabel = 'idle';
    ui.add(animLabel);

    var ghostLabel = new Alphabet(0,0,"Ghost",false,false,.35);
    ghostLabel.x = 310;
    ghostLabel.y = -45;
    ui.add(ghostLabel);
    ghostDropdown = new FlxUIDropDownMenu(280, 70, FlxUIDropDownMenu.makeStrIdLabelArray([''], true), function(anim:String)
    {
      var id = Std.parseInt(anim);
      if(id!=0){
        ghost.visible=true;
        ghost.playAnim(ghostAnims[id],true);
      }else{
        ghost.playAnim("idle",true);
        ghost.visible=false;
      }
    });
    ghostDropdown.dropDirection = FlxUIDropDownMenuDropDirection.Down;
    ghostDropdown.selectedLabel = '';


    var nameLabel = new Alphabet(0,0,"Name",false,false,.35);
    nameLabel.x = 72.5;
    nameLabel.y = 15;

    nameBox = new Inputbox(0, 130, 150, "idle", 14);
    nameBox.x = 25;
    nameBox.alignment = CENTER;
    nameBox.callback = function(text:String,action:String){
      if(action=='enter'){
        nameBox.hasFocus=false;
      }
    }

    ui.add(nameLabel);
    ui.add(nameBox);

    var prefixLabel = new Alphabet(0,0,"Prefix",false,false,.35);
    prefixLabel.x = 305;
    prefixLabel.y = 15;

    prefixBox = new Inputbox(0, 130, 175, "bf idle dance", 14);
    prefixBox.x = 250;
    prefixBox.alignment = LEFT;
    prefixBox.callback = function(text:String,action:String){
      if(action=='enter'){
        prefixBox.hasFocus=false;
      }
    }

    ui.add(prefixLabel);
    ui.add(prefixBox);

    var fpsLabel = new Alphabet(0,0,"Framerate",false,false,.35);
    fpsLabel.x = 40;
    fpsLabel.y = 70;

    fpsBox = new Inputbox(0, 190, 100, "24", 14);
    fpsBox.x = 40;
    fpsBox.filterMode = FlxInputText.ONLY_NUMERIC;
    fpsBox.alignment = LEFT;
    fpsBox.focusLost = function(){
      if(Math.isNaN(Std.parseFloat(fpsBox.text))){
        fpsBox.text = '24';
      }
    }
    fpsBox.callback = function(text:String,action:String){
      if(action=='enter'){
        if(Math.isNaN(Std.parseFloat(fpsBox.text))){
          fpsBox.text = '24';
        }
        fpsBox.hasFocus=false;
      }
    }

    ui.add(fpsLabel);
    ui.add(fpsBox);

    var loopLabel = new Alphabet(0,0,"Looped",false,false,.35);
    loopLabel.x = 300;
    loopLabel.y = 70;

    loopCheckbox = new Checkbox(false);
    loopCheckbox.x = 310;
    loopCheckbox.y = 185;
    ui.add(loopLabel);
    ui.add(loopCheckbox);

    var offLabel = new Alphabet(0,0,"Animation Offset",false,false,.35);
    offLabel.x = 12;
    offLabel.y = 125;
    ui.add(offLabel);

    var offXLabel = new Alphabet(0,0,"X",false,false,.35);
    offXLabel.x = 48;
    offXLabel.y = 150;

    offsetXBox = new Inputbox(30, 265, 50, '0', 16);
    offsetXBox.alignment = CENTER;
    offsetXBox.filterMode = FlxInputText.ONLY_NUMERIC;
    offsetXBox.focusLost = function(){
      if(Math.isNaN(Std.parseFloat(offsetXBox.text))){
        offsetXBox.text = '0';
      }
    }
    offsetXBox.callback = function(text,action){
      if(action=='enter'){
        var offset = Std.parseFloat(text);
        if(Math.isNaN(offset) ){
          offsetXBox.text = '0';
          offset=0;
        }
        offsetXBox.hasFocus=false;
        var name = animDropdown.selectedLabel;
        curCharacter.offset.x = offset;
      }
    }
    ui.add(offXLabel);
    ui.add(offsetXBox);

    var offYLabel = new Alphabet(0,0,"Y",false,false,.35);
    offYLabel.x = 118;
    offYLabel.y = 150;

    offsetYBox = new Inputbox(100, 265, 50, '0', 16);
    offsetYBox.alignment = CENTER;
    offsetYBox.filterMode = FlxInputText.ONLY_NUMERIC;
    offsetYBox.focusLost = function(){
      if(Math.isNaN(Std.parseFloat(offsetYBox.text))){
        offsetYBox.text = '0';
      }
    }
    offsetYBox.callback = function(text,action){
      if(action=='enter'){
        var offset = Std.parseFloat(text);
        if(Math.isNaN(offset) ){
          offsetYBox.text = '0';
          offset=0;
        }
        offsetYBox.hasFocus=false;
        var name = animDropdown.selectedLabel;
        curCharacter.offset.y = offset;
      }
    }
    ui.add(offYLabel);
    ui.add(offsetYBox);

    var indiceLabel = new Alphabet(0,0,"Indices",false,false,.35);
    indiceLabel.x = 270;
    indiceLabel.y = 150;

    indiceBox = new Inputbox(305 - (225 / 2), 265, 225, "", 14);
    indiceBox.alignment = LEFT;
    indiceBox.callback = function(text:String,action:String){
      if(action=='enter'){
        indiceBox.hasFocus=false;
      }
    }

    ui.add(indiceLabel);
    ui.add(indiceBox);


    delAnimButton = new FlxButton(220, 310, "Remove", function()
    {
      var name = nameBox.text;
      var idx:Int=0;
      var curPlaying = curCharacter.animation.curAnim.name;
      for(anim in curCharacter.charData.anims){

        if(anim.name==name){
          if(curCharacter.animation.getByName(anim.name)!=null)
            curCharacter.animation.remove(anim.name);

          curCharacter.charData.anims.remove(anim);
          break;
        }
        idx++;
      }
      if(curPlaying==name){
        curCharacter.dance();
      }
      updateDropdown();
      refreshAnims();
    });
    ui.add(delAnimButton);

    addAnimButton = new FlxButton(90, 310, "Add/Update", function()
		{
      var fps = Std.parseInt(fpsBox.text);
      var offsetX = Std.parseFloat(offsetXBox.text);
      var offsetY = Std.parseFloat(offsetYBox.text);
      if(Math.isNaN(fps)){
        fps=24;
      }
      if(Math.isNaN(offsetX)){
        offsetX=0;
      }
      if(Math.isNaN(offsetY)){
        offsetY=0;
      }

      var indices:Array<Int> = [];
      for(shit in indiceBox.text.trim().split(",")){
        if(shit!=null){
          var idx:Null<Int> = Std.parseInt(shit);
          if(idx!=null && !Math.isNaN(idx) && idx>-1)
            indices.push(idx);

          trace(idx, shit);
        }

      }
      var newAnim:Character.AnimShit = {
        prefix: prefixBox.text,
        name: nameBox.text,
        fps: fps,
        looped: loopCheckbox.state,
        offsets: [offsetX,offsetY]
      }
      if(indices.length>0)newAnim.indices=indices;
      trace(indices.length);
      var idx:Int=0;
      var curAnim = curCharacter.animation.curAnim;
      var curPlaying = '';
      if(curAnim!=null)
        curPlaying=curAnim.name;

      for(anim in curCharacter.charData.anims){
        if(anim.name==newAnim.name){
          if(curCharacter.animation.getByName(anim.name)!=null){
            curCharacter.animation.remove(anim.name);
          }
          curCharacter.charData.anims.remove(anim);
          break;
        }
        idx++;
      }
      if(indices.length>0)
        curCharacter.animation.addByIndices(newAnim.name,newAnim.prefix,newAnim.indices, "", newAnim.fps,newAnim.looped);
      else
        curCharacter.animation.addByPrefix(newAnim.name,newAnim.prefix,newAnim.fps,newAnim.looped);
      curCharacter.animOffsets.set(newAnim.name,newAnim.offsets);
      curCharacter.charData.anims.insert(idx, newAnim);
      curCharacter.playAnim(newAnim.name,true);

      updateDropdown();
      animDropdown.selectedLabel = newAnim.name;
		});
    ui.add(addAnimButton);


    ui.add(animDropdown);
    ui.add(ghostDropdown);
    ui.setScrollFactor(0,0);
  }

  function populateHPUI(ui:UIGroup){
    var title = new Alphabet(0,0,"Healthbar",false,false,.4);
    title.x = ui.getMidpoint().x - title.width/2;
    title.y = -80;
    ui.add(title);

    var iconLabel = new Alphabet(0,0,"Icon Name",false,false,.35);
    iconLabel.x = ui.getMidpoint().x - iconLabel.width/2;
    iconLabel.y = -55;

    iconBox = new Inputbox(0, 65, 140, "bf", 16);
    iconBox.x = ui.getMidpoint().x - iconBox.width/2;
    iconBox.alignment = CENTER;
    iconBox.callback = function(text:String,action:String){
      if(action=='enter'){
        iconBox.hasFocus=false;
        curCharacter.iconName = text;
        curCharacter.charData.iconName = text;

        refreshHP();
      }
    }

    ui.add(iconLabel);
    ui.add(iconBox);

    var hpLabel = new Alphabet(0,0,"Health Colour",false,false,.35);
    hpLabel.x = ui.getMidpoint().x - hpLabel.width/2;
    hpLabel.y = 0;

    hpBox = new Inputbox(0, 120, 160, "#50A5EB", 16);
    hpBox.x = ui.getMidpoint().x - hpBox.width/2;
    hpBox.alignment = CENTER;
    hpBox.callback = function(text:String,action:String){
      if(action=='enter'){
        var colour = FlxColor.fromString(text);
        if(colour==null){
          hpBox.text = "#66FF33";
          colour = 0xFF66FF33;
        }
        curCharacter.iconColor = colour;
        curCharacter.charData.healthColor = colour.toHexString(true,true);

        refreshHP();
      }
    }

    ui.add(hpLabel);
    ui.add(hpBox);

    redBox = new Inputbox(0, 170, 45, "255", 12);
    redBox.x = 38.05;
    redBox.filterMode = FlxInputText.ONLY_NUMERIC;
    redBox.alignment = CENTER;
    redBox.callback = function(text:String,action:String){
      if(action=='enter'){
        redBox.hasFocus=false;
        curCharacter.iconColor.red = Std.parseInt(text);
        curCharacter.charData.healthColor = curCharacter.iconColor.toHexString(true,true);
        refreshHP();
      }
    }

    var redLabel = new Alphabet(0,0,"Red",false,false,.3);
    redLabel.x = redBox.getMidpoint().x - redLabel.width/2;
    redLabel.y = 52;

    ui.add(redLabel);
    ui.add(redBox);

    greenBox = new Inputbox(0, 170, 45, "255", 12);
    greenBox.x = 95.6;
    greenBox.filterMode = FlxInputText.ONLY_NUMERIC;
    greenBox.alignment = CENTER;
    greenBox.callback = function(text:String,action:String){
      if(action=='enter'){
        greenBox.hasFocus=false;
        curCharacter.iconColor.green = Std.parseInt(text);
        curCharacter.charData.healthColor = curCharacter.iconColor.toHexString(true,true);
        refreshHP();
      }
    }
    var greenLabel = new Alphabet(0,0,"Green",false,false,.3);
    greenLabel.x = greenBox.getMidpoint().x - greenLabel.width/2;
    greenLabel.y = 52;

    ui.add(greenLabel);
    ui.add(greenBox);

    blueBox = new Inputbox(0, 170, 45, "255", 12);
    blueBox.x = 151.65;
    blueBox.filterMode = FlxInputText.ONLY_NUMERIC;
    blueBox.alignment = CENTER;
    blueBox.callback = function(text:String,action:String){
      if(action=='enter'){
        blueBox.hasFocus=false;
        curCharacter.iconColor.blue = Std.parseInt(text);
        curCharacter.charData.healthColor = curCharacter.iconColor.toHexString(true,true);
        refreshHP();
      }
    }

    var blueLabel = new Alphabet(0,0,"Blue",false,false,.3);
    blueLabel.x = blueBox.getMidpoint().x - blueLabel.width/2;
    blueLabel.y = 52;

    ui.add(blueLabel);
    ui.add(blueBox);

  }

  function refreshCharList(){
    InitState.getCharacters();

    var selectedLabel = charDropdown.selectedLabel;
    var characters:Array<String> = EngineData.characters;
    charDropdown.setData(FlxUIDropDownMenu.makeStrIdLabelArray(characters, true));
    charDropdown.selectedLabel = selectedLabel;
  }

  function populateCharUI(ui:UIGroup){
    var title = new Alphabet(0,0,"Character",false,false,.4);
    title.x = ui.getMidpoint().x - title.width/2;
    title.y = -75;
    ui.add(title);
    var characters:Array<String> = EngineData.characters;
    charDropdown = new FlxUIDropDownMenu(105, 40, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			char = characters[Std.parseInt(character)];
      showCharacter();
		});
    charDropdown.dropDirection = FlxUIDropDownMenuDropDirection.Down;
    charDropdown.x = ui.getMidpoint().x - charDropdown.width/2;
		charDropdown.selectedLabel = char;

    var idleLabel = new Alphabet(0,0,"Idles Every Beat",false,false,.4);
    idleLabel.x = ui.getMidpoint().x - idleLabel.width/2;
    idleLabel.y = -10;

    idleCheckbox = new Checkbox(false);
    idleCheckbox.callback = function(state:Bool){
      curCharacter.beatDancer=state;
      curCharacter.charData.beatDancer=state;
    }
    idleCheckbox.tracker = idleLabel;
    ui.add(idleLabel);
    ui.add(idleCheckbox);

    var playerLabel = new Alphabet(0,0,"Is Player",false,false,.4);
    playerLabel.x = idleLabel.x;
    playerLabel.y = 40;

    playerCheckbox = new Checkbox(false);
    playerCheckbox.tracker = playerLabel;
    playerCheckbox.callback = function(state:Bool){
      showCharacter();
    }

    ui.add(playerLabel);
    ui.add(playerCheckbox);

    var flipLabel = new Alphabet(0,0,"Flip X",false,false,.4);
    flipLabel.x = idleLabel.x;
    flipLabel.y = 90;

    flipCheckbox = new Checkbox(false);
    flipCheckbox.tracker = flipLabel;
    flipCheckbox.callback = function(state:Bool){
      curCharacter.flipX = state;
      curCharacter.charData.flipX = state;
    }

    ui.add(flipLabel);
    ui.add(flipCheckbox);

    var antialiasingLabel = new Alphabet(0,0,"Antialiasing",false,false,.4);
    antialiasingLabel.x = idleLabel.x;
    antialiasingLabel.y = 140;

    antialiasingCheckbox = new Checkbox(false);
    antialiasingCheckbox.tracker = antialiasingLabel;
    antialiasingCheckbox.callback = function(state:Bool){
      curCharacter.antialiasing = state;
      curCharacter.charData.antialiasing = state;
    }

    ui.add(antialiasingLabel);
    ui.add(antialiasingCheckbox);

    var scaleLabel = new Alphabet(0,0,"Scale",false,false,.4);
    scaleLabel.x = 30;
    scaleLabel.y = 180;

    scaleBox = new Inputbox(30, 300, 94, "1", 18);
    scaleBox.alignment = LEFT;
    scaleBox.filterMode = FlxInputText.ONLY_NUMERIC;
    scaleBox.focusLost = function(){
      if(Math.isNaN(Std.parseFloat(scaleBox.text))){
        scaleBox.text = '1';
      }
    }
    scaleBox.callback = function(text,action){
      if(action=='enter'){
        var scale = Std.parseFloat(text);
        if(Math.isNaN(scale) ){
          scaleBox.text = '1';
          scale=1;
        }
        scaleBox.hasFocus=false;
        curCharacter.charData.scale = scale;
        curCharacter.setGraphicSize(Std.int(curCharacter.frameWidth*scale));
        curCharacter.updateHitbox();
        ghost.setGraphicSize(Std.int(curCharacter.width),Std.int(curCharacter.height));
        ghost.updateHitbox();
        curCharacter.dance(true);
      }
    }
    ui.add(scaleLabel);
    ui.add(scaleBox);

    var singDurLabel = new Alphabet(0,0,"Sing Duration",false,false,.4);
    singDurLabel.x = 160;
    singDurLabel.y = 180;
    singDurBox = new Inputbox(155, 300, 94, "1", 18);
    singDurBox.alignment = LEFT;
    singDurBox.filterMode = FlxInputText.ONLY_NUMERIC;
    singDurBox.focusLost = function(){
      if(Math.isNaN(Std.parseFloat(singDurBox.text))){
        singDurBox.text = '1';
      }
    }
    singDurBox.callback = function(text,action){
      if(action=='enter'){
        var singDur = Std.parseFloat(text);
        if(Math.isNaN(singDur) ){
          singDurBox.text = '1';
          singDur=1;
        }
        singDurBox.hasFocus=false;
        curCharacter.charData.singDur = singDur;
        curCharacter.dadVar = singDur;
      }
    }

    ui.add(singDurLabel);
    ui.add(singDurBox);

    var sheetLabel = new Alphabet(0,0,"Spritesheet",false,false,.4);
    sheetLabel.x = 30;
    sheetLabel.y = 245;
    sheetBox = new Inputbox(30, 360, 241, 'BOYFRIEND', 18);
    sheetBox.alignment = LEFT;
    sheetBox.callback = function(text,action){
      if(action=='enter'){
        sheetBox.hasFocus=false;
        curCharacter.charData.spritesheet = text;
        curCharacter.setCharData();
        updateGhost();
      }
    }

    ui.add(sheetLabel);
    ui.add(sheetBox);

    var charOffLabel = new Alphabet(0,0,"Character Offset",false,false,.3);
    charOffLabel.x = 25;
    charOffLabel.y = 305;

    var charOffXLabel = new Alphabet(0,0,"X",false,false,.25);
    charOffXLabel.x = 52;
    charOffXLabel.y = 330;

    charXBox = new Inputbox(30, 450, 50, '0', 16);
    charXBox.filterMode = FlxInputText.ONLY_NUMERIC;
    charXBox.alignment = CENTER;
    charXBox.focusLost = function(){
      if(Math.isNaN(Std.parseFloat(charXBox.text))){
        charXBox.text = '0';
      }
    }
    charXBox.callback = function(text,action){
      if(action=='enter'){
        var offset = Std.parseFloat(text);
        if(Math.isNaN(offset) ){
          charXBox.text = '0';
          offset=0;
        }
        charXBox.hasFocus=false;
        curCharacter.posOffset.x = offset;
        curCharacter.charData.charOffset[0]=offset;
        stage.setPlayerPositions(boyfriend,dad);
        updateGhost();
      }
    }

    var charOffYLabel = new Alphabet(0,0,"Y",false,false,.25);
    charOffYLabel.x = 132;
    charOffYLabel.y = 330;

    charYBox = new Inputbox(110, 450, 50, '0', 16);
    charYBox.alignment = CENTER;
    charYBox.filterMode = FlxInputText.ONLY_NUMERIC;
    charYBox.focusLost = function(){
      if(Math.isNaN(Std.parseFloat(charYBox.text))){
        charYBox.text = '0';
      }
    }
    charYBox.callback = function(text,action){
      if(action=='enter'){
        var offset = Std.parseFloat(text);
        if(Math.isNaN(offset) ){
          charYBox.text = '0';
          offset=0;
        }
        charYBox.hasFocus=false;
        curCharacter.posOffset.y = offset;
        curCharacter.charData.charOffset[1]=offset;
        stage.setPlayerPositions(boyfriend,dad);
        updateGhost();
      }
    }

    ui.add(charOffLabel);
    ui.add(charOffXLabel);
    ui.add(charXBox);
    ui.add(charOffYLabel);
    ui.add(charYBox);

    var camOffLabel = new Alphabet(0,0,"Camera Offset",false,false,.3);
    camOffLabel.x = 206;
    camOffLabel.y = 305;

    var camOffXLabel = new Alphabet(0,0,"X",false,false,.25);
    camOffXLabel.x = 230;
    camOffXLabel.y = 330;

    camXBox = new Inputbox(210, 450, 50, '0', 16);
    camXBox.alignment = CENTER;
    camXBox.filterMode = FlxInputText.ONLY_NUMERIC;
    camXBox.focusLost = function(){
      if(Math.isNaN(Std.parseFloat(camXBox.text))){
        camXBox.text = '0';
      }
    }
    camXBox.callback = function(text,action){
      if(action=='enter'){
        var offset = Std.parseFloat(text);
        if(Math.isNaN(offset) ){
          camXBox.text = '0';
          offset=0;
        }
        camXBox.hasFocus=false;
        curCharacter.camOffset.x = offset;
        if(curCharacter.charData.camOffset==null)curCharacter.charData.camOffset=[curCharacter.camOffset.x,curCharacter.camOffset.y];
        curCharacter.charData.camOffset[0]=offset;
      }
    }

    var camOffYLabel = new Alphabet(0,0,"Y",false,false,.25);
    camOffYLabel.x = 310;
    camOffYLabel.y = 330;

    camYBox = new Inputbox(290, 450, 50, '0', 16);
    camYBox.alignment = CENTER;
    camYBox.filterMode = FlxInputText.ONLY_NUMERIC;
    camYBox.focusLost = function(){
      if(Math.isNaN(Std.parseFloat(camYBox.text))){
        camYBox.text = '0';
      }
    }

    camYBox.callback = function(text,action){
      if(action=='enter'){
        var offset = Std.parseFloat(text);
        if(Math.isNaN(offset) ){
          camYBox.text = '0';
          offset=0;
        }
        camYBox.hasFocus=false;
        curCharacter.camOffset.y = offset;
        if(curCharacter.charData.camOffset==null)curCharacter.charData.camOffset=[curCharacter.camOffset.x,curCharacter.camOffset.y];
        curCharacter.charData.camOffset[1]=offset;
      }
    }

    ui.add(camOffLabel);
    ui.add(camOffXLabel);
    ui.add(camXBox);
    ui.add(camOffYLabel);
    ui.add(camYBox);

    saveButton = new FlxButton(100, 485, "Save", function()
    {
      save(Json.stringify(curCharacter.charData,"\t"),'${curCharacter.curCharacter}${playerCheckbox.state==true?"-player":""}.json');
    });
    saveButton.x = ui.getMidpoint().x - saveButton.width/2;

    ui.add(saveButton);


    ui.add(charDropdown);
    ui.setScrollFactor(0,0);
  }
}
