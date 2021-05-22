package;
import llua.Convert;
import llua.Lua;
import llua.State;
import llua.LuaL;

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
  public function Register(l:State){
    Lua.newtable(l);
    state=l;
    objectProperties[className]=this.properties;

    var classIdx = Lua.gettop(l);
    Lua.pushvalue(l,classIdx);
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
class LuaNote extends LuaClass {
  private static var state:State;
  private static var internalNames = [
    "left",
    "down",
    "up",
    "right"
  ];
  public function new(noteData:Int,plr:Bool){
    super();
    className= internalNames[noteData] + (plr?"Plr":"Dad") + "Note";
    properties=[
      "xOffset"=>{
        defaultValue: 0,
        getter: function(l:State,data:Any):Int{
          Lua.pushstring(l,data);
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
          Lua.pushstring(l,data);
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
