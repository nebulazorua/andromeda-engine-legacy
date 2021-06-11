package;

// STOLEN FROM HAXEFLIXEL DEMO LOL
import flixel.system.FlxAssets.FlxShader;
import openfl.display.BitmapData;
import openfl.display.ShaderInput;
import openfl.utils.Assets;

typedef ShaderEffect = {
  var shader:Dynamic;
}

class BuildingEffect {
  public var shader:BuildingShader = new BuildingShader();
  public function new(){
    shader.alphaShit.value = [0];
  }
  public function addAlpha(alpha:Float){
    trace(shader.alphaShit.value[0]);
    shader.alphaShit.value[0]+=alpha;
  }
  public function setAlpha(alpha:Float){
    shader.alphaShit.value[0]=alpha;
  }

}

class BuildingShader extends FlxShader
{
  @:glFragmentSource('
    #pragma header
    uniform float alphaShit;
    void main()
    {

      vec4 color = flixel_texture2D(bitmap,openfl_TextureCoordv);
      if (color.a > 0.0)
        color-=alphaShit;

      gl_FragColor = color;
    }
  ')
  public function new()
  {
    super();
  }
}

class VCRDistortionEffect
{
  public var shader:VCRDistortionShader = new VCRDistortionShader();
  public function new(){
    shader.iTime.value = [0];
    shader.vignetteOn.value = [1];
    shader.perspectiveOn.value = [1];
    shader.distortionOn.value = [1];
    shader.scanlinesOn.value = [1];
    shader.vignetteMoving.value = [1];
    shader.glitchModifier.value = [1];
  }

  public function update(elapsed:Float){
    shader.iTime.value[0] += elapsed;
  }

  public function setVignette(state:Bool){
    shader.vignetteOn.value[0] = state?1:0;
  }

  public function setPerspective(state:Bool){
    shader.perspectiveOn.value[0] = state?1:0;
  }

  public function setGlitchModifier(modifier:Float){
    shader.glitchModifier.value[0] = modifier;
  }

  public function setDistortion(state:Bool){
    shader.distortionOn.value[0] = state?1:0;
  }

  public function setScanlines(state:Bool){
    shader.scanlinesOn.value[0] = state?1:0;
  }

  public function setVignetteMoving(state:Bool){
    shader.vignetteMoving.value[0] = state?1:0;
  }
}

class CRTShader extends FlxShader // https://github.com/crosire/reshade-shaders/blob/master/Shaders/CRT.fx
{
  @:glFragmentSource('
    uniform float Amount = 1.0;
    uniform float Resolution = 1.15;
    uniform float Gamma = 2.4;
    uniform float MonitorGamma = 2.2;
    uniform float Brightness = .9;
    uniform int ScanlineIntensity = 2;
    uniform bool ScanlineGaussian = true;
    uniform bool Curvature = true;
    uniform float CurvatureRadius = 1.5;
    uniform float CornerSize = 0.01;
    uniform float ViewerDistance = 2.0;
    uniform float2 Angle = 0.0;
    uniform float Overscan = 1.01;
    uniform bool Oversample = true;

  ')
  public function new()
  {
    super();
  }
}

class VCRDistortionShader extends FlxShader // https://www.shadertoy.com/view/ldjGzV
{
  @:glFragmentSource('
    #pragma header

    uniform float iTime;
    uniform int vignetteOn;
    uniform int perspectiveOn;
    uniform int distortionOn;
    uniform int scanlinesOn;
    uniform int vignetteMoving;
    uniform float glitchModifier;

    float onOff(float a, float b, float c)
    {
    	return step(c, sin(iTime + a*cos(iTime*b)));
    }

    float ramp(float y, float start, float end)
    {
    	float inside = step(start,y) - step(end,y);
    	float fact = (y-start)/(end-start)*inside;
    	return (1.-fact) * inside;

    }

    vec4 getVideo(vec2 uv)
      {
      	vec2 look = uv;
        if(distortionOn==1){
        	float window = 1./(1.+20.*(look.y-mod(iTime/4.,1.))*(look.y-mod(iTime/4.,1.)));
        	look.x = look.x + (sin(look.y*10. + iTime)/50.*onOff(4.,4.,.3)*(1.+cos(iTime*80.))*window)*(glitchModifier*2);
        	float vShift = 0.4*onOff(2.,3.,.9)*(sin(iTime)*sin(iTime*20.) +
        										 (0.5 + 0.1*sin(iTime*200.)*cos(iTime)));
        	look.y = mod(look.y + vShift*glitchModifier, 1.);
        }
      	vec4 video = flixel_texture2D(bitmap,look);
      	return video;
      }

    vec2 screenDistort(vec2 uv)
    {
      if(perspectiveOn==1){
        uv -= vec2(.5,.5);
        uv = uv*1.2*(1./1.2+2.*uv.x*uv.x*uv.y*uv.y);
        uv += vec2(.5,.5);
      }
    	return uv;
    }

    void main()
    {
    	vec2 uv = openfl_TextureCoordv;
    	uv = screenDistort(uv);
    	vec4 video = getVideo(uv);
      float vigAmt = 1.0;
      if(vignetteMoving==1)
    	  vigAmt = 3.+.3*sin(iTime + 5.*cos(iTime*5.));

    	float vignette = (1.-vigAmt*(uv.y-.5)*(uv.y-.5))*(1.-vigAmt*(uv.x-.5)*(uv.x-.5));

      if(vignetteOn==1)
    	 video *= vignette;

      if(scanlinesOn==1){
        float scanline = sin(uv.y*800.0)*0.04;
	      video -= scanline;
     }

    	gl_FragColor = video;
    }
  ')
  public function new()
  {
    super();
  }
}
