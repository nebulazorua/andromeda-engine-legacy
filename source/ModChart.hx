package;
import flixel.system.FlxAssets.FlxShader;
import openfl.filters.ShaderFilter;
import openfl.filters.BitmapFilter;
import Shaders;
class ModChart {
  private var playState:PlayState;
  private var camShaders=[];
  private var hudShaders=[];
  public function new(playState:PlayState){
    this.playState=playState;
  }
  public function addCamEffect(effect:ShaderEffect){
    camShaders.push(effect);
    var newCamEffects:Array<BitmapFilter>=[]; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
    for(i in camShaders){
      newCamEffects.push(new ShaderFilter(i.shader));
    }
    @:privateAccess
    playState.camGame.setFilters(newCamEffects);
  }

  public function removeCamEffect(effect:ShaderEffect){
    camShaders.remove(effect);
    var newCamEffects:Array<BitmapFilter>=[];
    for(i in camShaders){
      newCamEffects.push(new ShaderFilter(i.shader));
    }
    @:privateAccess
    playState.camGame.setFilters(newCamEffects);
  }

  public function addHudEffect(effect:ShaderEffect){
    hudShaders.push(effect);
    var newCamEffects:Array<BitmapFilter>=[];
    for(i in camShaders){
      newCamEffects.push(new ShaderFilter(i.shader));
    }
    @:privateAccess
    playState.camHUD.setFilters(newCamEffects);
  }
  public function removeHudEffect(effect:ShaderEffect){
    hudShaders.remove(effect);
    var newCamEffects:Array<BitmapFilter>=[];
    for(i in camShaders){
      newCamEffects.push(new ShaderFilter(i.shader));
    }
    @:privateAccess
    playState.camHUD.setFilters(newCamEffects);
  }


  public function update(elapsed:Float){

  }
}
