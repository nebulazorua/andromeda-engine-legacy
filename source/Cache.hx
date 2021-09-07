package;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.FlxG;
import LuaClass;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets;
import sys.io.File;
import flash.display.BitmapData;
import Sys;
import sys.FileSystem;

class Cache {
  public static var offsetData = new Map<String,String>();
  public static var animData = new Map<String,String>();
  public static var charFrames = new Map<String,FlxFramesCollection>();
  public static var charXmlData = new Map<String,String>();
  public static var xmlData = new Map<String,String>();
  public static var pathCache = new Map<String,String>();

  public static function wipe(){ // a COMPLETE cache clear
    pathCache.clear();
    xmlData.clear();
    Clear();
    trace("WIPED CACHE!");
  }

  public static function Clear(){ // clears most things that are cached
    offsetData.clear();
    animData.clear();
    charFrames.clear();
    charXmlData.clear();
    LuaStorage.objectProperties.clear();
    LuaStorage.objects.clear();
    trace("CLEARED CACHE!");
  }

  public static function getXML(path:String):Null<String>{ // gets an XML file and caches it if it hasnt been already
    if(FileSystem.exists(path) && !xmlData.exists(path)){
      xmlData.set(path,File.getContent(path));
    }

    if(xmlData.exists(path)){
        return xmlData.get(path);
    }

    return null;
  }
}
