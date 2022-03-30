package;

// STOLEN FROM HAXEFLIXEL DEMO LOL
import flixel.system.FlxAssets.FlxShader;
import openfl.display.BitmapData;
import openfl.display.ShaderInput;
import openfl.utils.Assets;
import flixel.FlxG;
import openfl.Lib;
import flixel.math.FlxPoint;

using StringTools;
typedef ShaderEffect = {
  var shader:Dynamic;
}

class NoteEffect {
  public var shader: NoteShader = new NoteShader();
  public function new(){
    shader.flash.value = [0];
  }

  public function setFlash(val: Float){
    shader.flash.value=[val];
  }

}


class ColorSwap {
  public var shader:ColorSwapShader = new ColorSwapShader();
  public var hasOutline(default, set):Bool = false;
  public var hue(default, set):Float = 0;
  public var sat(default, set):Float = 0;
  public var val(default, set):Float = 0;

  private function set_hasOutline(value:Bool){
    hasOutline=value;
    shader.awesomeOutline.value[0]=value;
    return hasOutline;
  }

  private function set_hue(value:Float){
    hue=value;
    shader.hue.value[0]=value;
    return hue;
  }

  private function set_sat(value:Float){
    sat=value;
    shader.sat.value[0]=value;
    return sat;
  }

  private function set_val(value:Float){
    val=value;
    shader.val.value[0]=value;
    return val;
  }

  public function new(){
    shader.hue.value = [hue];
    shader.sat.value = [sat];
    shader.val.value = [val];
    shader.awesomeOutline.value = [hasOutline];
  }
}

class NoteShader extends FlxShader
{
  @:glFragmentSource('
    #pragma header
    uniform float flash;

    float scaleNum(float x, float l1, float h1, float l2, float h2){
        return ((x - l1) * (h2 - l2) / (h1 - l1) + l2);
    }

    void main()
    {
        vec4 col = flixel_texture2D(bitmap, openfl_TextureCoordv);
        vec4 newCol = col;
        if(flash!=0.0 && col.a>0.0)
          newCol = mix(col,vec4(1.0,1.0,1.0,col.a),flash) * col.a;

        gl_FragColor = newCol;
    }
  ')
  public function new()
  {
    super();
  }

}

class ColorSwapShader extends FlxShader
{
  @:glFragmentSource('
    #pragma header
    uniform float hue;
    uniform float sat;
    uniform float val;
    uniform bool awesomeOutline;


    const float offset = 1.0 / 128.0;



    vec3 normalizeColor(vec3 color)
    {
        return vec3(
            color[0] / 255.0,
            color[1] / 255.0,
            color[2] / 255.0
        );
    }

    vec3 rgb2hsv(vec3 c)
    {
        vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
        vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
        vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

        float d = q.x - min(q.w, q.y);
        float e = 1.0e-10;
        return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
    }

    vec3 hsv2rgb(vec3 c)
    {
        vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
        vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
        return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
    }

    void main()
    {
        vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);

        vec4 swagColor = vec4(rgb2hsv(vec3(color[0], color[1], color[2])), color[3]);

        // [0] is the hue???
        swagColor[0] += hue;
        swagColor[1] += sat;
        swagColor[2] *= (1.0+val);

        // swagColor[1] += uTime;

        if(swagColor[1] < 0.0)
  			{
  				swagColor[1] = 0.0;
  			}
  			else if(swagColor[1] > 1.0)
  			{
  				swagColor[1] = 1.0;
  			}

        color = vec4(hsv2rgb(vec3(swagColor[0], swagColor[1], swagColor[2])), swagColor[3]);


        if (awesomeOutline)
        {
             // Outline bullshit?
            vec2 size = vec2(3, 3);

            if (color.a <= 0.5) {
                float w = size.x / openfl_TextureSize.x;
                float h = size.y / openfl_TextureSize.y;

                if (flixel_texture2D(bitmap, vec2(openfl_TextureCoordv.x + w, openfl_TextureCoordv.y)).a != 0.
                || flixel_texture2D(bitmap, vec2(openfl_TextureCoordv.x - w, openfl_TextureCoordv.y)).a != 0.
                || flixel_texture2D(bitmap, vec2(openfl_TextureCoordv.x, openfl_TextureCoordv.y + h)).a != 0.
                || flixel_texture2D(bitmap, vec2(openfl_TextureCoordv.x, openfl_TextureCoordv.y - h)).a != 0.)
                    color = vec4(1.0, 1.0, 1.0, 1.0);
            }


        }



        gl_FragColor = color;


        /*
        if (color.a > 0.5)
            gl_FragColor = color;
        else
        {
            float a = flixel_texture2D(bitmap, vec2(openfl_TextureCoordv + offset, openfl_TextureCoordv.y)).a +
                      flixel_texture2D(bitmap, vec2(openfl_TextureCoordv, openfl_TextureCoordv.y - offset)).a +
                      flixel_texture2D(bitmap, vec2(openfl_TextureCoordv - offset, openfl_TextureCoordv.y)).a +
                      flixel_texture2D(bitmap, vec2(openfl_TextureCoordv, openfl_TextureCoordv.y + offset)).a;
            if (color.a < 1.0 && a > 0.0)
                gl_FragColor = vec4(0.0, 0.0, 0.0, 0.8);
            else
                gl_FragColor = color;
        } */
      }
  ')
  public function new()
  {
    super();
  }
}

// https://www.shadertoy.com/view/WtGXDD

class RaymarchEffect {
  var rad = Math.PI/180;
  public var shader:RaymarchShader = new RaymarchShader();
  public function new(){
    shader.yaw.value = [0];
    shader.pitch.value = [0];
  }
  public function addYaw(yaw:Float){
    shader.yaw.value[0]+=yaw*rad;
  }
  public function setYaw(yaw:Float){
    shader.yaw.value[0]=yaw*rad;
  }

  public function addPitch(pitch:Float){
    shader.pitch.value[0]+=pitch*rad;
  }
  public function setPitch(pitch:Float){
    shader.pitch.value[0]=pitch*rad;
  }
}

class RaymarchShader extends FlxShader {
  @:glFragmentSource('
    #pragma header

    // "RayMarching starting point"
    // Modified by Nebula_Zorua
    // by Martijn Steinrucken aka The Art of Code/BigWings - 2020
    // The MIT License
    // Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, moy, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    // Email: countfrolic@gmail.com
    // Twitter: @The_ArtOfCode
    // YouTube: youtube.com/TheArtOfCodeIsCool
    // Facebook: https://www.facebook.com/groups/theartofcode/
    //
    // You can use this shader as a template for ray marching shaders

    #define MAX_STEPS 100
    #define MAX_DIST 100.
    #define SURF_DIST 0.01

    uniform float yaw;
    uniform float pitch;

    mat2 Rot(float a) {
        float s=sin(a), c=cos(a);
        return mat2(c, -s, s, c);
    }

    float sdBox(vec3 p, vec3 s) {
        p = abs(p)-s;
    	return length(max(p, 0.))+min(max(p.x, max(p.y, p.z)), 0.);
    }

    float GetDist(vec3 p) {
        float d = sdBox(p, vec3(1.,1.,0));

        return d;
    }



    float RayMarch(vec3 ro, vec3 rd) {
    	float dO=0.;

        for(int i=0; i<MAX_STEPS; i++) {
        	vec3 p = ro + rd*dO;
            float dS = GetDist(p);
            dO += dS;
            if(dO>MAX_DIST || abs(dS)<SURF_DIST) break;
        }

        return dO;
    }

    vec3 GetNormal(vec3 p) {
    	float d = GetDist(p);
        vec2 e = vec2(.001, 0);

        vec3 n = d - vec3(
            GetDist(p-e.xyy),
            GetDist(p-e.yxy),
            GetDist(p-e.yyx));

        return normalize(n);
    }

    vec3 GetRayDir(vec2 uv, vec3 p, vec3 l, float z) {
        vec3 f = normalize(l-p),
            r = normalize(cross(vec3(0,1,0), f)),
            u = cross(f,r),
            c = f*z,
            i = c + uv.x*r + uv.y*u,
            d = normalize(i);
        return d;
    }

    void main()
    {
        vec2 uv = openfl_TextureCoordv - vec2(0.5);
        vec3 ro = vec3(0, 0., -2);

        ro.xz *= Rot(yaw);
        ro.yz *= Rot(pitch);

        vec3 rd = GetRayDir(uv, ro, vec3(0,0.,0.), 1.);
        vec4 col = vec4(0);

        float d = RayMarch(ro, rd);

        if(d<MAX_DIST) {
            vec3 p = ro + rd * d;
            vec3 n = GetNormal(p);
            uv = vec2(p.x,p.y) * .5 + vec2(0.5);
            col = flixel_texture2D(bitmap,uv);
        }
        gl_FragColor = col;
    }
  ')
  public function new()
  {
    super();
  }
}

class BuildingEffect {
  public var shader:BuildingShader = new BuildingShader();
  public function new(){
    shader.alphaShit.value = [0];
  }
  public function addAlpha(alpha:Float){
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
    shader.vignetteOn.value = [true];
    shader.perspectiveOn.value = [true];
    shader.distortionOn.value = [true];
    shader.scanlinesOn.value = [true];
    shader.vignetteMoving.value = [true];
    shader.noiseOn.value = [true];
    shader.glitchModifier.value = [1];
    shader.iResolution.value = [Lib.current.stage.stageWidth,Lib.current.stage.stageHeight];
    var noise = Assets.getBitmapData(Paths.image("noise2"));
    shader.noiseTex.input = noise;
  }

  public function update(elapsed:Float){
    shader.iTime.value[0] += elapsed;
    shader.iResolution.value = [Lib.current.stage.stageWidth,Lib.current.stage.stageHeight];
  }

  public function setVignette(state:Bool){
    shader.vignetteOn.value[0] = state;
  }

  public function setNoise(state:Bool){
    shader.noiseOn.value[0] = state;
  }

  public function setPerspective(state:Bool){
    shader.perspectiveOn.value[0] = state;
  }

  public function setGlitchModifier(modifier:Float){
    shader.glitchModifier.value[0] = modifier;
  }

  public function setDistortion(state:Bool){
    shader.distortionOn.value[0] = state;
  }

  public function setScanlines(state:Bool){
    shader.scanlinesOn.value[0] = state;
  }

  public function setVignetteMoving(state:Bool){
    shader.vignetteMoving.value[0] = state;
  }
}

class VCRDistortionShader extends FlxShader // https://www.shadertoy.com/view/ldjGzV and https://www.shadertoy.com/view/Ms23DR and https://www.shadertoy.com/view/MsXGD4 and https://www.shadertoy.com/view/Xtccz4
{

  @:glFragmentSource('
    #pragma header

    uniform float iTime;
    uniform bool vignetteOn;
    uniform bool perspectiveOn;
    uniform bool distortionOn;
    uniform bool scanlinesOn;
    uniform bool vignetteMoving;
    uniform sampler2D noiseTex;
    uniform float glitchModifier;
    uniform vec3 iResolution;
    uniform bool noiseOn;

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
        if(distortionOn){
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
      if(perspectiveOn){
        uv = (uv - 0.5) * 2.0;
      	uv *= 1.1;
      	uv.x *= 1.0 + pow((abs(uv.y) / 5.0), 2.0);
      	uv.y *= 1.0 + pow((abs(uv.x) / 4.0), 2.0);
      	uv  = (uv / 2.0) + 0.5;
      	uv =  uv *0.92 + 0.04;
      	return uv;
      }
    	return uv;
    }
    float random(vec2 uv)
    {
     	return fract(sin(dot(uv, vec2(15.5151, 42.2561))) * 12341.14122 * sin(iTime * 0.03));
    }
    float noise(vec2 uv)
    {
     	vec2 i = floor(uv);
        vec2 f = fract(uv);

        float a = random(i);
        float b = random(i + vec2(1.,0.));
    	float c = random(i + vec2(0., 1.));
        float d = random(i + vec2(1.));

        vec2 u = smoothstep(0., 1., f);

        return mix(a,b, u.x) + (c - a) * u.y * (1. - u.x) + (d - b) * u.x * u.y;

    }


    vec2 scandistort(vec2 uv) {
    	float scan1 = clamp(cos(uv.y * 2.0 + iTime), 0.0, 1.0);
    	float scan2 = clamp(cos(uv.y * 2.0 + iTime + 4.0) * 10.0, 0.0, 1.0) ;
    	float amount = scan1 * scan2 * uv.x;

    	uv.x -= 0.05 * mix(flixel_texture2D(noiseTex, vec2(uv.x, amount)).r * amount, amount, 0.9);

    	return uv;

    }
    void main()
    {
    	vec2 uv = openfl_TextureCoordv;
      vec2 curUV = screenDistort(uv);
    	uv = scandistort(curUV);
    	vec4 video = getVideo(uv);
      float vigAmt = 1.0;
      float x =  0.;


      video.r = getVideo(vec2(x+uv.x+0.001,uv.y+0.001)).x+0.05;
      video.g = getVideo(vec2(x+uv.x+0.000,uv.y-0.002)).y+0.05;
      video.b = getVideo(vec2(x+uv.x-0.002,uv.y+0.000)).z+0.05;
      video.r += 0.08*getVideo(0.75*vec2(x+0.025, -0.027)+vec2(uv.x+0.001,uv.y+0.001)).x;
      video.g += 0.05*getVideo(0.75*vec2(x+-0.022, -0.02)+vec2(uv.x+0.000,uv.y-0.002)).y;
      video.b += 0.08*getVideo(0.75*vec2(x+-0.02, -0.018)+vec2(uv.x-0.002,uv.y+0.000)).z;

      video = clamp(video*0.6+0.4*video*video*1.0,0.0,1.0);
      if(vignetteMoving)
    	  vigAmt = 3.+.3*sin(iTime + 5.*cos(iTime*5.));

    	float vignette = (1.-vigAmt*(uv.y-.5)*(uv.y-.5))*(1.-vigAmt*(uv.x-.5)*(uv.x-.5));

      if(vignetteOn)
    	 video *= vignette;

      if(curUV.x<0 || curUV.x>1 || curUV.y<0 || curUV.y>1){
        gl_FragColor = vec4(0,0,0,0);
      }else{
        if(noiseOn){
          gl_FragColor = mix(video,vec4(noise(uv * 75.)),.05);
        }else{
          gl_FragColor = video;
        }

      }



    }
  ')
  public function new()
  {
    super();
  }
}
