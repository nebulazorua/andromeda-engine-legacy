package;

import flixel.math.FlxMath;
import Options;
import haxe.Json;
import haxe.format.JsonParser;
import haxe.macro.Type;
import lime.utils.Assets;

typedef JudgementInfo =
{
	var comboBreakJudgements:Array<String>;
	var judgementHealth:Any;
	var judgementAccuracy:Any;
	var judgementScores:Any;
	var judgementWindows:Any;
	var judgements:Array<String>;
	@:optional var wifeZeroPoint:Null<Float>;
}

class JudgementData {
	public var comboBreakJudgements:Array<String>=[];
	public var judgementHealth:Map<String,Int>=[];
	public var judgementAccuracy:Map<String,Int>=[];
	public var judgementScores:Map<String,Int>=[];
	public var judgementWindows:Map<String,Int>=[];
	public var judgements:Array<String>=[];
	public var judgementWindowsOrder:Array<String>=[];
	public var wifeZeroPoint:Float = 65;
	public function new(info:JudgementInfo){
		for(judge in info.judgements){
			if(EngineData.validJudgements.contains(judge))
				if(judge!='epic' || judge=='epic' && EngineData.options.useEpic)
					judgements.push(judge);

		}
		for(judge in info.comboBreakJudgements){
			comboBreakJudgements.push(judge);
		}
		for(name in ["Health","Accuracy","Scores","Windows"]){
			var data = Reflect.field(info,'judgement${name}');
			var thisData = Reflect.field(this,'judgement${name}');
			for(field in Reflect.fields(data)){
				if(judgements.contains(field) || field=='miss'){
					var val = Reflect.field(data,field);
					thisData.set(field,val);
				}
			}
		}


		for(judge in judgementWindows.keys()){
			judgementWindowsOrder.push(judge);
		}
		judgementWindowsOrder.sort((a,b)->Std.int(judgementWindows.get(a)-judgementWindows.get(b)));

		wifeZeroPoint=info.wifeZeroPoint==null?judgementWindows.get(judgementWindowsOrder[judgementWindowsOrder.length-1])/2:info.wifeZeroPoint;
	}
}

class JudgementManager
{
	public static var judgementDisplayNames:Map<String,String> = [
		"epic"=>"Epic",
		"sick"=>"Sick",
		"good"=>"Good",
		"bad"=>"Bad",
		"shit"=>"Shit",
		"miss"=>"Miss"
	];
  var judgeData:JudgementData;
	var highestAcc:Float = 0;
	public static var rawJudgements:AnonType;
	public static var defaultJudgement = new JudgementData(EngineData.defaultJudgementData);
	public var judgementCounter:Map<String,Int> = [];
	public static function dataExists(name:String){
		rawJudgements = Json.parse(Assets.getText(Paths.json("judgements")));
		if(rawJudgements!=null){
			return Reflect.hasField(rawJudgements,name);
		}
		return false;
	}

	public function hasJudge(name:String){
		return judgeData.judgementWindows.exists(name);
	}

	public function getWifeZero(){
		return judgeData.wifeZeroPoint;
	};

	public static function getDataByName(name:String){
		rawJudgements = Json.parse(Assets.getText(Paths.json("judgements")));
		if(rawJudgements!=null){
			if(Reflect.hasField(rawJudgements,name)){
				return new JudgementData(Reflect.field(rawJudgements,name));
			}
		}
		return defaultJudgement;
	}

	public function getHighestWindow(){
		return getJudgementWindow(judgeData.judgementWindowsOrder[judgeData.judgementWindowsOrder.length-1]);
	}

	public function getLowestWindow(){
		return getJudgementWindow(judgeData.judgementWindowsOrder[0]);
	}

	public function getHighestAccJudgement(){
		var n:Null<Float>=null;
		var name:String='epic';
		for(judgement in judgeData.judgementAccuracy.keys()){
			var acc = judgeData.judgementAccuracy.get(judgement);
			if(n==null || acc>n){
				n=acc;
				name=judgement;
			}
		}
		return name;
	}


  public function new(data:JudgementData){
    judgeData=data;
		judgeData.judgements.insert(judgeData.judgements.length,"miss");
		for(judge in getJudgements()){
			judgementCounter.set(judge,0);
		}
		judgementCounter.set("miss",0);

		highestAcc=judgeData.judgementAccuracy.get(getHighestAccJudgement());
  }

	public function getJudgementWindow(judge:String):Float{
		if(judgeData.judgementWindows.exists(judge)){
			return judgeData.judgementWindows.get(judge);
		}

		return judgeData.judgementWindows.get('shit');
	}

  public function getJudgements():Array<String>{
    return judgeData.judgements;
  }

  public function shouldComboBreak(judge:String):Bool{
		for(judgement in judgeData.comboBreakJudgements){
			if(judgement==judge){
				return true;
			}
		}

    return judge=='miss'?true:false;
  }

  public function getJudgementHealth(judge:String):Float{
		if(judgeData.judgementHealth.exists(judge)){
			return (judgeData.judgementHealth.get(judge)/100)*2;
		}
    return (judgeData.judgementHealth.get("miss")/100)*2;
  }

  public function getJudgementAccuracy(judge:String):Float{
		if(judgeData.judgementAccuracy.exists(judge)){
			return judgeData.judgementAccuracy.get(judge)/highestAcc;
		}
    return judgeData.judgementAccuracy.get("miss")/highestAcc;
  }

  public function getJudgementScore(judge:String):Int{
		if(judgeData.judgementScores.exists(judge)){
			return judgeData.judgementScores.get(judge);
		}
    return judgeData.judgementScores.get("miss");
  }

  public function determine(noteDiff:Float):String{
    var noteDiff = Math.abs(noteDiff);
    for(judgeOrder in 0...judgeData.judgementWindowsOrder.length){
			var judgement = judgeData.judgementWindowsOrder[judgeOrder];
      var window = judgeData.judgementWindows.get(judgement);
      if(noteDiff<=window){
        return judgement;
			}
    }
    return "miss";
  }

}
