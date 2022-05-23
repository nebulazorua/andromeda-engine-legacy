 package states;

import Options;
import Conductor.BPMChangeEvent;
import Section.SwagSection;
import Song.SwagSong;
import Song.VelocityChange;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSubState;
import flixel.FlxCamera;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import haxe.Json;
import lime.utils.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;
import flixel.FlxObject;
import openfl.media.Sound;
import ui.*;
import EngineData.EventArgType;
using StringTools;

class ChartingState extends MusicBeatState
{
	var _file:FileReference;

	var UI_box:FlxUITabMenu;

	/**
	 * Array of notes showing when each section STARTS in STEPS
	 * Usually rounded up??
	 */
	var chartingBG:FlxSprite;

	var curSection:Int = 0;
  var blockInput:Bool=false;
	public static var lastSongName:String = '';
	public static var lastSection:Int = 0;
	public static var songPos:Float = 0;
	public static var instance:ChartingState;

	var songInfoTxt:FlxText;
	var timeTxt:FlxText;
	var controlsTxt:FlxText;
	var strumLine:FlxSprite;
	var curSong:String = 'Dadbattle';
	var amountSteps:Int = 0;
	var bullshitUI:FlxGroup;

	var GRID_SIZE:Int = 40;

	var dummyArrow:NoteGraphic;
	var dummyArrowLayer:FlxTypedGroup<NoteGraphic>;

	var dummyEvent:FlxSprite;
	var eventArgs:Array<Dynamic> = [];
	var eventName:String = '';

	var selectedEvent:Section.Event;
  var selectedEventData:Section.Event;
  var curSelectedEvent:Int = 0;
  var curSelectedArg:Int = 0;
	var useHitSoundsBF = false;
	var useHitSoundsDad = false;
	var curRenderedEvents:FlxTypedGroup<NoteGraphic>;
	var curRenderedNotes:FlxTypedGroup<Note>;
	var curRenderedSustains:FlxTypedGroup<Note>;

	var nextRenderedEvents:FlxTypedGroup<NoteGraphic>;
	var nextRenderedNotes:FlxTypedGroup<Note>;
	var nextRenderedSustains:FlxTypedGroup<Note>;

	var curRenderedMarkers:FlxTypedGroup<FlxSprite>;
	var dropdowns:Array<FlxUIDropDownMenu> = [];
	var textboxes:Array<FlxText> = [];

	var gridBG:FlxSprite;
	var eventRow:FlxSprite;

	var quantization:Int = 16;
	var quantIdx = 3;
	var quantizations:Array<Int> = [
		4,
		8,
		12,
		16,
		20,
		24,
		32,
		48,
		64,
		96,
		192
	];

	var _song:SwagSong;
	var velChanges:Array<VelocityChange> = [];
	var typingShit:FlxInputText;
	/*
	 * WILL BE THE CURRENT / LAST PLACED NOTE
	**/
	var curSelectedNote:Array<Dynamic>;
	var recentNote:Array<Dynamic>;
	var curSelectedMarker:VelocityChange;

	var check_sexPreview:FlxUICheckBox;

	var tempBpm:Int = 0;

	public var vocals:FlxSound;

	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;
	var startPos:Float = 0;

	var gridLayer:FlxTypedGroup<FlxSprite>;

	function addGridBG(){
		gridLayer.clear();
		var height:Int = 16;
		if(check_sexPreview.checked)height=32;

		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * height);
		gridLayer.add(gridBG);

		eventRow = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE, GRID_SIZE * height);
		eventRow.x -= GRID_SIZE*2;
		gridLayer.add(eventRow);

		if(check_sexPreview.checked){
			var gridOverlay = new FlxSprite(gridBG.x, gridBG.height / 2).makeGraphic(Std.int(GRID_SIZE * 8), Std.int(GRID_SIZE * (height/2)), FlxColor.BLACK);
			gridOverlay.alpha = 0.6;
			var eventOverlay = new FlxSprite(eventRow.x, eventRow.height / 2).makeGraphic(Std.int(GRID_SIZE), Std.int(GRID_SIZE * (height/2)), FlxColor.BLACK);
			eventOverlay.alpha = 0.6;
			gridLayer.add(gridOverlay);
			gridLayer.add(eventOverlay);
		}

		var gridBlackLine:FlxSprite = new FlxSprite(gridBG.x + gridBG.width / 2).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		gridLayer.add(gridBlackLine);
	}
	var pauseHUD:FNFCamera;

	override function create()
	{
		super.create();
		InitState.getCharacters();

		instance = this;

		// taken straight from story menu state lmao!
		chartingBG = new FlxSprite(-80).loadGraphic(Paths.image('menuBGDesat'));
		chartingBG.color = FlxColor.fromRGB(FlxG.random.int(50, 205), FlxG.random.int(50, 205), FlxG.random.int(50, 205));
		chartingBG.setGraphicSize(Std.int(chartingBG.width * 1.1));
		chartingBG.antialiasing = true;
		chartingBG.screenCenter();
		chartingBG.scrollFactor.set();
		add(chartingBG);

		gridLayer = new FlxTypedGroup<FlxSprite>();
		add(gridLayer);

		leftIcon = new HealthIcon('bf');
		rightIcon = new HealthIcon('dad');
		leftIcon.scrollFactor.set(1, 1);
		rightIcon.scrollFactor.set(1, 1);

		leftIcon.setGraphicSize(0, 45);
		rightIcon.setGraphicSize(0, 45);

		add(leftIcon);
		add(rightIcon);

		leftIcon.setPosition(60, -50);
		rightIcon.setPosition(220, -50);

		curRenderedEvents = new FlxTypedGroup<NoteGraphic>();
		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedSustains = new FlxTypedGroup<Note>();

		nextRenderedEvents = new FlxTypedGroup<NoteGraphic>();
		nextRenderedNotes = new FlxTypedGroup<Note>();
		nextRenderedSustains = new FlxTypedGroup<Note>();

		curRenderedMarkers = new FlxTypedGroup<FlxSprite>();

		if (PlayState.SONG != null){
			_song = PlayState.SONG;
			velChanges=_song.sliderVelocities;
			_song.sliderVelocities=null;
		}else
		{
			_song = {
				song: 'Test',
				notes: [],
				bpm: 150,
				needsVoices: true,
				player1: 'bf',
				player2: 'dad',
				stage: "stage",
				noteModifier: "base",
        format: "andromeda1",
				speed: 1,
				validScore: false
			};
			velChanges = [];
		}

    for(section in _song.notes){
      if(section.events==null)section.events=[]; // so shit doesnt BREAK

      for(event in section.events){ // legacy events to new event system
        if(event.events==null){
          event.events = [
            {
              name: event.name,
              args: event.args
            }
          ];
          event.name=null;
          event.args=null;
        }
      }
    }

		FlxG.mouse.visible = true;
		FlxG.save.bind('funkin', 'ninjamuffin99');

		if(lastSongName!=_song.song){songPos=0;lastSection=0;}
		lastSongName = _song.song;
		tempBpm = _song.bpm;

		addSection();

		// sections = _song.notes;

		loadSong(_song.song);
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		timeTxt = new FlxText(60, 50, 600, "", 16);
		timeTxt.setFormat('vcr.ttf', 24, FlxColor.WHITE, LEFT);
		timeTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.25, 1);
		timeTxt.scrollFactor.set();
		add(timeTxt);

		songInfoTxt = new FlxText(60, 100, 300, "", 16);
		songInfoTxt.setFormat('vcr.ttf', 24, FlxColor.WHITE, LEFT);
		songInfoTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.25, 1);
		songInfoTxt.scrollFactor.set();
		add(songInfoTxt);

		controlsTxt = new FlxText(60, 200, 300, "", 16);
		controlsTxt.setFormat('vcr.ttf', 16, FlxColor.WHITE, LEFT);
		controlsTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.25, 1);
		controlsTxt.scrollFactor.set();
		add(controlsTxt);

		strumLine = new FlxSprite(0, 50).makeGraphic(320, 4);
		add(strumLine);

		dummyArrowLayer = new FlxTypedGroup<NoteGraphic>();
		add(dummyArrowLayer);
		dummyArrow = new NoteGraphic(0,PlayState.noteModifier,EngineData.options.noteSkin,Note.noteBehaviour);
		dummyArrow.setDir(0,0,false);
		dummyArrow.setGraphicSize(GRID_SIZE,GRID_SIZE);
		dummyArrow.updateHitbox();
		dummyArrow.alpha=.5;
		dummyArrowLayer.add(dummyArrow);

		dummyEvent = new FlxSprite(-GRID_SIZE*2).makeGraphic(GRID_SIZE, GRID_SIZE);

		var tabs = [
			{name: "Song", label: 'Song'},
			{name: "Section", label: 'Section'},
			{name: "Note", label: 'Note'},
			{name: "Event", label: 'Event'},
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 400);
		UI_box.x = 890;
		UI_box.y = 20;
		add(UI_box);

		addSongUI();
		addGridBG();
		updateGrid();
		addSectionUI();
		addNoteUI();
		addMarkerUI();
		add(dummyEvent);
		add(curRenderedNotes);
		add(curRenderedSustains);
		add(curRenderedMarkers);
		add(curRenderedEvents);
		add(nextRenderedNotes);
		add(nextRenderedSustains);
		add(nextRenderedEvents);
		curSection = 0;

		vocals.time = songPos;
		FlxG.sound.music.time = songPos;
		Conductor.songPosition = songPos;
		Conductor.lastSongPos = songPos;
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();

		/*changeSection(0);
		while (curStep >= 16 * (curSection + 1))
		{
			trace(curStep);
			trace((_song.notes[curSection].lengthInSteps) * (curSection + 1));
			trace('DUMBSHIT');

			if (_song.notes[curSection + 1] == null)
			{
				addSection();
			}

			changeSection(curSection + 1, false);
		}*/
		changeSection(lastSection);


		updateSectionUI();

		resetSection();

		var cam = FlxG.camera;
		pauseHUD = new FNFCamera();
		pauseHUD.bgColor.alpha = 0;
		FlxG.cameras.add(pauseHUD);
		FlxCamera.defaultCameras = [FlxG.camera];

	}

	function addSongUI():Void
	{
		var UI_songTitle = new Inputbox(10, 10, 70, _song.song, 8);
		typingShit = UI_songTitle;
		textboxes.push(typingShit);

		check_sexPreview = new FlxUICheckBox(90, 10, null, null, "Section Preview", 100);
		check_sexPreview.checked = OptionUtils.options.sectionPreview;
		check_sexPreview.callback = function()
		{
			OptionUtils.options.sectionPreview=check_sexPreview.checked;
			addGridBG();
			updateGrid();
		};

		var check_voices = new FlxUICheckBox(check_sexPreview.x, check_sexPreview.y + 30, null, null, "Voices Enabled?", 100);
		check_voices.checked = _song.needsVoices;
		// _song.needsVoices = check_voices.checked;
		check_voices.callback = function()
		{
			_song.needsVoices = check_voices.checked;
			trace('CHECKED!');
		};


		var check_mute_inst = new FlxUICheckBox(check_voices.x, check_voices.y + 30, null, null, "Mute Instrumental (Editor Only)", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_inst.checked)
				vol = 0;

			FlxG.sound.music.volume = vol;
		};

		var check_mute_vox = new FlxUICheckBox(check_mute_inst.x, check_mute_inst.y + 30, null, null, "Mute Vocals \n(Editor Only)", 100);
		check_mute_vox.checked = false;
		check_mute_vox.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_vox.checked)
				vol = 0;

			vocals.volume = vol;
		};

		var check_use_bfhit = new FlxUICheckBox(10, check_mute_vox.y + 30, null, null, "Play Hit Sounds (Player)", 100);
		check_use_bfhit.checked = OptionUtils.options.bfHitsounds;
		useHitSoundsBF = OptionUtils.options.bfHitsounds;
		check_use_bfhit.callback = function()
		{
			useHitSoundsBF=check_use_bfhit.checked;
			OptionUtils.options.bfHitsounds = useHitSoundsBF;
		};

		var check_use_dadhit = new FlxUICheckBox(160, check_mute_vox.y + 30, null, null, "Play Hit Sounds (Opponent)", 100);
		check_use_dadhit.checked = OptionUtils.options.dadHitsounds;
		useHitSoundsDad = OptionUtils.options.dadHitsounds;
		check_use_dadhit.callback = function()
		{
			useHitSoundsDad=check_use_dadhit.checked;
			OptionUtils.options.dadHitsounds = useHitSoundsDad;
		};

		var saveButton:FlxButton = new FlxButton(210, 8, "Save JSON", function()
		{
      if(blockInput)return;
			saveLevel();
		});

		var reloadSong:FlxButton = new FlxButton(saveButton.x, saveButton.y + 30, "Reload Audio", function()
		{
      if(blockInput)return;
			loadSong(_song.song);
		});

		var reloadSongJson:FlxButton = new FlxButton(reloadSong.x, reloadSong.y + 30, "Reload JSON", function()
		{
      if(blockInput)return;
			loadJson(_song.song.toLowerCase());
		});

		var loadAutosaveBtn:FlxButton = new FlxButton(reloadSongJson.x, reloadSongJson.y + 30, 'Load Autosave', loadAutosave);

		var stepperBPMInfo = new FlxText(10, 25, 'Song BPM');

		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 40, 1, 1, 1, 339, 0);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';
		@:privateAccess
		textboxes.push(stepperBPM.text_field);

		var stepperSpeedInfo = new FlxText(10, 55, 'Scroll Speed');

		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(10, 70, 0.1, 1, 0.1, 10, 1);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';
		@:privateAccess
		textboxes.push(stepperSpeed.text_field);

		var characters:Array<String> = EngineData.characters;

		var player1Info = new FlxText(10, 155, 'Player 1');

		var player1DropDown = new FlxUIDropDownMenu(10, 170, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player1 = characters[Std.parseInt(character)];
		});
		player1DropDown.dropDirection = FlxUIDropDownMenuDropDirection.Down;
		player1DropDown.selectedLabel = _song.player1;
		dropdowns.push(player1DropDown);

		var player2Info = new FlxText(160, 155, 'Player 2');

		var player2DropDown = new FlxUIDropDownMenu(160, 170, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player2 = characters[Std.parseInt(character)];
		});
		player2DropDown.dropDirection = FlxUIDropDownMenuDropDirection.Down;
		player2DropDown.selectedLabel = _song.player2;
		dropdowns.push(player2DropDown);
		var stageInfo = new FlxText(10, 195, 'Stage');

		var stageDropdown = new FlxUIDropDownMenu(10, 210, FlxUIDropDownMenu.makeStrIdLabelArray(Stage.stageNames, true), function(stageName:String)
		{
			_song.stage = Stage.stageNames[Std.parseInt(stageName)];
		});
		stageDropdown.dropDirection = FlxUIDropDownMenuDropDirection.Down;
		stageDropdown.selectedLabel = _song.stage;
		dropdowns.push(stageDropdown);
		// TODO: noteskin.noteModifiers or some shit
		var modifiers:Array<String> = CoolUtil.coolTextFile(Paths.txt('noteModifiers'));

		var modInfo = new FlxText(160, 195, 'Note Modifier');

		var modifierDropdown = new FlxUIDropDownMenu(160, 210, FlxUIDropDownMenu.makeStrIdLabelArray(modifiers, true), function(mod:String)
		{
			_song.noteModifier = modifiers[Std.parseInt(mod)];
		});
		modifierDropdown.dropDirection = FlxUIDropDownMenuDropDirection.Down;
		modifierDropdown.selectedLabel = _song.noteModifier;
		dropdowns.push(modifierDropdown);
		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "Song";
		tab_group_song.add(UI_songTitle);

		tab_group_song.add(check_sexPreview);
		tab_group_song.add(check_voices);
		tab_group_song.add(check_mute_inst);
		tab_group_song.add(check_mute_vox);
		tab_group_song.add(check_use_bfhit);
		tab_group_song.add(check_use_dadhit);
		tab_group_song.add(saveButton);
		tab_group_song.add(reloadSong);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperBPMInfo);
		tab_group_song.add(stepperSpeed);
		tab_group_song.add(stepperSpeedInfo);
		tab_group_song.add(modifierDropdown);
		tab_group_song.add(modInfo);
		tab_group_song.add(stageDropdown);
		tab_group_song.add(stageInfo);
		tab_group_song.add(player2DropDown);
		tab_group_song.add(player2Info);
		tab_group_song.add(player1DropDown);
		tab_group_song.add(player1Info);

		UI_box.addGroup(tab_group_song);
		UI_box.scrollFactor.set();

		FlxG.camera.follow(strumLine);

	}

	var stepperLength:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	var check_altAnim:FlxUICheckBox;

	function addSectionUI():Void
	{
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		stepperSectionBPM = new FlxUINumericStepper(10, 80, 1, Conductor.bpm, 0, 999, 0);
		stepperSectionBPM.value = Conductor.bpm;
		stepperSectionBPM.name = 'section_bpm';
		@:privateAccess
		textboxes.push(stepperSectionBPM.text_field);


		var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(110, 130, 1, 1, -999, 999, 0);
		@:privateAccess
		textboxes.push(stepperCopy.text_field);
		var copyLastButton:FlxButton = new FlxButton(10, 130, "Copy last", function()
		{
      if(blockInput)return;
			copySectionLast(Std.int(stepperCopy.value));
		});

		var copyButton:FlxButton = new FlxButton(10, 150, "Copy section", function()
		{
      if(blockInput)return;
			copySection(Std.int(stepperCopy.value));
		});

		var clearSectionButton:FlxButton = new FlxButton(10, 170, "Clear Section", function(){
      if(blockInput)return;
      clearSection();
    });

		var swapSection:FlxButton = new FlxButton(10, 190, "Swap Section", function()
		{
      if(blockInput)return;
			for (i in 0..._song.notes[curSection].sectionNotes.length)
			{
				var note = _song.notes[curSection].sectionNotes[i];
				note[1] = (note[1] + 4) % 8;
				_song.notes[curSection].sectionNotes[i] = note;
			}
      updateGrid();
		});

		check_mustHitSection = new FlxUICheckBox(10, 30, null, null, "Must hit section", 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = true;
		// _song.needsVoices = check_mustHit.checked;

		check_altAnim = new FlxUICheckBox(10, 220, null, null, "Alt Animation", 100);
		check_altAnim.name = 'check_altAnim';

		check_changeBPM = new FlxUICheckBox(10, 60, null, null, 'Change BPM', 100);
		check_changeBPM.name = 'check_changeBPM';

		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(stepperCopy);
		tab_group_section.add(check_mustHitSection);
		tab_group_section.add(check_altAnim);
		tab_group_section.add(check_changeBPM);
		tab_group_section.add(copyButton);
		tab_group_section.add(copyLastButton);
		tab_group_section.add(clearSectionButton);
		tab_group_section.add(swapSection);

		UI_box.addGroup(tab_group_section);
	}
	var eventDropdown:FlxUIDropDownMenu;
	var eventArgDropdown:FlxUIDropDownMenu;
	var dropdownArg:FlxUIDropDownMenu;
	var stepperArg:FlxUINumericStepper;
	var stringArg:FlxInputText;
	var argWidgets:Array<FlxSprite> = [];
	var argToWidget:Map<EventArgType, FlxSprite> = new Map<EventArgType, FlxSprite>();
  var addEventButton:FlxButton;
  var delEventButton:FlxButton;
  var nextEventButton:FlxButton;
  var prevEventButton:FlxButton;
  var eventSelectedText:FlxText;

	var curEvent:String = '';
	function updateArgDropdown():Void
	{
		eventArgs=[];
		var args:Array<String>=[];
		for(ev in EngineData.events){
			if(ev.name==eventName){
				for(arg in ev.arguments){
					args.push(arg.name);
					var defVal:Dynamic = arg.defaultVal;
					if(selectedEvent!=null && selectedEvent.name==eventName)defVal = selectedEvent.args[eventArgs.length];
					if(defVal==null){
						switch(arg.type){
							case EventArgType.SteppedNumber | EventArgType.Number:
								defVal = 0;
							case EventArgType.Dropdown:
								//arg.dropdownValues
								defVal = getDropVals(arg)[0];
							case EventArgType.CharacterDropdown:
								defVal = EngineData.characters[0];
							case EventArgType.Text:
								defVal = '';
							case EventArgType.Checkbox:
								defVal = false;
						}
					}
					eventArgs.push(defVal);
				}
			}
		}
		if(args.length==0){
			eventArgDropdown.active=false;
			eventArgDropdown.visible=false;
		}else{
			eventArgDropdown.visible=true;
			eventArgDropdown.active=true;
			eventArgDropdown.setData(FlxUIDropDownMenu.makeStrIdLabelArray(args, true));
			eventArgDropdown.selectedId = Std.string(curSelectedArg);
		}
	}

	function updateWidgets(){
		for(obj in argWidgets){obj.visible=false;obj.active=false;}

		for(ev in EngineData.events){
			if(ev.name==eventName){
				var argData = ev.arguments[curSelectedArg];
				if(argData!=null){

					var widget = argToWidget.get(argData.type);
					if(widget!=null){
						widget.visible=true;
						widget.active=true;
					}

					switch(argData.type){
						case EventArgType.SteppedNumber:
							var widget:FlxUINumericStepper = cast widget;
							widget.stepSize = argData.step==null?1:argData.step;
							widget.value = eventArgs[curSelectedArg];
						case EventArgType.Dropdown:
							var widget:FlxUIDropDownMenu = cast widget;
							widget.setData(FlxUIDropDownMenu.makeStrIdLabelArray(getDropVals(argData), true));
							widget.selectedLabel = eventArgs[curSelectedArg];
						case EventArgType.CharacterDropdown:
							var widget:FlxUIDropDownMenu = cast widget;
							widget.setData(FlxUIDropDownMenu.makeStrIdLabelArray(EngineData.characters, true));
							widget.selectedLabel = eventArgs[curSelectedArg];
						case EventArgType.Text:
							var widget:Inputbox = cast widget;
							widget.text = eventArgs[curSelectedArg];
						default:

					}
				}

			}
		}
	}

	function getDropVals(what: EngineData.EventArg):Array<String> {
		if(what.dropdownValues!=null)
			return what.dropdownValues;
		else if(what.getDropdownValues!=null)
			return what.getDropdownValues();

		return [''];
	}

	function addMarkerUI():Void
	{
		var eventGroup = new FlxUI(null,UI_box);
		eventGroup.name = 'Event';
		var events:Array<String> = [];
		for(ev in EngineData.events)
			events.push(ev.name);

    eventSelectedText = new FlxText(80, 155, 'Selected: None');
    eventSelectedText.setFormat('vcr.ttf', 14, FlxColor.WHITE, LEFT);

    addEventButton = new FlxButton(135, 205, "Add", function(){
      if(blockInput)return;
      if(selectedEventData!=null){
        selectedEventData.events.insert(curSelectedEvent+1, {
    			args: [],
          name: '',
        });
        changeSelectedEvent(1);
      }
    });

    delEventButton = new FlxButton(30, 205, "Remove", function(){
      if(blockInput)return;
      if(selectedEventData==null)return;
      selectedEventData.events.splice(curSelectedEvent, 1);
      if(selectedEventData.events.length==0){
        for(section in _song.notes){
          for(event in section.events){
            if(event==selectedEventData){
              section.events.remove(event);
              return;
            }
          }
        }
      }else
        changeSelectedEvent(-1);


    });

    nextEventButton = new FlxButton(135, 175, "Next", function(){
      if(blockInput)return;
      changeSelectedEvent(1);
    });

    prevEventButton = new FlxButton(30, 175, "Prev", function(){
      if(blockInput)return;
      changeSelectedEvent(-1);
    });

    eventGroup.add(nextEventButton);
    eventGroup.add(prevEventButton);
    eventGroup.add(addEventButton);
    eventGroup.add(delEventButton);
    eventGroup.add(eventSelectedText);

		stepperArg = new FlxUINumericStepper(60, 80, 0.1, 0, -999, 999, 2);
		stepperArg.value = 0;
		stepperArg.name = 'stepperArg';
		@:privateAccess
		textboxes.push(stepperArg.text_field);

		dropdownArg = new FlxUIDropDownMenu(60, 80, null, function(arg:String)
		{
			eventArgs[curSelectedArg] = dropdownArg.selectedLabel;
      if(selectedEventData!=null)
        selectedEventData.events[curSelectedEvent].args = eventArgs;

		});
		dropdownArg.dropDirection = FlxUIDropDownMenuDropDirection.Down;
		dropdownArg.selectedLabel = events[0];
		dropdowns.push(dropdownArg);
		stringArg = new Inputbox(60, 80, 150, '', 8);
		textboxes.push(stringArg);
		stringArg.focusLost = function(){
			eventArgs[curSelectedArg] = stringArg.text; // ev.arguments[curSelectedArg].dropdownValues[Std.parseInt(arg)];
      if(selectedEventData!=null)
        selectedEventData.events[curSelectedEvent].args = eventArgs;
    }

		argToWidget.set(EventArgType.SteppedNumber, stepperArg);
		argToWidget.set(EventArgType.Dropdown, dropdownArg);
		argToWidget.set(EventArgType.CharacterDropdown, dropdownArg);
		argToWidget.set(EventArgType.Text, stringArg);

		argWidgets = [stepperArg, dropdownArg, stringArg];

		eventArgDropdown = new FlxUIDropDownMenu(165, 30, null, function(arg:String)
		{
			curSelectedArg=Std.parseInt(arg);
			updateWidgets();
		});
		dropdowns.push(eventArgDropdown);
		eventDropdown = new FlxUIDropDownMenu(15, 30, FlxUIDropDownMenu.makeStrIdLabelArray(events, true), function(event:String)
		{
			curSelectedArg=0;
			eventName = events[Std.parseInt(event)];
			updateArgDropdown();
			updateWidgets();
			if(selectedEventData!=null && selectedEventData.events[curSelectedEvent].name!=eventName){
				selectedEventData.events[curSelectedEvent].name = eventName;
				selectedEventData.events[curSelectedEvent].args = eventArgs;
			}
		});
		dropdowns.push(eventDropdown);
		eventDropdown.dropDirection = FlxUIDropDownMenuDropDirection.Down;
		eventDropdown.selectedLabel = events[0];

		for(widget in argWidgets)
			eventGroup.add(widget);



		eventGroup.add(eventArgDropdown);
		eventGroup.add(eventDropdown);
		UI_box.addGroup(eventGroup);

		updateArgDropdown();
		updateWidgets();
	}

	var stepperSusLength:FlxUINumericStepper;

	var leftType:FlxUIDropDownMenu;
	var rightType:FlxUIDropDownMenu;
	var selectedType:FlxUIDropDownMenu;

	var check_isRoll:FlxUICheckBox;

	function addNoteUI():Void
	{
		var tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';

		var susInfo = new FlxText(5, 5, 'Sustain Length');
		stepperSusLength = new FlxUINumericStepper(10, 20, Conductor.stepCrochet/2, 0, 0, Conductor.stepCrochet * 32);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';
		@:privateAccess
		textboxes.push(stepperSusLength.text_field);

		check_isRoll = new FlxUICheckBox(120, 20, null, null, "Roll", 100);
		check_isRoll.checked = false;
		check_isRoll.callback = function()
		{
			if(curSelectedNote!=null){
				curSelectedNote[4] = check_isRoll.checked;
				updateNoteUI();
				updateGrid();
			}
		};

		var leftInfo = new FlxText(10, 50, 'Left Click Type');
		var rightInfo = new FlxText(150, 50, 'Right Click Type');
		var selectedInfo = new FlxText(10, 150, "Selected Note's Type");

		rightType = new FlxUIDropDownMenu(150, 70, FlxUIDropDownMenu.makeStrIdLabelArray(EngineData.noteTypes, true));
		rightType.dropDirection = FlxUIDropDownMenuDropDirection.Down;
		rightType.selectedLabel = EngineData.noteTypes[0];
		dropdowns.push(rightType);

		selectedType = new FlxUIDropDownMenu(10, 170, FlxUIDropDownMenu.makeStrIdLabelArray(EngineData.noteTypes, true), function(type:String){
			if(curSelectedNote!=null){
				curSelectedNote[3] = type;
				updateNoteUI();
				updateGrid();
			}
		});
		selectedType.dropDirection = FlxUIDropDownMenuDropDirection.Down;
		selectedType.selectedLabel = EngineData.noteTypes[0];
		dropdowns.push(selectedType);

		leftType = new FlxUIDropDownMenu(10, 70, FlxUIDropDownMenu.makeStrIdLabelArray(EngineData.noteTypes, true), function(type:String){
			dummyArrowLayer.remove(dummyArrow);
			var realType = EngineData.noteTypes[Std.parseInt(type)];
			var type = realType=='alt'?'default':realType; // TODO: maybe NOT hardcode this lol
			// prob just make a note w/ the type and then just like.. get the graphicType off of there
			var modBehaviours = Note.behaviours.get(Note.defaultModifier);
			if(modBehaviours==null)modBehaviours = new Map<String,Note.NoteBehaviour>();

			var behaviour = type=='default'?Note.noteBehaviour:modBehaviours.get(type);
			if(behaviour==null){
				behaviour = Json.parse(Paths.noteSkinText("behaviorData.json",'skins',EngineData.options.noteSkin,Note.defaultModifier,type));
				modBehaviours.set(type,behaviour);
				Note.behaviours.set(Note.defaultModifier,modBehaviours);
			}

			dummyArrow = new NoteGraphic(0,PlayState.noteModifier,EngineData.options.noteSkin,type,behaviour);
			dummyArrow.setDir(0,0,false);
			dummyArrow.setGraphicSize(GRID_SIZE,GRID_SIZE);
			dummyArrow.updateHitbox();
			dummyArrow.alpha=.5;
			dummyArrowLayer.add(dummyArrow);
		});
		leftType.dropDirection = FlxUIDropDownMenuDropDirection.Down;
		leftType.selectedLabel = EngineData.noteTypes[0];
		dropdowns.push(leftType);

		tab_group_note.add(leftInfo);
		tab_group_note.add(rightInfo);
		tab_group_note.add(selectedInfo);
		tab_group_note.add(leftType);
		tab_group_note.add(rightType);
		tab_group_note.add(selectedType);
		tab_group_note.add(susInfo);
		tab_group_note.add(check_isRoll);
		tab_group_note.add(stepperSusLength);

		UI_box.addGroup(tab_group_note);
	}

	function loadSong(daSong:String):Void
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
			// vocals.stop();
		}

		FlxG.sound.playMusic(CoolUtil.getSound('${Paths.inst(daSong)}'), 0.6);

		// WONT WORK FOR TUTORIAL OR TEST SONG!!! REDO LATER
		vocals = new FlxSound().loadEmbedded(CoolUtil.getSound('${Paths.voices(daSong)}'));
		FlxG.sound.list.add(vocals);

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.onComplete = function()
		{
			vocals.pause();
			vocals.time = 0;
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		};
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				case 'Must hit section':
					_song.notes[curSection].mustHitSection = check.checked;

					updateHeads();

				case 'Change BPM':
					_song.notes[curSection].changeBPM = check.checked;
					Conductor.mapBPMChanges(_song);
					FlxG.log.add('changed bpm shit');
				case "Alt Animation":
					_song.notes[curSection].altAnim = check.checked;
			}
		}
		else if(id == FlxUITabMenu.CLICK_EVENT && (sender is FlxUITabMenu)){
			var tabMenu:FlxUITabMenu = cast FlxUITabMenu;
			if(sender==UI_box){
				switch(data){
					case 'Event':
						updateMarkerUI();
				}
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);
			switch(wname){
				case 'stepperArg':
					eventArgs[curSelectedArg] = nums.value; // ev.arguments[curSelectedArg].dropdownValues[Std.parseInt(arg)];
					if(selectedEventData!=null)
						selectedEventData.events[curSelectedEvent].args = eventArgs;
				case 'marker_scrollVel':
					curSelectedMarker.multiplier=nums.value;
					updateGrid();
				case 'section_bpm':
					_song.notes[curSection].bpm = Std.int(nums.value);
					updateGrid();
				case 'note_susLength':
          if(curSelectedNote[2]!=nums.value){
  					curSelectedNote[2] = nums.value;
  					updateGrid();
          }
				case 'song_bpm':
					tempBpm = Std.int(nums.value);
					Conductor.mapBPMChanges(_song);
					Conductor.changeBPM(Std.int(nums.value));
				case 'song_speed':
					_song.speed = nums.value;
				case 'section_length':
					trace("point and laugh at this user"); // no
			}
		}

		// FlxG.log.add(id + " WEED " + sender + " WEED " + data + " WEED " + params);
	}

	var updatedSection:Bool = false;

	/* this function got owned LOL
		function lengthBpmBullshit():Float
		{
			if (_song.notes[curSection].changeBPM)
				return _song.notes[curSection].lengthInSteps * (_song.notes[curSection].bpm / _song.bpm);
			else
				return _song.notes[curSection].lengthInSteps;
	}*/
	function sectionStartTime(?section:Int):Float
	{
		if(section==null)section=curSection;

		var daBPM:Int = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...section)
		{
			if (_song.notes[i].changeBPM)
			{
				daBPM = _song.notes[i].bpm;
			}
			daPos += 4 * (1000 * 60 / daBPM);
		}
		return daPos;
	}
	function sectionEndTime(?section:Int):Float
	{
		if(section==null)section=curSection;
		return sectionStartTime(section+1);
	}

	var lastMousePos:FlxPoint = FlxPoint.get();
	var paused:Bool=false;
	function pause(){
		if(subState!=null || paused)return;
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		openSubState(new ChartingPauseSubstate());
	}


		override function closeSubState()
		{
			if (paused)
			{
				paused = false;
				trace("was paused");
				persistentDraw=true;
				persistentUpdate=true;
			}

			super.closeSubState();
		}

		override function openSubState(SubState:FlxSubState)
		{
			if (paused){
				FlxG.sound.music.pause();
				vocals.pause();
				trace("am paused");
			}


			super.openSubState(SubState);
		}

	override function update(elapsed:Float)
	{
		curStep = recalculateSteps();

		Conductor.songPosition = FlxG.sound.music.time;
		_song.song = typingShit.text;

		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps));

		if (curStep >= 16 * (curSection + 1))
		{
			if (_song.notes[curSection + 1] == null)
			{
				addSection();
			}

			changeSection(curSection + 1, false);
		}


		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);

		if (FlxG.mouse.justPressed || FlxG.mouse.justPressedRight)
		{
			if (FlxG.mouse.overlaps(curRenderedNotes))
			{
				curRenderedNotes.forEach(function(note:Note)
				{
					if (FlxG.mouse.overlaps(note) || CoolUtil.truncateFloat(note.strumTime,2) == CoolUtil.truncateFloat(getStrumTime(dummyArrow.y),2) && note.rawNoteData==Math.floor(FlxG.mouse.x / GRID_SIZE) )
					{
						trace(note.strumTime,note.rawNoteData);
						if (FlxG.keys.pressed.CONTROL)
						{
							trace("tryin to select note...");
							selectNote(note);
						}
						else
						{
							trace('tryin to delete note...');
							deleteNote(note);
						}
					}
				});
			}else if (FlxG.mouse.overlaps(curRenderedMarkers)){
				curRenderedMarkers.forEach( function(mark:FlxSprite)
				{
					if (FlxG.mouse.overlaps(mark))
					{
						if(FlxG.keys.pressed.CONTROL){
							selectMarker(mark);
						}else{
							deleteMarker(mark);
						}
					}
				});
			}else if (FlxG.mouse.overlaps(curRenderedEvents)){
				curRenderedEvents.forEach( function(event:NoteGraphic)
				{
					if (FlxG.mouse.overlaps(event))
					{
						if(FlxG.keys.pressed.CONTROL){
							selectEvent(event);
						}else{
							deleteEvent(event);
						}
					}
				});
			}
			else
			{
				if (FlxG.mouse.x > gridBG.x
					&& FlxG.mouse.x < gridBG.x + gridBG.width
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
				{
					FlxG.log.add('added note');
					addNote(FlxG.mouse.justPressedRight);
				}

				if (FlxG.mouse.x > eventRow.x
					&& FlxG.mouse.x < eventRow.x + eventRow.width
					&& FlxG.mouse.y > eventRow.y
					&& FlxG.mouse.y < eventRow.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
				{
					FlxG.log.add('added event');
					addEvent();
				}
			}
		}

		if(FlxG.mouse.justReleased || FlxG.mouse.justReleasedRight){
			recentNote=null;
		}else if(FlxG.mouse.pressed || FlxG.mouse.pressedRight){
			if(recentNote!=null){
				if(lastMousePos.y!=dummyArrow.y){
					lastMousePos.set(dummyArrow.x,dummyArrow.y);
					var length = getStrumTime(dummyArrow.y)-(recentNote[0]-sectionStartTime());
					setNoteSustain(length,recentNote);
				}
			}
		}

		var hitSound:Array<Bool> = [false,false,false,false];
		curRenderedNotes.forEach(function(note:Note){
			if(note.strumTime<=Conductor.songPosition){
				if(note.color!=0xAAAAAA){
					if(!note.wasGoodHit){
						note.wasGoodHit=true;
						if((useHitSoundsBF && note.mustPress || useHitSoundsDad && !note.mustPress) && !hitSound[note.noteData] && note.strumTime > Conductor.lastSongPos){
							FlxG.sound.play(Paths.sound('Normal_Hit'),3);
							hitSound[note.noteData]=true;
						}

					}

					note.color = 0xAAAAAA;
				}

			}else{
				note.wasGoodHit=false;
				note.color = 0xFFFFFF;
			}
		});

		_song.bpm = tempBpm;

		/* if (FlxG.keys.justPressed.UP)
				Conductor.changeBPM(Conductor.bpm + 1);
			if (FlxG.keys.justPressed.DOWN)
				Conductor.changeBPM(Conductor.bpm - 1); */

		var canInput = true;


		if(canInput){
			for(drop in dropdowns){
				if(drop.dropPanel.visible
					#if FLX_MOUSE
						&& FlxG.mouse.overlaps(drop)
					#end
				){
					canInput=false;
					break;
				}
			}
		}
		if(canInput){
			for(text in textboxes){
				if((text is FlxInputText)){
					var text:FlxInputText = cast text;
					if(text.hasFocus && text.visible){
						canInput=false;
						break;
					}else if(text.hasFocus && !text.visible)
            text.hasFocus=false;
				}
			}
		}


    blockInput=!canInput;

		if (canInput)
		{

			if(FlxG.keys.justPressed.RIGHT){
				quantIdx+=1;
				if(quantIdx>quantizations.length-1)
					quantIdx = 0;

				quantization = quantizations[quantIdx];
			}

			if(FlxG.keys.justPressed.LEFT){
				quantIdx-=1;
				if(quantIdx<0)
					quantIdx = quantizations.length-1;

				quantization = quantizations[quantIdx];
			}

				if (FlxG.keys.justPressed.ENTER)
					startSong(FlxG.keys.pressed.SHIFT?FlxG.sound.music.time:0);


				if(FlxG.keys.justPressed.ESCAPE)
					pause();


				if(FlxG.keys.pressed.SHIFT){

				}else{
					if (FlxG.keys.justPressed.E)
					{
						changeNoteSustain(Conductor.stepCrochet);
					}
					if (FlxG.keys.justPressed.Q)
					{
						changeNoteSustain(-Conductor.stepCrochet);
					}
				}


				if (FlxG.keys.justPressed.TAB)
				{
					if (FlxG.keys.pressed.SHIFT)
					{
						UI_box.selected_tab -= 1;
						if (UI_box.selected_tab < 0)
							UI_box.selected_tab = 3;
					}
					else
					{
						UI_box.selected_tab += 1;
						if (UI_box.selected_tab > 3)
							UI_box.selected_tab = 0;
					}
				}

			var shiftThing:Int = 1;
			if (FlxG.keys.pressed.SHIFT)
				shiftThing = 4;
			if (FlxG.keys.justPressed.D){
				for(i in 0...shiftThing){
					if (_song.notes[curSection + i] == null)
					{
						addSection();
					}
				}
				changeSection(curSection + shiftThing);
			}
			if (FlxG.keys.justPressed.A)
				changeSection(curSection - shiftThing);


			if (FlxG.keys.justPressed.SPACE)
			{
				if (FlxG.sound.music.playing)
				{
					FlxG.sound.music.pause();
					vocals.pause();
				}
				else
				{
					vocals.play();
					FlxG.sound.music.play();
					vocals.time = FlxG.sound.music.time;
					FlxG.sound.music.time = vocals.time;
				}
			}

			if (FlxG.keys.justPressed.R)
			{
				if (FlxG.keys.pressed.SHIFT)
					resetSection(true);
				else
					resetSection();
			}


			if (FlxG.mouse.wheel != 0)
			{
				FlxG.sound.music.pause();
				vocals.pause();

				FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);
				vocals.time = FlxG.sound.music.time;
			}

			if (!FlxG.keys.pressed.SHIFT)
			{
				if (FlxG.keys.pressed.W || FlxG.keys.pressed.S)
				{
					FlxG.sound.music.pause();
					vocals.pause();

					var daTime:Float = 700 * FlxG.elapsed;

					if (FlxG.keys.pressed.W)
					{
						FlxG.sound.music.time -= daTime;
					}
					else
						FlxG.sound.music.time += daTime;

					vocals.time = FlxG.sound.music.time;
				}
			}
			else
			{
				if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.S)
				{
					FlxG.sound.music.pause();
					vocals.pause();

					var daTime:Float = Conductor.stepCrochet * 2;

					if (FlxG.keys.justPressed.W)
					{
						FlxG.sound.music.time -= daTime;
					}
					else
						FlxG.sound.music.time += daTime;

					vocals.time = FlxG.sound.music.time;
				}
			}
		}

		if (FlxG.mouse.x > eventRow.x
			&& FlxG.mouse.x < eventRow.x + eventRow.width
			&& FlxG.mouse.y > eventRow.y
			&& FlxG.mouse.y < eventRow.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
		{
			dummyEvent.visible=true;
			var time = getEventTime(FlxG.mouse.y);
			var beat = Conductor.getBeat(time + sectionStartTime());
			var snap = 4/quantization;
			var x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			var y = getYfromEvent(Conductor.beatToSeconds(Math.floor(beat / snap) * snap) - sectionStartTime());

			if (FlxG.keys.pressed.SHIFT)
				y = FlxG.mouse.y;

			if(dummyEvent.y!=y || dummyEvent.x!=x){
				dummyEvent.x = x;
				dummyEvent.y = y;
			}
		}else{
			dummyEvent.visible=false;
		}

		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
		{
			var time = getStrumTime(FlxG.mouse.y);
			var beat = Conductor.getBeat(time + sectionStartTime());
			var snap = 4/quantization;
			var x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			var y = getYfromStrum(Conductor.beatToSeconds(Math.floor(beat / snap) * snap) - sectionStartTime());

			dummyArrow.visible=true;
			if (FlxG.keys.pressed.SHIFT)
				y = FlxG.mouse.y;

			if(dummyArrow.y!=y || dummyArrow.x!=x){
				var beat = Conductor.getBeatInMeasure(getStrumTime(y) + sectionStartTime());
				var quant = Note.getQuant(beat);
				if(dummyArrow.quantTexture!=quant){
					dummyArrow.quantTexture = quant;

					dummyArrow.setTextures();
				}
				dummyArrow.setDir(Math.floor(FlxG.mouse.x / GRID_SIZE)%4,0,false);
				dummyArrow.setGraphicSize(GRID_SIZE,GRID_SIZE);
				dummyArrow.updateHitbox();
				dummyArrow.x = x;
				dummyArrow.y = y;
			}
		}else{
			dummyArrow.visible=false;
		}


		timeTxt.text = Std.string(
			"Song Time: " + FlxMath.roundDecimal(Conductor.songPosition / 1000, 2)) + " / "	+ Std.string(FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2)) + "\n";

		songInfoTxt.text =
			"Section: " + curSection +
			"\nStep: " + CoolUtil.truncateFloat(curDecStep,2) +
			"\nBeat: " + CoolUtil.truncateFloat(curDecBeat,2) +
			"\nSnap: 1/" + quantization + "\n";

		controlsTxt.text =
			"Press W or S to\nmove between sections.\n\n" +
			"Press Left or Right to\nchange the note snapping to\nchart. (Default is 1/16)\n\n" +
			"Press and Hold Shift\n to bypass snapping.\n\n" +
			"Press Left/Right Click to\n place a note (or remove \na note if one is already\n placed) on the charting grid.\n\n";

		Conductor.lastSongPos = Conductor.songPosition;
		super.update(elapsed);
	}

	function changeNoteSustain(value:Float,?note):Void
	{
		if(note==null)note=curSelectedNote;
		if(note==null)return;
		setNoteSustain(note[2]+value);
	}

	function setNoteSustain(value:Float,?note):Void
	{
		if(note==null)note=curSelectedNote;

		if (note != null)
		{
			if (note[2] != null)
			{
				note[2] = Math.max(value, 0);
			}
		}

		updateNoteUI();
		updateGrid();
	}

	public function startSong(?pos:Float){
		lastSection = curSection;
		var time = FlxG.sound.music.time;
		songPos = time;
		PlayState.setSong(_song);
		PlayState.SONG.sliderVelocities = velChanges;
		FlxG.sound.music.stop();
		vocals.stop();
		FlxG.mouse.visible = false;
		PlayState.startPos = pos==null?0:pos;
		PlayState.inCharter=true;
		OptionUtils.saveOptions(OptionUtils.options);
		FlxG.switchState(new PlayState());
	}

	function recalculateSteps():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (FlxG.sound.music.time > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((FlxG.sound.music.time - lastChange.songTime) / Conductor.stepCrochet);
		updateBeat();

		return curStep;
	}

	function resetSection(songBeginning:Bool = false):Void
	{

		FlxG.sound.music.pause();
		vocals.pause();

		// Basically old shit from changeSection???
		FlxG.sound.music.time = sectionStartTime();

		if (songBeginning)
		{
			FlxG.sound.music.time = 0;
			curSection = 0;
		}

		vocals.time = FlxG.sound.music.time;
		updateCurStep();

		updateGrid();
		updateSectionUI();
	}

  function changeSection(newSec:Int = 0, ?updateMusic:Bool = true):Void
	{
		trace('changing section ' + newSec);
    for(sec in curSection ... newSec){
      if (_song.notes[sec] == null)
      {
        _song.notes[sec] = {
    			lengthInSteps: 16,
    			bpm: _song.bpm,
    			changeBPM: false,
    			mustHitSection: true,
    			sectionNotes: [],
    			typeOfSection: 0,
    			altAnim: false,
    			events: []
    		};
      }
    }
    var sec = newSec;
		if (_song.notes[sec] != null)
		{
			curSection = sec;

			if (updateMusic)
			{
				FlxG.sound.music.pause();
				vocals.pause();

				FlxG.sound.music.time = sectionStartTime();
				vocals.time = FlxG.sound.music.time;
				updateCurStep();
			}
			if(_song.notes[curSection].events==null)_song.notes[curSection].events=[];

			updateSectionUI();
			for(i in curRenderedNotes){
				i.wasGoodHit=false;
			}
		}

    updateGrid();
	}

	function copySection(?sectionNum:Int = 0){

		// i'll rewrite this some day
		// probably get the beat/whatever in the section
		// and then move it to that same beat in the current section

		var diff = curSection - sectionNum;

		for (note in _song.notes[sectionNum].sectionNotes)
		{
			var strum = note[0] + Conductor.stepCrochet * (_song.notes[sectionNum].lengthInSteps * diff);

			var copiedNote:Array<Dynamic> = [strum, note[1], note[2], note[3]];
			var canCopy:Bool=true;
			for(nD in _song.notes[curSection].sectionNotes){
				if(nD[0]==copiedNote[0] && nD[1]==copiedNote[1]){
					canCopy=false;
					break;
				}
			}
			if(canCopy)_song.notes[curSection].sectionNotes.push(copiedNote);
		}

		for (event in _song.notes[sectionNum].events)
		{
			var strum = event.time + Conductor.stepCrochet * (_song.notes[sectionNum].lengthInSteps * diff);

			var copy:Section.Event = {
				time: strum,
        events: event.events,
			};
			var canCopy:Bool=true;
			for(nD in _song.notes[curSection].events){
				if(nD.time==copy.time ){
					canCopy=false;
					break;
				}
			}

			if(canCopy)_song.notes[curSection].events.push(copy);
		}

		updateGrid();
	}

	function copySectionLast(?sectionNum:Int = 1)
	{
		var daSec = FlxMath.maxInt(curSection, sectionNum);
		if(_song.notes[daSec - sectionNum]==null)return;
		var daBPM:Float = _song.bpm;
		var offsetArray:Array<Float> = [];
		var totalOffsets:Float = 0;
		var copyOffsets:Float = 0;

		if (daSec > 0){
			for (i in 0...daSec)
			{
				if (_song.notes[i].changeBPM)
					daBPM = _song.notes[i].bpm;

					offsetArray.push((1000 * 60 / daBPM) * (_song.notes[i].lengthInSteps / 4));
			}
			for (i in 0...daSec)
				totalOffsets += offsetArray[i];

			for (i in 0...(daSec-sectionNum))
				copyOffsets += offsetArray[i];
		}
		var section = _song.notes[daSec - sectionNum];
		for (note in section.sectionNotes)
		{
			var noteRatio = (note[0]-copyOffsets) / offsetArray[daSec-sectionNum];

			var holdRatio = (Conductor.crochet * 4) / offsetArray[daSec-sectionNum];

			var strum = totalOffsets + noteRatio * Conductor.crochet * 4; //Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * value);
			var sus = note[2] * holdRatio;

			var copiedNote:Array<Dynamic> = [strum, note[1], sus, note[3]];
			var canCopy:Bool=true;
			for(nD in _song.notes[daSec].sectionNotes){
				if(nD[0]==copiedNote[0] && nD[1]==copiedNote[1]){
					canCopy=false;
					break;
				}
			}
			if(canCopy)_song.notes[daSec].sectionNotes.push(copiedNote);
		}
		if(section.events==null)section.events=[];

		for (event in section.events)
		{
			var noteRatio = (event.time-copyOffsets) / offsetArray[daSec-sectionNum];

			var holdRatio = (Conductor.crochet * 4) / offsetArray[daSec-sectionNum];

			var strum = totalOffsets + noteRatio * Conductor.crochet * 4; //Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * value);

			var copy:Section.Event = {
        time: strum,
        events: event.events,
			};
			var canCopy:Bool=true;
			for(nD in _song.notes[curSection].events){
				if(nD.time==copy.time ){
					canCopy=false;
					break;
				}
			}

			if(canCopy)_song.notes[curSection].events.push(copy);
		}

		updateGrid();
	}

	function updateSectionUI():Void
	{
		var sec = _song.notes[curSection];

		check_mustHitSection.checked = sec.mustHitSection;
		check_altAnim.checked = sec.altAnim;
		check_changeBPM.checked = sec.changeBPM;
		stepperSectionBPM.value = sec.bpm;

		updateHeads();
	}

	function updateHeads():Void
	{
		if (check_mustHitSection.checked)
		{
			leftIcon.changeCharacter(Character.getIcon(_song.player1));
			rightIcon.changeCharacter(Character.getIcon(_song.player2));
			leftIcon.setGraphicSize(0, 45);
			rightIcon.setGraphicSize(0, 45);
		}
		else
		{
			leftIcon.changeCharacter(Character.getIcon(_song.player2));
			rightIcon.changeCharacter(Character.getIcon(_song.player1));
			leftIcon.setGraphicSize(0, 45);
			rightIcon.setGraphicSize(0, 45);
		}
	}

	function updateMarkerUI():Void
	{
    if(selectedEventData!=null){
      eventName = selectedEventData.events[curSelectedEvent].name;
      eventDropdown.selectedLabel = eventName;
      eventSelectedText.text = 'Selected: ${curSelectedEvent+1} / ${selectedEventData.events.length}';
    }else{
      eventSelectedText.text = 'Selected: None';
    }

    //selectedEventText.text = 'Selected Event: ' + (curEventSelected + 1) + ' / ' + curSelectedNote[1].length;


		updateArgDropdown();
		updateWidgets();
	}

	function updateNoteUI():Void
	{
		if (curSelectedNote != null){
			stepperSusLength.value = curSelectedNote[2];
			selectedType.selectedLabel = EngineData.noteTypes[curSelectedNote[3]];
			check_isRoll.checked = curSelectedNote[4];
		}
	}

	function createNote(i:Array<Dynamic>, ?section:Int):Note{
		if(section==null)section=curSection;

		var daNoteInfo = i[1];
		var daStrumTime = i[0];
		var daSus = i[2];

		var note:Note = new Note(daStrumTime, daNoteInfo%4, EngineData.options.noteSkin, PlayState.noteModifier, EngineData.noteTypes[i[3]], null, false, i[4]==true, 0, true);
		note.wasGoodHit = daStrumTime<Conductor.songPosition;
		note.rawNoteData = daNoteInfo;
		note.mustPress = _song.notes[section].mustHitSection;
		if(daNoteInfo>3)note.mustPress=!note.mustPress;

		note.sustainLength = daSus;
		note.setGraphicSize(GRID_SIZE, GRID_SIZE);
		note.updateHitbox();
		note.x = Math.floor(daNoteInfo * GRID_SIZE);
		note.y = getYfromStrum((daStrumTime - sectionStartTime(section)) % (Conductor.stepCrochet * _song.notes[section].lengthInSteps));

		return note;
	}

	function createSustains(i:Array<Dynamic>, baseNote:Note, daSus:Float){
		var daNoteInfo = i[1];
		var daStrumTime = i[0];
		var sus:Array<Note> = [];
		var oldNote:Note = baseNote;
    var func = Math.round;
    if(!OptionUtils.options.fixHoldSegCount)func=Math.floor;
		for (susNote in 0...func(daSus))
		{
			var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteInfo % 4, EngineData.options.noteSkin, PlayState.noteModifier, EngineData.noteTypes[i[3]], oldNote, true, i[4]==true, 0, true);
			sustainNote.rawNoteData = daNoteInfo;
			sustainNote.setGraphicSize(GRID_SIZE, GRID_SIZE);
			sustainNote.updateHitbox();
			sustainNote.x = Math.floor(daNoteInfo * GRID_SIZE);
			sustainNote.y = oldNote.y + GRID_SIZE;
			sustainNote.flipY = false;
			sustainNote.scale.y = 1;
			oldNote = sustainNote;
			sus.push(sustainNote);
		}
		for(i in sus){
			switch(i.noteType){
				default:
					if(i.animation.curAnim!=null && i.animation.curAnim.name.endsWith("end") ){
						if(PlayState.curStage.startsWith("school")){
							i.setGraphicSize(Std.int(GRID_SIZE*.35), Std.int(GRID_SIZE*.35));
							i.updateHitbox();
							i.offset.x = -17.25;
							i.offset.y = (GRID_SIZE*.35)/2-12;
						}else{
							i.setGraphicSize(Std.int(GRID_SIZE*.35), Std.int((GRID_SIZE)/2)+2);
							i.updateHitbox();
							i.offset.x = 5;
							i.offset.y = (GRID_SIZE)/2+2;
						}

						i.x = Math.floor(i.rawNoteData * GRID_SIZE);
					}else{
						i.setGraphicSize(Std.int(GRID_SIZE*.35), GRID_SIZE+1);
						i.updateHitbox();
						i.offset.x = 5;
						if(PlayState.curStage.startsWith("school")){
							i.offset.x = -17.25;
						}
						i.x = Math.floor(i.rawNoteData * GRID_SIZE);
					}
				}
			}
			return sus;
	}

	function updateGrid():Void
	{
    trace("updating grid");
		curRenderedMarkers.clear();

		curRenderedNotes.clear();
		curRenderedSustains.clear();
		curRenderedEvents.clear();

		nextRenderedNotes.clear();
		nextRenderedSustains.clear();
		nextRenderedEvents.clear();

		var sectionInfo:Array<Dynamic> = _song.notes[curSection].sectionNotes;
		var events:Array<Dynamic> = _song.notes[curSection].events;

		if (_song.notes[curSection].changeBPM && _song.notes[curSection].bpm > 0)
		{
			Conductor.changeBPM(_song.notes[curSection].bpm);
			FlxG.log.add('CHANGED BPM!');
		}
		else
		{
			// get last bpm
			var daBPM:Int = _song.bpm;
			for (i in 0...curSection)
				if (_song.notes[i].changeBPM)
					daBPM = _song.notes[i].bpm;
			Conductor.changeBPM(daBPM);
		}

		var idx:Int=0;
		if(events!=null){
			for(i in events){
				var eventMarker = new NoteGraphic(i.time, PlayState.noteModifier, EngineData.options.noteSkin, Note.noteBehaviour);
				eventMarker.setDir(1,0,false);
				eventMarker.setGraphicSize(GRID_SIZE,GRID_SIZE);
				eventMarker.updateHitbox();
				eventMarker.x = eventRow.x;
				eventMarker.y = getYfromEvent((i.time - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps));
				eventMarker.ID = idx;
				idx++;
				curRenderedEvents.add(eventMarker);
			}
		}

		for(i in velChanges){
			if(i.startTime>=sectionStartTime() && i.startTime<sectionEndTime()){
				var marker = new FlxSprite(-50, 50).makeGraphic(64, 12);
				marker.health = i.startTime;
				marker.y = getYfromStrum((i.startTime - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps));
				curRenderedMarkers.add(marker);
			}
		}

		var oldNote:Note;
		for (i in sectionInfo)
		{
      if(i[1]<0)continue;
			var note:Note = createNote(i);
			oldNote=note;


			var daSus:Float = i[2];
			curRenderedNotes.add(note);
			if(!note.canHold)daSus=0;
			if (daSus > 0)
			{
				daSus = daSus/Conductor.stepCrochet;
				var sus = createSustains(i, note, daSus);
				for(sussy in sus)
					curRenderedSustains.add(sussy);

				oldNote = sus[sus.length-1];
			}
		}

		if(check_sexPreview.checked){
			var nextSex = _song.notes[curSection+1];
			if(nextSex!=null){
				var oldNote:Note;
				for (i in nextSex.sectionNotes)
				{
          if(i[1]<0)continue;
					var note:Note = createNote(i, curSection+1);
					oldNote=note;
					note.alpha = 0.7;
					note.y += GRID_SIZE*16;
					var daNoteInfo = i[1];
					if(nextSex.mustHitSection!=_song.notes[curSection].mustHitSection){
						if(daNoteInfo>3)
							daNoteInfo = daNoteInfo - 4;
						else
							daNoteInfo = daNoteInfo + 4;

						note.x = Math.floor(daNoteInfo * GRID_SIZE);
					}


					var daSus:Float = i[2];
					nextRenderedNotes.add(note);
					if(!note.canHold)daSus=0;
					if (daSus > 0)
					{
						daSus = daSus/Conductor.stepCrochet;
						var sus = createSustains(i, note, daSus);
						for(sussy in sus){
							nextRenderedSustains.add(sussy);
							sussy.x = Math.floor(daNoteInfo * GRID_SIZE);
						}

						oldNote = sus[sus.length-1];
					}
				}
				if(nextSex.events!=null){
					for(i in nextSex.events){
						var eventMarker = new NoteGraphic(i.time, PlayState.noteModifier, EngineData.options.noteSkin, Note.noteBehaviour);
						eventMarker.alpha = 0.7;
						eventMarker.setDir(1,0,false);
						eventMarker.setGraphicSize(GRID_SIZE,GRID_SIZE);
						eventMarker.updateHitbox();
						eventMarker.x = eventRow.x;
						eventMarker.y = getYfromEvent((i.time - sectionStartTime(curSection+1)) % (Conductor.stepCrochet * nextSex.lengthInSteps)) + GRID_SIZE*16;
						eventMarker.ID = idx;
						idx++;
						nextRenderedEvents.add(eventMarker);
					}
				}
			}
		}
	}

	private function addSection(lengthInSteps:Int = 16):Void
	{
		var sec:SwagSection = {
			lengthInSteps: lengthInSteps,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: true,
			sectionNotes: [],
			typeOfSection: 0,
			altAnim: false,
			events: []
		};

		_song.notes.push(sec);
	}

	function selectNote(note:Note):Void
	{
		for (i in _song.notes[curSection].sectionNotes)
		{
			trace(i[0],i[1],note.strumTime,note.rawNoteData);
			if (i[0] == note.strumTime && i[1] == note.rawNoteData)
			{
				curSelectedNote = i;
				lastMousePos.set(dummyArrow.x,dummyArrow.y);
				if(FlxG.mouse.pressed)
					recentNote = i;

			}
		}

		updateNoteUI();
		updateGrid();
	}

	function deleteNote(note:Note):Void
	{
		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i[0] == note.strumTime && i[1] == note.rawNoteData)
			{
				FlxG.log.add('FOUND EVIL NUMBER');
				_song.notes[curSection].sectionNotes.remove(i);
				break;
			}
		}
		updateMarkerUI();
		updateGrid();
	}

  function changeSelectedEvent(select:Int, exact:Bool=false) : Void {
    if(exact)
      curSelectedEvent=select;
    else
      curSelectedEvent+=select;

    curSelectedArg=0;

    if(selectedEventData!=null){
      if(curSelectedEvent>=selectedEventData.events.length)curSelectedEvent=0;
      if(curSelectedEvent<0)curSelectedEvent=selectedEventData.events.length-1;
      selectedEvent = selectedEventData.events[curSelectedEvent];
    }
    updateMarkerUI();
  }

	function selectEvent(event:NoteGraphic):Void
	{
		var idx=0;
		if(_song.notes[curSection].events==null)_song.notes[curSection].events=[];
		for (data in _song.notes[curSection].events)
		{
			if (event.ID==idx)
			{
				selectedEventData = data;
        changeSelectedEvent(0,true);
				break;
			}
			idx++;
		}

		updateMarkerUI();
		updateGrid();
	}

	function deleteEvent(event:NoteGraphic):Void
	{
		var idx=0;
		if(_song.notes[curSection].events==null)_song.notes[curSection].events=[];
		for (data in _song.notes[curSection].events)
		{
			if (event.ID==idx)
			{
				FlxG.log.add('FOUND EVIL NUMBER');
				_song.notes[curSection].events.remove(data);
				break;
			}
			idx++;
		}
		updateMarkerUI();
		updateGrid();
	}

	function selectMarker(marker:FlxSprite):Void
	{
		for (i in velChanges)
		{
			if (marker.health == i.startTime)
			{
				curSelectedMarker = i;
			}
		}
		updateMarkerUI();
		updateGrid();
	}

	function deleteMarker(marker:FlxSprite):Void
	{
		for (i in velChanges)
		{
			if (marker.health == i.startTime)
			{
				velChanges.remove(i);
			}
		}

		updateGrid();
	}

	function clearSection():Void
	{
		_song.notes[curSection].sectionNotes = [];
    _song.notes[curSection].events = [];
		updateGrid();
	}

	function clearSong():Void
	{
		for (daSection in 0..._song.notes.length)
		{
			_song.notes[daSection].sectionNotes = [];
		}

		updateGrid();
	}

	private function addEvent():Void
	{
		var eventStrum = getEventTime(dummyEvent.y) + sectionStartTime();
		if(_song.notes[curSection].events==null)_song.notes[curSection].events=[];

		_song.notes[curSection].events.push({
      events: [{
  			args: eventArgs,
        name: eventName,
      }],
			time: eventStrum

		});

		selectedEventData = _song.notes[curSection].events[_song.notes[curSection].events.length - 1];
    changeSelectedEvent(0,true);

		updateGrid();
		updateMarkerUI();
		autosaveSong();

	}

	private function addNote(rightClick:Bool):Void
	{
		var noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime();
		var noteData = Math.floor(FlxG.mouse.x / GRID_SIZE);
		for(nD in _song.notes[curSection].sectionNotes){
			if(nD[0]==noteStrum && nD[1]==noteData){
				return;
			}
		}
		var noteSus = 0;
		var type = Std.parseInt(rightClick?rightType.selectedId:leftType.selectedId);

		_song.notes[curSection].sectionNotes.push([noteStrum, noteData, noteSus, type]);

		curSelectedNote = _song.notes[curSection].sectionNotes[_song.notes[curSection].sectionNotes.length - 1];
		recentNote = curSelectedNote;
		if(FlxG.keys.pressed.CONTROL)
			_song.notes[curSection].sectionNotes.push([noteStrum, (noteData+4)%8, noteSus, type]);


		updateGrid();
		updateNoteUI();

		autosaveSong();
	}

	function getStrumTime(yPos:Float):Float
	{
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + (GRID_SIZE*16), 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float):Float
	{
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + (GRID_SIZE*16));
	}

	function getEventTime(yPos:Float):Float
	{
		return FlxMath.remapToRange(yPos, eventRow.y, eventRow.y + (GRID_SIZE*16), 0, 16 * Conductor.stepCrochet);
	}

	function getYfromEvent(strumTime:Float):Float
	{
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, eventRow.y, eventRow.y + (GRID_SIZE*16));
	}

	/*
		function calculateSectionLengths(?sec:SwagSection):Int
		{
			var daLength:Int = 0;

			for (i in _song.notes)
			{
				var swagLength = i.lengthInSteps;

				if (i.typeOfSection == Section.COPYCAT)
					swagLength * 2;

				daLength += swagLength;

				if (sec != null && sec == i)
				{
					trace('swag loop??');
					break;
				}
			}

			return daLength;
	}*/
	private var daSpacing:Float = 0.3;

	function loadLevel():Void
	{
		trace(_song.notes);
	}

	function getNotes():Array<Dynamic>
	{
		var noteData:Array<Dynamic> = [];

		for (i in _song.notes)
		{
			noteData.push(i.sectionNotes);
		}

		return noteData;
	}

	function loadJson(song:String):Void
	{
		PlayState.SONG = Song.loadFromJson(song.toLowerCase(), song.toLowerCase());
		FlxG.resetState();
	}

	function loadAutosave():Void
	{
    if(blockInput)return;
		PlayState.SONG = Song.parseJSONshit(FlxG.save.data.autosave);
		FlxG.resetState();
	}

	function autosaveSong():Void
	{
		FlxG.save.data.autosave = Json.stringify({
			"song": _song,
			"sliderVelocities": velChanges,
		},"\t");
		FlxG.save.flush();
	}

	private function saveLevel()
	{
		var json = {
			"song": _song,
			"sliderVelocities": velChanges,
		};

		var data:String = Json.stringify(json,"\t");

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), _song.song.toLowerCase() + ".json");
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}
}
