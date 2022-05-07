# BEFORE PUTTING AN ISSUE IN, MAKE SURE YOU'RE ON HAXE 4.2.4!

# Friday Night Funkin: Andromeda Engine


"ANDROMEDA ENGINE IS GOATED" - bbpanzu

Andromeda Engine is a fork of Friday Night Funkin' with customization and gameplay in mind.

Andromeda Engine includes but is not limited to:
- Customizable note skins
- Better input
- A modifier system based on NotITG's and Schmovin's (Schmovin' concept by [4mbr0s3 2](https://www.youtube.com/channel/UCez-Erpr0oqmC71vnDrM9yA))
- A whole lotta options
- The ability to add characters without recompiling source (Press 8 ingame to open the character editor) (Support for Psych's character format, too!)
- The ability to add songs to freeplay without recompiling source
- One of the best lua modchart systems in FNF so far (probably (in my opinion, anyway (I haven't used Psych's)))
- Scroll velocities/mid-song speed changes

## Original Funkin' team
- [ninjamuffin99](https://twitter.com/ninja_muffin99) - Programmer
- [PhantomArcade3K](https://twitter.com/phantomarcade3k) and [Evilsk8r](https://twitter.com/evilsk8r) - Art
- [Kawaisprite](https://twitter.com/kawaisprite) - Musician


## Credits / shoutouts
- [Nebula the Zorua](https://twitter.com/Nebula_Zorua) - Most engine stuff
- [TKTems](https://twitter.com/TKTems) - Menu stuff
- [4mbr0s3 2](https://www.youtube.com/channel/UCez-Erpr0oqmC71vnDrM9yA) - Implementation concept for new modifier stuff and inspiration to even BOTHER working on it, also some code and math shit. Cool dude!!
- [Zenokwei / ILuvGemz](https://twitter.com/gemz_luv) - Lots of useful PRs and reporting and fixing bugs
- [FreestyleDev](https://twitter.com/Rapper_GF_Dev) - Music sync stuff
- [kevinresol](https://github.com/kevinresol) - Original hxvm-lua
- [AndreiDudenko](https://github.com/AndreiRudenko) - Original linc_luajit
- [Echolocated](https://twitter.com/CH_echolocated) - "Epic" judgement rating and spreading the word about the engine
- [Bepixel](https://twitter.com/bepixel_owo) - Default mines
- [Quaver](https://github.com/Quaver/Quaver) - Scroll code
- [Poco](https://github.com/poco0317) - Wife3
- [OpenITG](https://github.com/openitg/openitg) - Quants, some modifier math.
- [Etterna](https://github.com/etternagame/etterna) - Poco did the math for Wife3 in Etterna, I think
- [SrPerez](https://twitter.com/NewSrPerez) - Some math to do with receptors in KE
- [Kade Engine](https://github.com/KadeDev/Kade-Engine) - SrPerez's math for receptors, caching loading screen stuff
- [bbpanzu](https://twitter.com/bbsub3) - Bringing issues to my attention & letting more people know about AE
- [Wilde](https://twitter.com/0WildeRaze) - Keepin' me sane and letting more people know about AE. Love ya, honey!
- [Lizzy](https://twitter.com/tc_lizzy) - Keepin' me sane
- [Redsty Phoenix](https://twitter.com/RedstyP) - REALLY getting the word out
- [Yoshubs](https://twitter.com/yoshubs) - Cache dumping, inspiring me to optimize and improve input
- [Shadow Mario](https://twitter.com/Shadow_Mario_) - Inspiration, Psych Engine character format
- [Psych Engine](https://github.com/ShadowMario/FNF-PsychEngine) - Read Shadow Mario's credit
- [gedehari](https://twitter.com/gedehari) - Inspiration
- [BigWIngs](https://www.shadertoy.com/user/BigWIngs) - Raymarcher shader (https://www.shadertoy.com/view/WtGXDD)
- [ryk](https://www.shadertoy.com/user/ryk) - VCR Distortion shader (https://www.shadertoy.com/view/ldjGzV)
- [Mattias](https://www.shadertoy.com/user/Mattias) - CRT shader in VCR Distortion (https://www.shadertoy.com/view/Ms23DR)
- [Klowner](https://www.shadertoy.com/user/Klowner) - Noise function from the CRT shader (https://www.shadertoy.com/view/MsXGD4)
- [luka712](https://www.shadertoy.com/user/luka712) - Scanlines from CRT shader (https://www.shadertoy.com/view/Xtccz4)
- [Ayma](https://twitter.com/FoguDragon) - Helping test how AE behaves on low-end PCs
- hayasgpt - Cache dumping

Also check out [Forever Engine](https://github.com/Yoshubs/Forever-Engine-Legacy)!

## OG Friday Night Funkin'

Play the Ludum Dare prototype here: https://ninja-muffin24.itch.io/friday-night-funkin
Play the Newgrounds one here: https://www.newgrounds.com/portal/view/770371
Support the project on the itch.io page: https://ninja-muffin24.itch.io/funkin
Get the source code: https://github.com/ninjamuffin99/Funkin

Shoutouts to Newgrounds and Tom Fulp for creatin' the best website and community on the internet

## Build instructions

THESE INSTRUCTIONS ARE FOR COMPILING THE GAME'S SOURCE CODE!!!

IF YOU WANT TO JUST DOWNLOAD AND INSTALL AND PLAY THE GAME NORMALLY, GO TO ITCH.IO TO DOWNLOAD THE GAME FOR PC, MAC, AND LINUX!!

https://ninja-muffin24.itch.io/funkin

IF YOU WANT TO COMPILE THE GAME YOURSELF, CONTINUE READING!!!

### Installing the Required Programs

First you need to install Haxe and HaxeFlixel. I'm too lazy to write and keep updated with that setup (which is pretty simple).
1. [Install Haxe 4.2.4](https://haxe.org/download/version/4.2.4/)
2. [Install HaxeFlixel](https://haxeflixel.com/documentation/install-haxeflixel/) after downloading Haxe

Other installations you'd need is the additional libraries, a fully updated list will be in `Project.xml` in the project root. Currently, these are all of the things you need to install:
```
flixel
flixel-addons
flixel-ui
hscript
newgrounds
```
So for each of those type `haxelib install [library]` so shit like `haxelib install newgrounds`

You'll also need to install a couple things that involve Gits. To do this, you need to do a few things first.
1. Download [git-scm](https://git-scm.com/downloads). Works for Windows, Mac, and Linux, just select your build.
2. Follow instructions to install the application properly.

Then for each of these type `haxelib git [libraryname] [library]` so `haxelib git polymod https://github.com/larsiusprime/polymod.git`
```
polymod https://github.com/larsiusprime/polymod.git
discord_rpc https://github.com/Aidan63/linc_discord-rpc
hxvm-luajit https://github.com/nebulazorua/hxvm-luajit
linc_luajit https://github.com/nebulazorua/linc_luajit
```

Alternatively, you can run "dependencies.bat" (on Windows) to install every dependency


You should have everything ready for compiling the game! Follow the guide below to continue!

At the moment, you can optionally fix the transition bug in songs with zoomed out cameras.
- Run `haxelib git flixel-addons https://github.com/HaxeFlixel/flixel-addons` in the terminal/command-prompt.

### Compiling game

Once you have all those installed, it's pretty easy to compile the game. You just need to run `lime test html5 -debug` in the root of the project to build and run the HTML5 version. (command prompt navigation guide can be found here: [https://ninjamuffin99.newgrounds.com/news/post/1090480](https://ninjamuffin99.newgrounds.com/news/post/1090480))
To run it from your desktop (Windows, Mac, Linux) it can be a bit more involved. For Linux, you only need to open a terminal in the project directory and run `lime test linux -debug` and then run the executable file in export/release/linux/bin. For Windows, you need to install Visual Studio Community 2019. While installing VSC, don't click on any of the options to install workloads. Instead, go to the individual components tab and choose the following:
* MSVC v142 - VS 2019 C++ x64/x86 build tools
* Windows SDK (10.0.17763.0)

Once that is done you can open up a command line in the project's directory and run `lime test windows -debug`. Once that command finishes (it takes forever even on a higher end PC), you can run FNF from the .exe file under export\release\windows\bin
As for Mac, 'lime test mac -debug' should work, if not the internet surely has a guide on how to compile Haxe stuff for Mac.

If you get an error about StatePointer, you'll want to run these:
```
haxelib remove linc_luajit
haxelib remove hxvm-luajit
```

And then

```
haxelib git hxvm-luajit https://github.com/nebulazorua/hxvm-luajit
haxelib git linc_luajit https://github.com/nebulazorua/linc_luajit
```

(Thanks KadeDev for figuring this out because I was stuck on why it happened tbh)

### Additional guides

- [Command line basics](https://ninjamuffin99.newgrounds.com/news/post/1090480)
