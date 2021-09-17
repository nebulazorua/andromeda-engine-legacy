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
	var judgementHealth:AnonType;
	var judgementAccuracy:AnonType;
	var judgementScores:AnonType;
	var judgementWindows:AnonType;
	var judgements:Array<String>;
}

class JudgementData {
	public var comboBreakJudgements:Array<String>=[];
	public var judgementHealth:Map<String,Int>=[];
	public var judgementAccuracy:Map<String,Int>=[];
	public var judgementScores:Map<String,Int>=[];
	public var judgementWindows:Map<String,Int>=[];
	public var judgements:Array<String>=[];
	public var judgementWindowsOrder:Array<String>=[];
	public function new(info:JudgementInfo){
		for(judge in info.judgements){
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
	}
}

class JudgementManager
{
  var judgeData:JudgementData;
	public static var rawJudgements:AnonType;
	public static var defaultJudgement = new JudgementData(Json.parse('{
			"comboBreakJudgements":[],
			"judgementHealth": {"sick":1.2,"good":1.2, "bad":1.2, "shit":1.2,"miss":-2.375 },
			"judgements": ["sick","good","bad","shit"],
			"judgementAccuracy": {"sick": 100, "good":50, "bad": -25, "shit": -50, "miss": -100},
			"judgementScores": {"sick":350,"good":200,"bad":100,"shit":50,"miss":-10},
			"judgementWindows": {"sick":32, "good":123, "bad":148, "shit":166}
	}'));// vanilla
	public var judgementCounter:Map<String,Int> = [];
	public static function dataExists(name:String){
		rawJudgements = Json.parse(Assets.getText(Paths.json("judgements")));
		if(rawJudgements!=null){
			return Reflect.hasField(rawJudgements,name);
		}
		return false;
	}
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
		var n:Null<Float>=null;
		for(judgement in judgeData.judgementWindows.keys()){
			var window = judgeData.judgementWindows.get(judgement);
			if(n==null || window>n){
				n=window;
			}
		}
		return n==null?166:n;
	}

  public function new(data:JudgementData){
    judgeData=data;
		judgeData.judgements.insert(judgeData.judgements.length,"miss");
		for(judge in getJudgements()){
			judgementCounter.set(judge,0);
		}
		judgementCounter.set("miss",0);
  }

	public function getJudgementWindow(judge:String):Float{
		for(judgement in judgeData.judgementWindows.keys()){
			if(judgement==judge)
				return judgeData.judgementWindows.get(judgement);
		}
		return judgeData.judgementWindows.get('shit');
	}

  public function getJudgements():Array<String>{
    return judgeData.judgements;
  }

  public function shouldComboBreak(judge:String):Bool{
		trace(judge);
    for(judgement in judgeData.comboBreakJudgements){
      if(judgement==judge){
        return true;
      }
    }
    return judge=="miss"?true:false;
  }

  public function getJudgementHealth(judge:String):Float{
    for(judgement in judgeData.judgementHealth.keys()){
      if(judgement==judge){
        return (judgeData.judgementHealth.get(judgement)/100)*2;
      }
    }
    return (judgeData.judgementHealth.get("miss")/100)*2;
  }

  public function getJudgementAccuracy(judge:String):Float{
    for(judgement in judgeData.judgementAccuracy.keys()){
      if(judgement==judge){
        return judgeData.judgementAccuracy.get(judgement)/100;
      }
    }
    return judgeData.judgementAccuracy.get("miss")/100;
  }

  public function getJudgementScore(judge:String):Int{
    for(judgement in judgeData.judgementScores.keys()){
      if(judgement==judge){
        return judgeData.judgementScores.get(judgement);
      }
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
