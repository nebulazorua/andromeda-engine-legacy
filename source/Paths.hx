package;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import sys.io.File;
import flash.display.BitmapData;
import Sys;
import sys.FileSystem;
import haxe.Json;
import flixel.system.FlxAssets.FlxGraphicAsset;
import ui.*;
using StringTools;
class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	static var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	static function getPath(file:String, type:AssetType, library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	public static function getDirs(library:String,?base='assets/images'){
		var folders:Array<String>=[];
		// TODO: openflassets shit maybe?
		for(folder in FileSystem.readDirectory('${base}/${library}') ){
			if(!folder.contains(".") && FileSystem.isDirectory('${base}/${library}/${folder}')){
				folders.push(folder);
			}
		}
		return folders;
	}

	// SLIGHTLY BASED ON https://github.com/Yoshubs/Forever-Engine/blob/master/source/ForeverTools.hx
	// THANKS YOU GUYS ARE THE FUNKIN BEST
	// IF YOU'RE READING THIS AND YOU HAVENT HEARD OF IT:
	// TRY FOREVER ENGINE, SERIOUSLY!

	public static function noteskinManifest(skin:String,?library:String='skins'):Note.SkinManifest{
		var path = 'assets/images/${library}/${skin}/metadata.json';
		if(OpenFlAssets.exists(path)){
			return Json.parse(OpenFlAssets.getText(path));
		}else if(FileSystem.exists(path)){
			return Json.parse(File.getContent(path));
		}
		return Json.parse(File.getContent('assets/images/${library}/fallback/metadata.json'));
	}

	public static function noteSkinPath(key:String, ?library:String='skins', ?skin:String='default', modifier:String='base', noteType:String='default', ?useOpenFLAssetSystem:Bool=true):String
	{
		var internalName = '${library}-${skin}-${modifier}-${noteType}-${key}';
		if(Cache.pathCache.exists(internalName)){
			return Cache.pathCache.get(internalName);
		}

		var pathsNotetype:Array<String> = [
			'assets/images/${library}/${skin}/${modifier}/${noteType}/${key}',
			'assets/images/${library}/${skin}/base/${noteType}/${key}',
			'assets/images/${library}/default/base/${noteType}/${key}',
			'assets/images/skins/fallback/${modifier}/${noteType}/${key}',
			'assets/images/skins/fallback/base/${noteType}/${key}',
		];

		var pathsNoNotetype:Array<String> = [
			'assets/images/${library}/${skin}/${modifier}/${key}',
			'assets/images/${library}/${skin}/base/${key}',
			'assets/images/${library}/default/base/${key}',
			'assets/images/skins/default/base/${key}',
			'assets/images/skins/fallback/${modifier}/${key}',
			'assets/images/skins/fallback/base/${key}',
		];
		var idx = 0;
		var path:String='';
		if(useOpenFLAssetSystem){
			if(noteType!='' && noteType!='default' && noteType!='receptor'){
				while(idx<pathsNotetype.length){
					path = pathsNotetype[idx];
					if(OpenFlAssets.exists(path))
						break;

					idx++;
				}
				trace(path);
			}else{
				while(idx<pathsNoNotetype.length){
					path = pathsNoNotetype[idx];
					if(FileSystem.exists(path))
						break;

					idx++;
				}
			}

			if(!OpenFlAssets.exists(path)){
				return noteSkinPath(key,library,skin,modifier,noteType,false);
			}

			Cache.pathCache.set(internalName,path);
			return path;
		}else{
			if(noteType!='' && noteType!='default'){
				while(idx<pathsNotetype.length){
					path = pathsNotetype[idx];
					if(FileSystem.exists(path))
						break;

					idx++;
				}
				trace(path);
			}else{
				while(idx<pathsNoNotetype.length){
					path = pathsNoNotetype[idx];
					if(FileSystem.exists(path))
						break;

					idx++;
				}
				trace(path);
			}

			Cache.pathCache.set(internalName,path);
			return path;
		}
	}

	public static function noteSkinImage(key:String, ?library:String='skins', ?skin:String='default', modifier:String='base', noteType:String='', ?useOpenFLAssetSystem:Bool=true):FlxGraphicAsset{
		if(useOpenFLAssetSystem){
			var pngPath = noteSkinPath('${key}.png',library,skin,modifier,noteType,useOpenFLAssetSystem);
			if(OpenFlAssets.exists(pngPath)){
				return pngPath;
			}else{
				return noteSkinImage(key,library,skin,modifier,noteType,false);
			}
		}else{
			var bitmapName:String = '${key}-${library}-${skin}-${modifier}-${noteType}';
			var doShit=FlxG.bitmap.checkCache(bitmapName);
			if(!doShit){
				var pathPng = noteSkinPath('${key}.png',library,skin,modifier,noteType,useOpenFLAssetSystem);
				var image:Null<BitmapData>=null;
				if(FileSystem.exists(pathPng)){
					doShit=true;
					image = BitmapData.fromFile(pathPng);
					FlxG.bitmap.add(image,false,bitmapName);
				}
				if(image!=null)
					return image;
			}else
				return FlxG.bitmap.get(bitmapName);

		}
		return image('skins/fallback/base/$key','preload');
	}

	public static function noteSkinText(key:String, ?library:String='skins', ?skin:String='default', modifier:String='base', noteType:String='', ?useOpenFLAssetSystem:Bool=true):String{
		if(useOpenFLAssetSystem){
			var path = noteSkinPath('${key}',library,skin,modifier,noteType,useOpenFLAssetSystem);
			if(OpenFlAssets.exists(path)){
				return OpenFlAssets.getText(path);
			}else{
				return noteSkinText(key,library,skin,modifier,noteType,false);
			}
		}else{
			var path = noteSkinPath('${key}',library,skin,modifier,noteType,useOpenFLAssetSystem);
			if(FileSystem.exists(path)){
				return Cache.getText(path);
			}
		}
		return OpenFlAssets.getText(file('images/skins/fallback/base/$key','preload'));
	}

	public static function noteSkinAtlas(key:String, ?library:String='skins', ?skin:String='default', modifier:String='base', noteType:String='', ?useOpenFLAssetSystem:Bool=true):Null<FlxAtlasFrames>{
		if(useOpenFLAssetSystem){
			var pngPath = noteSkinPath('${key}.png',library,skin,modifier,noteType,useOpenFLAssetSystem);
			if(OpenFlAssets.exists(pngPath)){
				var xmlPath = noteSkinPath('${key}.xml',library,skin,modifier,noteType,useOpenFLAssetSystem);
				if(OpenFlAssets.exists(xmlPath)){
					return FlxAtlasFrames.fromSparrow(pngPath,xmlPath);
				}else{
					return getSparrowAtlas('skins/fallback/base/$key','preload');
				}
			}else{
				return noteSkinAtlas(key,library,skin,modifier,noteType,false);
			}
		}else{
			var xmlData = Cache.getXML(noteSkinPath('${key}.xml',library,skin,modifier,noteType,useOpenFLAssetSystem));
			if(xmlData!=null){
				var bitmapName:String = '${key}-${library}-${skin}-${modifier}-${noteType}';
				var doShit=true;
				if(!FlxG.bitmap.checkCache(bitmapName)){
					doShit=false;
					var pathPng = noteSkinPath('${key}.png',library,skin,modifier,noteType,useOpenFLAssetSystem);
					if(FileSystem.exists(pathPng)){
						doShit=true;
						FlxG.bitmap.add(BitmapData.fromFile(pathPng),false,bitmapName);
					}
				}
				if(doShit)
					return FlxAtlasFrames.fromSparrow(FlxG.bitmap.get(bitmapName),xmlData);
			}
		}
		return getSparrowAtlas('skins/fallback/base/$key','preload');
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function dialogue(key:String, ?library:String)
	{
		return getPath('songs/$key.txt', TEXT, library);
	}

	inline static public function txtImages(key:String, ?library:String)
	{
		return getPath('images/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	inline static public function chart(key:String,?container:String, ?library:String)
	{
		if(container==null)container=key;
		return getPath('songs/$container/$key.json', TEXT, library);
	}

	static public function sound(key:String, ?library:String)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function voices(song:String)
	{
		return getPath('songs/${song.toLowerCase()}/Voices.$SOUND_EXT', MUSIC, null);
	}

	inline static public function inst(song:String)
	{
		return getPath('songs/${song.toLowerCase()}/Inst.$SOUND_EXT', MUSIC, null);
	}

	inline static public function lua(script:String,?library:String){
			return getPath('data/$script.lua',TEXT,library);
	}

	inline static public function modchart(song:String,?library:String){
		return getPath('songs/$song/modchart.lua',TEXT,library);
	}

	inline static public function image(key:String, ?library:String)
	{
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}


	inline static public function characterSparrow(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSparrow(getPath('characters/images/$key.png', IMAGE, library), file('characters/images/$key.xml', library));
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}
}
