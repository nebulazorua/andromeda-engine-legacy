package;
#if sys
import flixel.addons.ui.FlxUIState;
import flixel.FlxState;
import sys.thread.Thread;
import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import lime.app.Application;
import Discord.DiscordClient;
import flixel.FlxSprite;
import Options;
import flixel.ui.FlxBar;
import openfl.display.BitmapData;
import Sys;
import sys.FileSystem;

using StringTools;

class CachingState extends FlxUIState {
  var finishState:FlxState;
  var icon:FlxSprite;
  var bg:FlxSprite;
  var bar:FlxBar;
  var barBG:FlxSprite;
  var loaded:Float = 0;
  var toLoad:Float = 0;
  override function create(){
    bg = new FlxSprite().loadGraphic(Paths.image("loadingBG","preload"));
    bg.setGraphicSize(Std.int(bg.width*.85));
    bg.updateHitbox();
    bg.screenCenter(XY);
    bg.antialiasing=true;
    add(bg);

    barBG = new FlxSprite().loadGraphic(Paths.image("barBackground","preload"));
    barBG.setGraphicSize(Std.int(barBG.width));
    barBG.updateHitbox();
    barBG.screenCenter(XY);
    barBG.y += 200;
    barBG.antialiasing=true;
    add(barBG);

    icon = new FlxSprite();
    icon.frames = Paths.getSparrowAtlas("andromedaLogoBumpin","preload");
    icon.setGraphicSize(Std.int(icon.width*.8));
    icon.updateHitbox();
    icon.animation.addByPrefix("idle","logo bumpin",24,true);
    icon.animation.play("idle",true);
    icon.antialiasing=true;
    icon.screenCenter(X);
    add(icon);

    var images:Array<String> = [];
    var sounds:Array<String> = [];

    if(FileSystem.isDirectory("assets/images") ){
      for (file in FileSystem.readDirectory("assets/images"))
      {
        if(file.endsWith(".png") && !FileSystem.isDirectory(file)){ // TODO: recursively go through all directories
          images.push('assets/images/${file}');
        }
      }
    }

    if(EngineData.options.cacheCharacters){
      if(FileSystem.isDirectory("assets/shared/images/characters") ){
        for (file in FileSystem.readDirectory("assets/shared/images/characters"))
        {
          if(file.endsWith(".png") && !FileSystem.isDirectory(file)){
            images.push('assets/shared/images/characters/${file}');
          }
        }
      }
    }
    /*
    if(EngineData.options.cacheWeekImages){
      for (dir in FileSystem.readDirectory("assets"))
      {
        if (FileSystem.isDirectory(dir) && dir.startsWith("week")){
          if(FileSystem.exists('${dir}/images') && FileSystem.isDirectory('${dir}/images') ){
            for (file in FileSystem.readDirectory('${dir}/images'))
            {

            }
          }
        }
      }
    }*/
    if(EngineData.options.cacheSongs){
      if(FileSystem.isDirectory("assets/songs") ){
        for (dir in FileSystem.readDirectory("assets/songs"))
        {
          if (FileSystem.isDirectory(dir)){
            for (file in FileSystem.readDirectory(dir))
            {
              if(file.endsWith('.mp3') || file.endsWith('.ogg')){
                sounds.push('assets/songs/{dir}/${file}');
              }
            }
          }
        }
      }

      if(FileSystem.isDirectory("assets/music") ){
        for (dir in FileSystem.readDirectory("assets/music"))
        {
          if (FileSystem.isDirectory(dir)){
            for (file in FileSystem.readDirectory(dir))
            {
              if(file.endsWith('.mp3') || file.endsWith('.ogg')){
                sounds.push('assets/music/{dir}/${file}');
              }
            }
          }
        }
      }

      if(FileSystem.isDirectory("assets/shared/music") ){
        for (dir in FileSystem.readDirectory("assets/shared/music"))
        {
          if (FileSystem.isDirectory(dir)){
            for (file in FileSystem.readDirectory(dir))
            {
              if(file.endsWith('.mp3') || file.endsWith('.ogg')){
                sounds.push('assets/shared/music/{dir}/${file}');
              }
            }
          }
        }
      }
    }

    if(EngineData.options.cacheSounds){
      if(FileSystem.isDirectory("assets/sounds") ){
        for (file in FileSystem.readDirectory("assets/sounds"))
        {
          if(file.endsWith('.mp3') || file.endsWith('.ogg')){
            sounds.push('assets/sounds/{dir}/${file}');
          }
        }
      }
      if(FileSystem.isDirectory("assets/shared/sounds") ){
        for (file in FileSystem.readDirectory("assets/shared/sounds"))
        {
          if(file.endsWith('.mp3') || file.endsWith('.ogg')){
            sounds.push('assets/shared/sounds/{dir}/${file}');
          }
        }
      }
    }


    toLoad = images.length+sounds.length;
    if(toLoad<=0){
      FlxG.switchState(finishState);
      return;
    }
    bar = new FlxBar(barBG.x + 4, barBG.y + 4, LEFT_TO_RIGHT, Std.int(barBG.width - 8), Std.int(barBG.height - 8), this,
      'loaded', 0, toLoad);
    bar.createFilledBar(0xFF808080, 0xFF4CFF00);
    add(bar);


    Thread.create(()->{
      // TODO: show how many assets n shit
      for(file in images){
        var id = file.replace(".png","");
        var data:BitmapData = BitmapData.fromFile(file);
        var graphic = FlxG.bitmap.add(data,true,id);
        graphic.destroyOnNoUse=false;
        trace("loaded " + file);
        loaded++;
      }
      for(file in sounds){
        FlxG.sound.cache(file);
        trace("loaded " + file);
        loaded++;
      }
      trace("Loaded!");
      FlxG.switchState(finishState);
    });
    super.create();
  }

  public function new(state:FlxState){
    super();
    finishState=state;
  }
}
#end
