package;
import llua.Convert;
import llua.Lua;
import llua.State;
import llua.LuaL;

import flixel.FlxSprite;
import lime.app.Application;
import openfl.Lib;

typedef LuaProperty = {
    var defaultValue:Any;
    var getter:(State,Any)->Int;
    var setter:State->Int;
}

class LuaClass {
  public var properties:Map<String,LuaProperty> = [];
  public var methods:Map<String,cpp.Callable<StatePointer->Int> > = [];
  public var className:String = "BaseClass";
  private static var objectProperties:Map<String,Map<String,LuaProperty>> = [];
  private static var state:State;
  public var addToGlobal:Bool=true;
  public function Register(l:State){
    Lua.newtable(l);
    state=l;
    objectProperties[className]=this.properties;

    var classIdx = Lua.gettop(l);
    Lua.pushvalue(l,classIdx);
    if(addToGlobal)
      Lua.setglobal(l,className);

    for (k in methods.keys()){
      Lua.pushcfunction(l,methods[k]);
      Lua.setfield(l,classIdx,k);
    }

    LuaL.newmetatable(l,className + "Metatable");
    var mtIdx = Lua.gettop(l);
    Lua.pushstring(l, "__index");
		Lua.pushcfunction(l,cpp.Callable.fromStaticFunction(index));
		Lua.settable(l, mtIdx);

    Lua.pushstring(l, "__newindex");
		Lua.pushcfunction(l,cpp.Callable.fromStaticFunction(newindex));
		Lua.settable(l, mtIdx);

    for (k in properties.keys()){
      Lua.pushstring(l,k + "PropertyData");
      if(k=="visible"){
        trace(Type.typeof(properties[k].defaultValue));
      }
      Convert.toLua(l,properties[k].defaultValue);
      Lua.settable(l,mtIdx);
    }
    Lua.pushstring(l,"_CLASSNAME");
    Lua.pushstring(l,className);
    Lua.settable(l,mtIdx);

    Lua.pushstring(l,"__metatable");
    Lua.pushstring(l,"This metatable is locked.");
    Lua.settable(l,mtIdx);

    Lua.setmetatable(l,classIdx);

    Lua.pop(l,0);
  };


  private static function index(l:StatePointer):Int{
    var l = state;
    var index = Lua.tostring(l,-1);
    if(Lua.getmetatable(l,-2)!=0){
      var mtIdx = Lua.gettop(l);
      Lua.pushstring(l,index + "PropertyData");
      Lua.rawget(l,mtIdx);
      var data:Any = Convert.fromLua(l,-1);
      if(data!=null){
        Lua.pushstring(l,"_CLASSNAME");
        Lua.rawget(l,mtIdx);
        var clName = Lua.tostring(l,-1);
        if(objectProperties[clName]!=null && objectProperties[clName][index]!=null){
          return objectProperties[clName][index].getter(l,data);
        }
      };
    }else{
      // TODO: throw an error!
    };
    return 0;
  }

  private static function newindex(l:StatePointer):Int{
    var l = state;
    var index = Lua.tostring(l,2);
    if(Lua.getmetatable(l,1)!=0){
      var mtIdx = Lua.gettop(l);
      Lua.pushstring(l,index + "PropertyData");
      Lua.rawget(l,mtIdx);
      var data:Any = Convert.fromLua(l,-1);
      if(data!=null){
        Lua.pushstring(l,"_CLASSNAME");
        Lua.rawget(l,mtIdx);
        var clName = Lua.tostring(l,-1);
        if(objectProperties[clName]!=null && objectProperties[clName][index]!=null){
          Lua.pop(l,2);
          return objectProperties[clName][index].setter(l);
        }
      };
    }else{
      // TODO: throw an error!
    };
    return 0;
  }

  public static function SetProperty(l:State,tableIndex:Int,key:String,value:Any){
    Lua.pushstring(l,key + "PropertyData");
    Convert.toLua(l,value);
    Lua.settable(l,tableIndex  );

    Lua.pop(l,2);
  }

  public static function DefaultSetter(l:State){
    var key = Lua.tostring(l,2);

    Lua.pushstring(l,key + "PropertyData");
    Lua.pushvalue(l,3);
    Lua.settable(l,4);

    Lua.pop(l,2);
  };
  public function new(){}
}

class LuaWindow extends LuaClass {
  private static var state:State;
  private static function WrapNumberSetter(l:State){
      // 1 = self
      // 2 = key
      // 3 = value
      // 4 = metatable
      if(Lua.type(l,3)!=Lua.LUA_TNUMBER){
        LuaL.error(l,"invalid argument #3 (number expected, got " + Lua.typename(l,Lua.type(l,3)) + ")");
        return 0;
      }
      //Lib.application.window.x = Std.int(Lua.tonumber(l,3));
      Reflect.setProperty(Lib.application.window,Lua.tostring(l,2),Lua.tonumber(l,3));
      return 0;
  }

  public function new (){
    super();
    className = "window";
    properties = [
      "x"=>{
        defaultValue:Lib.application.window.x,
        getter: function(l:State,data:Any):Int{
          Lua.pushnumber(l,Lib.application.window.x);
          return 1;
        },
        setter:WrapNumberSetter
      },
      "y"=>{
        defaultValue:Lib.application.window.y,
        getter: function(l:State,data:Any):Int{
          Lua.pushnumber(l,Lib.application.window.y);
          return 1;
        },
        setter:WrapNumberSetter
      },
      "width"=>{
        defaultValue:Lib.application.window.width,
        getter: function(l:State,data:Any):Int{
          Lua.pushnumber(l,Lib.application.window.width);
          return 1;
        },
        setter:WrapNumberSetter
      },
      "height"=>{
        defaultValue:Lib.application.window.height,
        getter: function(l:State,data:Any):Int{
          Lua.pushnumber(l,Lib.application.window.height);
          return 1;
        },
        setter:WrapNumberSetter
      },
      "boundsWidth"=>{ // TODO: turn into a table w/ bounds.x and bounds.y
        defaultValue:Lib.application.window.display.bounds.width,
        getter: function(l:State,data:Any):Int{
          Lua.pushnumber(l,Lib.application.window.display.bounds.width);
          return 1;
        },
        setter:function(l:State){
          LuaL.error(l,"boundsWidth is read-only.");
          return 0;
        }
      },
      "boundsHeight"=>{ // TODO: turn into a table w/ bounds.x and bounds.y
        defaultValue:Lib.application.window.display.bounds.height,
        getter: function(l:State,data:Any):Int{
          Lua.pushnumber(l,Lib.application.window.display.bounds.height);
          return 1;
        },
        setter:function(l:State){
          LuaL.error(l,"boundsHeight is read-only.");
          return 0;
        }
      }
    ];
  }
  override function Register(l:State){
    state=l;
    super.Register(l);
  }
}

class LuaSprite extends LuaClass {
  private static var state:State;

  private var sprite:FlxSprite;
  private function SetNumProperty(l:State){
      // 1 = self
      // 2 = key
      // 3 = value
      // 4 = metatable
      if(Lua.type(l,3)!=Lua.LUA_TNUMBER){
        LuaL.error(l,"invalid argument #3 (number expected, got " + Lua.typename(l,Lua.type(l,3)) + ")");
        return 0;
      }
      Reflect.setProperty(sprite,Lua.tostring(l,2),Lua.tonumber(l,3));
      return 0;
  }
  private function GetNumProperty(l:State,data:Any){
      // 1 = self
      // 2 = key
      // 3 = metatable
      Lua.pushnumber(l,Reflect.getProperty(sprite,Lua.tostring(l,2)));
      return 1;
  }

  private function SetBoolProperty(l:State){
      // 1 = self
      // 2 = key
      // 3 = value
      // 4 = metatable
      if(Lua.type(l,3)!=Lua.LUA_TBOOLEAN){
        LuaL.error(l,"invalid argument #3 (boolean expected, got " + Lua.typename(l,Lua.type(l,3)) + ")");
        return 0;
      }
      Reflect.setProperty(sprite,Lua.tostring(l,2),Lua.tonumber(l,3));
      return 0;
  }

  private function GetBoolProperty(l:State,data:Any){
      // 1 = self
      // 2 = key
      // 3 = metatable
      Lua.pushboolean(l,Reflect.getProperty(sprite,Lua.tostring(l,2)));
      return 1;
  }

  private static function setScale(l:StatePointer){
    // 1 = self
    // 2 = scale
    var scale = LuaL.checknumber(state,2);
    trace(scale);
    Lua.getfield(state,1,"spriteName");
    var spriteName = Lua.tostring(state,-1);
    trace(spriteName);
    var sprite = PlayState.currentPState.luaSprites[spriteName];
    sprite.setGraphicSize(Std.int(sprite.width*scale));
    return 0;
  }

  public function new(sprite:FlxSprite,name:String,?addToGlobal:Bool=true){
    super();
    className=name;
    this.addToGlobal=addToGlobal;
    this.sprite=sprite;
    PlayState.currentPState.luaSprites[name]=sprite;
    properties=[
      "spriteName"=>{
        defaultValue:name,
        getter:function(l:State,data:Any){
          Lua.pushstring(l,name);
          return 1;
        },
        setter:function(l:State){
          LuaL.error(l,"spriteName is read-only.");
          return 0;
        }
      },
      "x"=>{
        defaultValue:sprite.x,
        getter:GetNumProperty,
        setter:SetNumProperty
      },
      "y"=>{
        defaultValue:sprite.y,
        getter:GetNumProperty,
        setter:SetNumProperty
      },
      "alpha"=>{
        defaultValue:sprite.alpha,
        getter:GetNumProperty,
        setter:SetNumProperty
      },
      "angle"=>{
        defaultValue:sprite.angle,
        getter:GetNumProperty,
        setter:SetNumProperty
      },
      "width"=>{
        defaultValue:sprite.width,
        getter:GetNumProperty,
        setter:SetNumProperty
      },
      "height"=>{
        defaultValue:sprite.height,
        getter:GetNumProperty,
        setter:SetNumProperty
      },
      "visible"=>{
        defaultValue:sprite.visible,
        getter:GetBoolProperty,
        setter:SetBoolProperty
      },
      "setScale"=>{
        defaultValue:0,
        getter:function(l:State,data:Any){
          Lua.pushcfunction(l,cpp.Callable.fromStaticFunction(setScale));
          return 1;
        },
        setter:function(l:State){
          LuaL.error(l,"setScale is read-only.");
          return 0;
        }
      }

    ];
  }
  override function Register(l:State){
    state=l;
    super.Register(l);
  }
}
class LuaNote extends LuaClass {
  private static var state:State;
  private static var internalNames = [
    "left",
    "down",
    "up",
    "right"
  ];
  public function new(noteData:Int,plr:Bool){ // god i've gotta make this better
    super();
    className= internalNames[noteData] + (plr?"Plr":"Dad") + "Note";
    properties=[
      "alpha"=>{
        defaultValue: 1 ,
        getter: function(l:State,data:Any):Int{
          Lua.pushnumber(l,data);
          return 1;
        },
        setter: function(l:State):Int{
          // 1 = self
          // 2 = key
          // 3 = value
          // 4 = metatable
          if(Lua.type(l,3)!=Lua.LUA_TNUMBER){
            LuaL.error(l,"invalid argument #3 (number expected, got " + Lua.typename(l,Lua.type(l,3)) + ")");
            return 0;
          }

          var alpha = Lua.tonumber(l,3);
          if(plr)
            PlayState.currentPState.refNotes.members[noteData].alpha=alpha;
          else
            PlayState.currentPState.opponentRefNotes.members[noteData].alpha=alpha;

          LuaClass.DefaultSetter(l);
          return 0;
        }
      },
      "xOffset"=>{
        defaultValue: 0,
        getter: function(l:State,data:Any):Int{
          Lua.pushnumber(l,data);
          return 1;
        },
        setter: function(l:State):Int{
          // 1 = self
          // 2 = key
          // 3 = value
          // 4 = metatable
          if(Lua.type(l,3)!=Lua.LUA_TNUMBER){
            LuaL.error(l,"invalid argument #3 (number expected, got " + Lua.typename(l,Lua.type(l,3)) + ")");
            return 0;
          }

          var offset = Lua.tonumber(l,3);
          if(plr)
            PlayState.currentPState.playerNoteOffsets[noteData][0]=offset;
          else
            PlayState.currentPState.opponentNoteOffsets[noteData][0]=offset;

          LuaClass.DefaultSetter(l);
          return 0;
        }
      },
      "yOffset"=>{
        defaultValue: 0,
        getter: function(l:State,data:Any):Int{
          Lua.pushnumber(l,data);
          return 1;
        },
        setter: function(l:State):Int{
          // 1 = self
          // 2 = key
          // 3 = value
          // 4 = metatable
          if(Lua.type(l,3)!=Lua.LUA_TNUMBER){
            LuaL.error(l,"invalid argument #3 (number expected, got " + Lua.typename(l,Lua.type(l,3)) + ")");
            return 0;
          }

          var offset = Lua.tonumber(l,3);
          if(plr)
            PlayState.currentPState.playerNoteOffsets[noteData][1]=offset;
          else
            PlayState.currentPState.opponentNoteOffsets[noteData][1]=offset;

          LuaClass.DefaultSetter(l);
          return 0;
        }
      },
    ];
  }
  override function Register(l:State){
    state=l;
    super.Register(l);
  }
}
