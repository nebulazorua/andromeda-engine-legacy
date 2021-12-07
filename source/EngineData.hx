package;
import flixel.system.debug.log.LogStyle;
using StringTools;
import JudgementManager;
class EngineData {
  public static var LUAERROR:LogStyle = new LogStyle("[MODCHART] ", "FF8888", 12, false, false, false, null, true);
  public static var characters:Array<String> = [];
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
  public static var createThread=false;
  public static var options:Options;
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
