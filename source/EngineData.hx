package;

using StringTools;

class SongData {
  public var displayName:String = 'Tutorial';
  public var chartName:String = 'tutorial';
  public var freeplayIcon:String = 'gf';
  public var weekNum:Int = 0;

  public function new(name:String='Tutorial',freeplayIcon:String='gf',weekNum:Int=0,?chartName:String){
    if(chartName==null){
      chartName=name.replace(" ","-").toLowerCase();
    }

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
  public var name:String = 'Template';

  public function new(name:String='Template',weekNum:Int=0,character:String='',songs:Array<Dynamic>,?protag='bf',?lover='gf'){
    var songData:Array<SongData>=[];
    for(stuff in songs){
      switch(Type.typeof(stuff)){
        case TClass(String):
          songData.push(new SongData(stuff,character,weekNum));
        case TClass(SongData):
          songData.push(stuff);
        default:
      }
    }
    this.protag=protag;
    this.lover=lover;
    this.songs=songData;
    this.name=name;
    this.weekNum=weekNum;
    this.character=character;
  }

  public function getCharts(){
    var charts=[];
    for(data in songs){
      charts.push(data.chartName.toLowerCase() );
    }
    return charts;
  }
}

class EngineData {
  public static var weeksUnlocked:Array<Bool>=[true,true,true,true,true,true];
  public static var mustUnlockWeeks:Bool=false;
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
