package;
import flixel.system.debug.log.LogStyle;
using StringTools;
import JudgementManager;
import flixel.tweens.FlxEase;

enum EventArgType {
  Checkbox;
  Text;
  Dropdown;
  CharacterDropdown;
  Number;
  SteppedNumber;
}

typedef EventArg = {
  var name:String;
  var type:EventArgType;
  @:optional var description:String;
  @:optional var getDefaultValue:Void->Dynamic;
  @:optional var defaultVal:Dynamic;


  @:optional var dropdownValues:Array<String>; // only for 'Dropdown' EventArgType
  @:optional var step:Float;  // only for 'SteppedNumber' EventArgType
  @:optional var min:Float; // for 'SteppedNumber' and 'Number' EventArgType
  @:optional var max:Float; // for 'SteppedNumber' and 'Number' EventArgType

  @:optional var getDropdownValues:Void->Dynamic; // only for 'Dropdown' EventArgType
  // used so you dont have to hardcode shit like CharacterDropdown is, and that only is because its used fairly often
}

typedef EventInfo = {
  var name:String;
  var arguments:Array<EventArg>;
  @:optional var description:String;
}

class EngineData {
  // should there be a better way to create these? possibly
  // but this works for now lmao
  public static var events:Array<EventInfo> = [
    {
      name: "",
      arguments: [

      ]
    },
    {
      name: "Change Character",
      arguments: [
        {
          name: "Character",
          type: EventArgType.Dropdown,
          defaultVal: "player",
          dropdownValues: ["player","opponent","gf"]
        },
        {
          name: "New Character",
          type: EventArgType.CharacterDropdown
        }
      ]
    },
    {
      name: "Hey",
      arguments: []
    },
    {
      name: "Play Anim",
      arguments: [
        {
          name: "Character",
          type: EventArgType.Dropdown,
          defaultVal: "player",
          dropdownValues: ["player","opponent","gf"]
        },
        {
          name: "Animation",
          type: EventArgType.Text
        },
        {
          name: "Duration in seconds",
          type: EventArgType.SteppedNumber,
          step: 0.05,
          defaultVal: 1,
        }
      ]
    },
    {
      name: "Scroll Velocity",
      arguments: [
        {
          name: "Type",
          type: EventArgType.Dropdown,
          defaultVal: "mult",
          dropdownValues: ["mult", "constant"]
        },
        {
          name: "Value",
          type: EventArgType.SteppedNumber,
          step: 0.05,
          defaultVal: 1,
        }
      ]
    },
    {
      name: "Set Modifier",
      arguments: [
        {
          name: "Modifier",
          type: EventArgType.Text
        },
        {
          name: "Value",
          type: EventArgType.SteppedNumber,
          step: 1,
          defaultVal: 0,
        },
        {
          name: "Player",
          type: EventArgType.Dropdown,
          defaultVal: "player",
          dropdownValues: ["player","opponent","both"]
        },
      ]
    },
    //queueEase(step:Float, endStep:Float, modName:String, percent:Float, style:String='linear', player:Int=-1, ?startVal:Float)
    {
      name: "Ease Modifier",
      // TODO: Function which lets you set how to show the event's length
      arguments: [
        {
          name: "Modifier",
          type: EventArgType.Text
        },
        {
          name: "Value",
          type: EventArgType.SteppedNumber,
          step: 1,
          defaultVal: 0,
        },
        {
          name: "Length in steps",
          type: EventArgType.SteppedNumber,
          step: 1,
          defaultVal: 4,
        },
        {
          name: "Ease",
          type: EventArgType.Dropdown,
          defaultVal: "linear",
          getDropdownValues: function(){
            var eases:Array<String> = ["sine","quad","cube","quart","quint","expo","circ","back","elastic","bounce","smoothStep","smootherStep"];
            var vals:Array<String> = ["linear"];
            for(func in eases){
              vals.push('${func}Out');
              vals.push('${func}InOut');
              vals.push('${func}In');
            }
            return vals;
          }
        },
        {
          name: "Player",
          type: EventArgType.Dropdown,
          defaultVal: "player",
          dropdownValues: ["player","opponent","both"]
        },
      ]
    },
    {
      name: "Camera Zoom",
      arguments: [
        {
          name: "Zoom",
          type: EventArgType.SteppedNumber,
          step: 0.01,
          min: 0,
          defaultVal: 1,
        }
      ]
    },
    {
      name: "Camera Zoom Bump",
      arguments: [
        {
          name: "Game Zoom",
          type: EventArgType.SteppedNumber,
          step: 0.01,
          min: 0,
          defaultVal: 0.02,
        },
        {
          name: "HUD Zoom",
          type: EventArgType.SteppedNumber,
          step: 0.01,
          min: 0,
          defaultVal: 0.02,
        },
      ]
    },

    {
      name: "Set Cam Pos",
      arguments: [
        {
          name: "X",
          type: EventArgType.SteppedNumber,
          step: 5,
          defaultVal: 0,
        },
        {
          name: "Y",
          type: EventArgType.SteppedNumber,
          step: 5,
          defaultVal: 0,
        }
      ]
    },

    {
      name: "Screen Shake",
      arguments: [
        {
          name: "Intensity",
          type: EventArgType.SteppedNumber,
          step: 0.01,
          defaultVal: 0.01,
          min: 0
        },
        {
          name: "Duration",
          type: EventArgType.SteppedNumber,
          step: 0.01,
          defaultVal: 0.5,
          min: 0
        },
        {
          name: "Axes",
          type: EventArgType.Dropdown,
          defaultVal: "XY",
          dropdownValues: ["XY","X","Y"]
        }
      ]
    },

    {
      name: "GF Speed",
      arguments: [
        {
          name: "Step",
          type: EventArgType.SteppedNumber,
          step: 1,
          defaultVal: 4,
          min: 0
        }
      ]
    },

    {
      name: "Set Cam Focus",
      arguments: [
        {
          name: "Focus",
          type: EventArgType.Dropdown,
          defaultVal: "player",
          dropdownValues: ["player","opponent","gf","center","none"]
        },
      ]
    },


    {
      name: "Camera Offset",
      arguments: [
        {
          name: "X",
          type: EventArgType.SteppedNumber,
          step: 5,
          defaultVal: 0,
        },
        {
          name: "Y",
          type: EventArgType.SteppedNumber,
          step: 5,
          defaultVal: 0,
        }
      ]
    },

    {
      name: "Camera Zoom Interval",
      arguments: [
        {
          name: "Beat",
          type: EventArgType.SteppedNumber,
          step: 1,
          defaultVal: 4,
          min: 1,
        },
        {
          name: "Zoom",
          type: EventArgType.SteppedNumber,
          step: 0.01,
          min: 0,
          defaultVal: 0.02,
        }
      ]
    },

    {
      name: "Custom",
      arguments: [
        {
          name: "Value 1",
          type: EventArgType.Text
        },
        {
          name: "Value 2",
          type: EventArgType.Text
        }
      ]
    },
  ];
  public static var noteTypes:Array<String> = ["default","alt","mine"];
  public static var validJudgements:Array<String> = ["epic","sick","good","bad","shit","miss"];
  public static var defaultJudgementData:JudgementInfo = {
    comboBreakJudgements: ["shit"],
    judgementHealth: {sick: 0.8, good: 0.4, bad: 0, shit:-2, miss: -5},
    judgements: ["sick","good","bad","shit"],
    judgementAccuracy: {sick: 100, good: 80, bad: 50, shit: -75, miss: -240},
    judgementScores: {sick:350, good:100, bad:0, shit:-50, miss:-100},
    judgementWindows: {sick: 43, good: 85, bad: 126, shit: 166, miss: 180}
    // miss window acts as a sort of "antimash"
  };
  public static var weeksUnlocked:Array<Bool>=[true,true,true,true,true,true];
  public static var mustUnlockWeeks:Bool=false; // TODO: make this work
  public static var weekData:Array<WeekData> = [
    new WeekData("Funkin' Virgin",0,'',[
      new SongData("Tutorial","gf",0),
    ]),
    new WeekData("DADDY DEAREST",1,'dad',[
      "Bopeebo",
      "Fresh",
      "Dadbattle"
    ]),
    new WeekData("Spooky Month",2,'spooky',[
      "Spookeez",
      "South",
      new SongData("Monster","monster",2)
    ]),
    new WeekData("Pico",3,'pico',[
      "Pico",
      new SongData("Philly Nice","pico",3,"philly-nice"),
      "Blammed"
    ]),
    new WeekData("MOMMY MUST MURDER",4,'mom',[
      new SongData("Satin Panties","mom",4,"satin-panties"),
      "High",
      "MILF"
    ]),
    new WeekData("RED SNOW",5,'parents-christmas',[
      "Cocoa",
      "Eggnog",
      new SongData("Winter Horrorland","monster",5,"winter-horrorland"),
    ]),
    new WeekData("hating simulator ft. moawling",6,'senpai',[
      "Senpai",
      "Roses",
      new SongData("Thorns","spirit",6),
    ]),
  ];

  // DON'T EDIT BEYOND THIS POINT!
  public static var LUAERROR:LogStyle = new LogStyle("[MODCHART] ", "FF8888", 12, false, false, false, null, true);
  public static var characters:Array<String> = []; // DON'T EDIT!
  public static var createThread=false; // DON'T EDIT!
  public static var options:Options; // DON'T EDIT!
}


class SongData {
  public var displayName:String = 'Tutorial';
  public var chartName:String = 'tutorial';
  public var freeplayIcon:String = 'gf';
  public var weekNum:Int = 0;
  public var loadingPath:String = '';
  public function new(name:String='Tutorial',freeplayIcon:String='gf',weekNum:Int=0,?chartName:String,?path:String){
    if(chartName==null){
      chartName=name.replace(" ","-").toLowerCase();
    }

    if(path==null){
      path = 'week${weekNum}';
    }
    loadingPath=path;

    this.displayName=name;
    this.freeplayIcon=freeplayIcon;
    this.weekNum=weekNum;
    this.chartName=chartName;
  }

  public function formatDifficulty(diffNum:Int=0){
    var name='';
    switch (diffNum){
      case 0:
        name = '${chartName}-easy';
      case 1:
        name = '${chartName}';
      case 2:
        name = '${chartName}-hard';
    };
    return name;
  }
}

class WeekData {
  public var songs:Array<SongData>=[];
  public var character:String = '';
  public var protag:String = 'bf';
  public var lover:String='gf';
  public var weekNum:Int = 0;
  public var loadingPath:String = '';
  public var name:String = 'Template';

  public function new(name:String='Template',weekNum:Int=0,character:String='',songs:Array<Dynamic>,?protag:String='bf',?lover:String='gf',?path:String){
    if(path==null){
      path = 'week${weekNum}';
    }
    var songData:Array<SongData>=[];
    for(stuff in songs){
      switch(Type.typeof(stuff)){
        case TClass(String):
          songData.push(new SongData(stuff,character,weekNum,null,path));
        case TClass(SongData):
          songData.push(stuff);
        default:
          trace('cannot handle ${Type.typeof(stuff)}');
      }
    }
    loadingPath=path;

    this.protag=protag;
    this.lover=lover;
    this.songs=songData;
    this.name=name;
    this.weekNum=weekNum;
    this.character=character;
  }

  public function getByChartName(name:String):Null<SongData>{
    for(data in songs){
      if(data.chartName==name){
        return data;
      }
    }
    return null;
  }

  public function getCharts(){
    var charts=[];
    for(data in songs){
      charts.push(data.chartName.toLowerCase() );
    }
    return charts;
  }
}
