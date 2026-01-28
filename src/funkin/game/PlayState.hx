package funkin.game;

import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.util.FlxDestroyUtil;
import flixel.text.FlxText.FlxTextFormatMarkerPair;
import funkin.backend.scripting.events.*;
import funkin.backend.scripting.events.game.*;
import funkin.game.*;
import funkin.game.hud.StrumGroup;
import funkin.game.system.*;
import funkin.game.system.SongData.ChartEvent;
import funkin.game.system.SongData.ChartEventGroup;
import funkin.game.system.SongData.Player;
import funkin.game.hud.StrumGroup;

#if sys
import sys.FileSystem;
#end

import funkin.backend.scripting.events.*;
import funkin.backend.scripting.events.game.*;

enum BeatType {
    STEP;
    BEAT;
    MEASURE;
}

typedef CharacterChangeData = {
    character:Character,
    nextCharacter:String,
    previousCharacter:String
}

typedef CampaignData = {
	score:Int,
	misses:Int,
	accuracy:Float,

	sicks:Int,
	goods:Int,
	bads:Int,
	shits:Int
}

@:access(funkin.backend.utils.PrecacheUtil)
class PlayState extends ScriptableState {
    // basic game objects
    public var stage:ScriptableStage;
    public var characters:Array<Character> = [];
	public var bf:Character;
	public var dad:Character;
	public var gf:Character;

    public var camGame:FunkinCamera;
    public var camHUD:FunkinCamera;
	public var camOther:FlxCamera;
    public var camFollow:FlxObject;
    public var hud:HUD;

	// basic song elements
	public var inst:FlxSound;
	public var voices:VoicesHandler;

    // aliases
	public var boyfriend(get, never):Character;
	public var girlfriend(get, never):Character;

    function get_boyfriend():Character return bf;
	function get_girlfriend():Character return gf;

    // camera attributes
    var __camZoomInterval(get, never):Int;
    public var camZoomInterval:Int = 1;
    public var camBeatEvery:BeatType = MEASURE;
    public var gameBeatZoom:Float = 0.028;
    public var hudBeatZoom:Float = 0.015;

    function get___camZoomInterval() {
		final mult = switch (camBeatEvery)
		{
			case MEASURE: 16;
			case BEAT: 4;
			case STEP: 1;
		}
		return camZoomInterval * mult;
	}

    // gameplay attributes
    public var noteKillWindow:Float = 376;
    public var spawnTime:Float = 2000;
    public var playerStrums:StrumGroup;
    public var opponentStrums:StrumGroup;
    public var scrollSpeed:Float = 1;

	// scoring-related
	public var songScore:Int = 0;
	public var songMisses:Int = 0;
	public var songAccuracy(get, never):Float;
	public var ratingName:String = 'N/A';

	var totalNotesHit:Float = 0;
	var totalPlayed:Float = 0;

	function get_songAccuracy() {
		if (totalPlayed != 0)
			return FlxMath.bound(totalNotesHit / totalPlayed);

		return 0;
	}
	
	public static var rankList:Map<String, Array<Dynamic>> = [
		'X'   => [0.99, 0xFF9FECFF],
		'S+'  => [0.95, 0xFFFFBB00],
		'S'   => [0.9 , 0xFFFFE600],
		'A'   => [0.8 , 0xFF56FF56],
		'B'   => [0.65, 0xFF00FFD5],
		'C'   => [0.5 , 0xFF00C3FF],
		'D'   => [0.55, 0xFF3C8AFF],
		'E'   => [0.4 , 0xFF873DFF],
		'F'   => [0   , 0xFFFF5151],
		'N/A' => [-1  , 0xFF808080]
	];

	public static var weekPlaylist:Array<String> = [];
	public static var weekDifficulty:String = '';
	public static var defaultCampaignData:CampaignData = {
		score: 0, misses: 0, accuracy: 0,
		sicks: 0, goods: 0, bads: 0, shits: 0
	}
	public static var campaignData:CampaignData = copyStruct(defaultCampaignData);

    // song attributes
	public var songName(get, never):String;
	public var songPath(get, never):String;
    public var songStarted:Bool = false;
    public var songEnded:Bool = false;
    public var syncThreshold:Float = 25; // in ms
	public var health(default, set):Float = 1;
	public function set_health(val:Float):Float {
		health = FlxMath.bound(val, 0, 2);
		if(hud != null) hud.updateHealthIcons();

		deathCheck(false); // TODO: Add smth to disable this when setting health?
		return health;
	}

	function get_songName() return song?.songName ?? '';
	function get_songPath() return song?.songPath ?? '';

    // misc
	private var precachedTags:Array<String> = [];
    public var singAnims:Array<String> = [
        'singLEFT', 'singDOWN', 'singUP', 'singRIGHT'
    ];
    public var keyNames:Array<String> = [
        'note_left', 'note_down', 'note_up', 'note_right'
    ];

    // static vars 
    public static var song(default, set):SongData;
    public static var isPixelStage(default, set):Bool = false;

	static function set_song(data:SongData)
	{
		if (data.chart == null)
			return song = null;

		return song = data;
	}

	// wip
	static function set_isPixelStage(value:Bool)
		return isPixelStage = value;

	// TEMPORARY UNTIL COUNTDOWN IS A THING!!
	public var pressLeEnter:FlxText;
    public var pressedEnter:Bool = false;

	// hscript & lua
	public static var instance:PlayState;

	public function new() {
		instance = this;
		super();
	}

    override function create() {
        if (song == null) {
            final songToLoad = 'unknown-suffering';
            loadSong(songToLoad, getMedianDifficulty(songToLoad));
        }

        // loading scripts
		if (songPath != null && Paths.exists('songs/$songPath/scripts'))
			addScriptsFromDirectory('songs/$songPath/scripts');
        
		set('game', this);

        if (FlxG.sound.music != null)
            FlxG.sound.music.stop();

        // ratings initialization
		Rating.add('sick', 45, 350, 1);
		Rating.add('good', 90, 250, 0.67);
		Rating.add('bad', 135, 100, 0.34);
		Rating.add('shit', 188, 100, 0);

        // cameras
		camGame = new FunkinCamera();
		FlxG.cameras.add(camGame);
		FlxG.camera = camGame;

		camFollow = new FlxObject();
		camGame.follow(camFollow, LOCKON, 0.083);

		camHUD = new FunkinCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD, false);

		camOther = new FlxCamera();
		camOther.bgColor = 0x0;
		FlxG.cameras.add(camOther, false);

        // hud elements
		hud = new HUD(this);
		hud.camera = camHUD;
		add(hud);

		playerStrums = new StrumGroup();
		opponentStrums = new StrumGroup();
		playerStrums.camera = hud.camera;
		opponentStrums.camera = hud.camera;

        // loading stage
        stage = new ScriptableStage(song.stage);
        add(stage);

        camGame.defaultCamZoom = stage?.defaultCamZoom ?? 0.9;
		camGame.zoom = camGame.defaultCamZoom;

        scrollSpeed = (song?.scrollSpeed ?? 1) * GameplayModifiers.scrollMult;
        
		call('create');

        var characterInfos:Array<Player> = (song?.characters ?? []);
		characterInfos.reverse();
        for (j => charInfo in characterInfos) {
            final i = characterInfos.length - 1 - j;
            var character = new Character(stage.characterPositions[i]?.x ?? 0, stage.characterPositions[i]?.y ?? 0, charInfo.name, charInfo.isPlayer);
            character.isBopper = charInfo.isBopper ?? false;
			character.hideStrumline = charInfo.hideStrumline ?? false;
            character.characterID = i;
            add(character);
            characters.push(character);
        }

		dad = first(characters.filter(c -> return !c.isPlayer && !c.isBopper));
		bf = first(characters.filter(c -> return c.isPlayer && !c.isBopper));
		gf = first(characters.filter(c -> return c.isBopper));
		focusCharacter();

        inst = new FlxSound();
        inst.loadEmbedded(loadSound(Paths.inst(songPath)), false, false, endSong);
        inst.volume = 0.8;
        FlxG.sound.list.add(inst);

        voices = new VoicesHandler(inst, songPath);

        inst.pause();
        voices.pause();
        initVoices();

        hud.loadStrums();
        hud.loadNotes();
		initEvents();

		hud.loadHealthBar(bf.icon, dad.icon);
		health = 1;

		hud.loadScoreText();

		if (GameplayModifiers.opponentMode) {
			for (strumline in hud.strumlines)
				strumline.cpu = !strumline.cpu;
		}

        super.create();

        call('createPost');

        // TEMPORARY
		pressLeEnter = new FlxText(0, 0, 0);
		pressLeEnter.camera = camHUD;
		pressLeEnter.setFormat(Paths.font('funkin'), 26, -1, CENTER, OUTLINE, 0xFF000000);
		pressLeEnter.applyMarkup('Press <y>ENTER<y> to Start the Song', [new FlxTextFormatMarkerPair(new FlxTextFormat(0xFFFFFF00), '<y>')]);
		pressLeEnter.borderSize = 2;
		pressLeEnter.screenCenter();
		add(pressLeEnter);
    }

    /**
     * Loads additional voice files for characters if they exists.
     */
    function initVoices() {
        for (character in characters) {
			if (Paths.exists(Paths.voices(songPath, '-${character.name}', false), false))
				voices.addVoices('-${character.name}');

			for (postfix in ['-Player', '-Opponent', '-player', '-opponent'])
				if (Paths.exists(Paths.voices(songPath, postfix, false), false))
					voices.addVoices(postfix);
        }
    }
    
    public var events:Array<ChartEventGroup> = [];
    /**
     * Initializes the events defined in the song's difficulty chart.
     */
    function initEvents() {
        final songEvents = song?.chart?.events ?? null;
        if (songEvents == null)
            return;

        var hasCharacterChanges:Bool = false;
        final collectedChanges:Array<CharacterChangeData> = [];
        for (eventGrp in songEvents) {
            for (event in eventGrp.events) {
                var scriptEvent = new EventLoadEvent(eventGrp.strumTime, event);
                call('onLoadEvent', [scriptEvent]);

                if (scriptEvent.cancelled)
                    eventGrp.events.remove(event);
                else {
                    switch(event.event) {
                        case 'Change Character': // character preloading
                            hasCharacterChanges = true;

							final char = characterFromID(event.values[0]);
                            collectedChanges.push({
                                character: char,
                                nextCharacter: event.values[1],
								previousCharacter: char.name
                            });
                    }
                }
            }
			events.push(eventGrp);
        }

        if (hasCharacterChanges) {
            initCharacterChanges(collectedChanges);
        }

        events.sort(HUD.sortByTime);
        call('onEventsLoaded', []); 
    }

    /**
     * Precaches characters that will present later in the song based on the given changes.
     * @param changes an Array of CharacterChangeData.
     */
    function initCharacterChanges(changes:Array<CharacterChangeData>) {
		var changed:Array<Bool> = [ for (_ in 0...changes.length) false ];
		function hasChanges(character:Character) {
			for (i => change in changes)
			{
				if (change.character == character && !changed[i])
					return true;
			}
			return false;
		}

        for (i => change in changes) {
            final character = change.character;
			final precacheTag = 'character_obj_${change.nextCharacter}';
			if (!PrecacheUtil.__cache.exists(precacheTag)) {
            	character.loadCharacter(change.nextCharacter);

            	var precachedChar = character.clone();
				precachedChar.alpha = 0.001;
				insert(members.indexOf(character), precachedChar);

				PrecacheUtil.__cache.set(precacheTag, precachedChar);
				precachedTags.push(precacheTag);
			}

			changed[i] = true;
			if (!hasChanges(character)) {
				character.loadCharacter(change.previousCharacter);
            }
        }
    }

    var allowStart:Bool = true;
    override function update(elapsed:Float) {
		call('update', [elapsed]);

        if (inst != null) {
			if (!songEnded && Math.abs((voices.container[0] != null ? voices.time : inst.time) - (Conductor.songPosition - Conductor.offset)) > syncThreshold) {
				sync();
				trace('synced!');
			}
        }

        checkForKeys();
        checkForPause();

        checkForEvent(Conductor.songPosition);

		if (FlxG.keys.justPressed.BACKSPACE) {
			FlxG.switchState(new funkin.states.FreeplayState());
		}

		super.update(elapsed);

		call('updatePost', [elapsed]);

		if (!pressedEnter && FlxG.keys.justPressed.ENTER)
		{
			pressedEnter = true;

			startSong();
			pressLeEnter.kill();
		}
    }

    /*
     * ######################
     * ##   INPUT CHECKS   ##
     * ######################
     */

    /**
     * Checks for key presses for each keybinds, calls keyPressed, keyJustPressed or keyJustReleased
       corresponding to the current user action.
     */
    function checkForKeys() {
        for (keyName => keybinds in Preferences.keyBinds) {
            final index = keyNames.indexOf(keyName);
			if (FlxG.keys.anyPressed(keybinds)) keyPressed(index);
			if (FlxG.keys.anyJustPressed(keybinds)) keyJustPressed(index);
			if (FlxG.keys.anyJustReleased(keybinds)) keyJustReleased(index);
        }
    }

    function keyPressed(key:Int) {
		call('keyPressed', [key]);

		for (strumline in hud.strumlines) {
			if (!strumline.cpu) {
				final strum = strumline.members[key];
				if (!strum.animation.name.contains('confirm')) {
					strum.allowStatic = false;
					strum.playAnim('press');
				}
			}
		}
	}

	function keyJustPressed(key:Int) {
		call('keyJustPressed', [key]);

		for (note in hud.notes) {
			if (note.noteData == key && !note.strum.cpu) {
				if (note.canBeHit) {
					hitNote(note);
					break;
				}
			}
		}
	}

	function keyJustReleased(key:Int) {
		call('keyJustReleased', [key]);

		for (strumline in hud.strumlines) {
			if (!strumline.cpu) {
				final strum = strumline.members[key];
				strum.playStatic();
			}
		}
	}

	/*
	 * ############################
	 * ##   SONG EVENT-RELATED   ##
	 * ############################
	 */

    function checkForEvent(strumTime:Float) {
		for (eventGrp in events) {
			if (strumTime >= eventGrp.strumTime) {
				events.remove(eventGrp);
				for (event in eventGrp.events) {
					triggerEvent(event, eventGrp.strumTime);
				}
			}
			else
				break; // no point in iterating on future events
		}
    }

    function triggerEvent(event:ChartEvent, ?strumTime:Float) {
        strumTime ??= Conductor.songPosition;

        var scriptEvent = new EventTriggeredEvent(event, strumTime);
        call('onEvent', [scriptEvent]);

        if (!scriptEvent.cancelled) {
			switch (event.event) { // hardcoded events
				case 'Move Camera':
					focusCharacter(int(event.values[0]));
				case 'Change Character':
					for (i in 0...characters.length)
					{
						var char = characters[i];
						if (char == null) continue;
						if (char.characterID == event.values[0])
						{
							var __lastChar:Character = char;
							final __precachedTag = 'character_obj_${event.values[1]}';

							 {
								characters[i] = PrecacheUtil.__cache.get(__precachedTag);
								//PrecacheUtil.__cache.remove(__precachedTag);
							}

							var char = characters[i];
							char.setPosition(__lastChar.x, __lastChar.y);
							char.alpha = __lastChar.alpha;
							char.visible = __lastChar.visible;
							char.playAnim(__lastChar.animation.curAnim.name);

							for (note in hud.notes)
							{
								if (note.character == __lastChar)
									note.character = char;
							}

							for (strumline in hud.strumlines)
							{
								if (strumline.character == __lastChar)
									Reflect.setProperty(strumline, 'character', char);
							}

							__lastChar.alpha = 0.001;

							break;
						}
					}
				case 'Play Animation':
					final character = characterFromID(event.values[1]);
					character.playAnim(event.values[0], true);
					character.specialAnim = true;
				case 'Add Camera Zoom':
					camGame.zoom += event.values[0];
					camHUD.zoom += event.values[1];
            }
        }
    }

	/*
	 * ########################
	 * ##   CAMERA-RELATED   ##
	 * ########################
	 */

    function focusCharacter(characterID:Int = 0) {
		characterID = int(FlxMath.bound(characterID, 0, characters.length - 1));
		final character = characters[characterID];
		final pos = character.getCameraPosition();

		var event:CameraMoveEvent = new CameraMoveEvent(character, pos);
		call('onCameraMove', [event]);
		if (!event.cancelled)
			camFollow.setPosition(event.position.x, event.position.y);
    }

	/*
	 * ################################
	 * ##	   SUBSTATE RELATED	 	 ##
	 * ################################
	 */

	var isPaused:Bool = false;
	var canPause:Bool = true;
	/**
	 * Checks if the pause key was pressed, pauses the game if so.
	 * Can be cancelled with scripts.
	 */
	function checkForPause() {
		if (FlxG.keys.justPressed.ENTER && canPause && pressedEnter && !songEnded) {
			var subState = new funkin.game.substates.PauseSubstate(this);
			var event:GamePauseEvent = new GamePauseEvent(Conductor.songPosition, subState);

			call('onPause', [event]);
			if (!event.cancelled) {
				persistentDraw = true;
				persistentUpdate = false;
				isPaused = true;

				openSubState(subState);
			}
			else subState.close();
		}
	}

	var hasDied:Bool = false;
	public static var deathCounter:Int = 0;
	function deathCheck(forceDeath:Bool = false):Bool {
		if(forceDeath || (health <= 0)) {
			var subState = new funkin.game.substates.GameOverSubstate(this);
			var event:GamePauseEvent = new GamePauseEvent(Conductor.songPosition, subState);
			call('onGameOver', [event]);

			if(!event.cancelled) {
				deathCounter++;
				isPaused = true; // This basically is another pause menu!
				persistentDraw = persistentUpdate = false;

				inst?.stop();
				voices?.stop();

				FlxTimer.globalManager.clear();
				FlxTween.globalManager.clear();

				openSubState(subState);

				return true;
			}
			else subState.close();
		}
		return false;
	}

	// Just some managing for substates, so the song pauses when a substate is opened
	override function openSubState(SubState:FlxSubState) {
		if(isPaused) {
			FlxTimer.globalManager.forEach(function(tmr:FlxTimer) if(!tmr.finished) tmr.active = false);
			FlxTween.globalManager.forEach(function(twn:FlxTween) if(!twn.finished) twn.active = false);

			inst?.pause();
			voices?.pause();
		}

		super.openSubState(SubState);
	}

	override function closeSubState() {
		super.closeSubState();

		if(isPaused) {
			sync();
			FlxTimer.globalManager.forEach(function(tmr:FlxTimer) if(!tmr.finished) tmr.active = true);
			FlxTween.globalManager.forEach(function(twn:FlxTween) if(!twn.finished) twn.active = true);

			isPaused = false;
			persistentDraw = true;
			persistentUpdate = true;
			inst?.resume();
			voices?.resume();
		}
	}

	/*
	 * ################################
	 * ##   NOTE HIT/MISS HANDLERS   ##
	 * ################################
	 */

    /**
     * Hits the specified note.
     * Meant to be called internally.
     * @param note The note to be hit.
     */
    public function hitNote(note:Note) {
		final rating = Rating.judge(note.strumTime, Conductor.songPosition);
		if (rating == null) return;
		
		final ratingName = rating?.name ?? '';
		note.rating = ratingName;

		if (ratingName != 'miss') {
			var event = new NoteEvent(note);
			callHScript('noteHit', [event]);
			if (note.strum.cpu) callHScript('cpuNoteHit', [event]);
			else callHScript('playerNoteHit', [event]);

			if (!event.cancelled) {
				if (!note.missed && !note.hit && note.spawned) {
					if (note.canBeHit) {						
						note.hit = true;
						note.strum.playAnim('confirm', true);

						if (note.character != null)
							note.character.playAnim(singAnims[note.noteData] + note.animSuffix, true);

						hud.onNoteDestroyed.dispatch(note);
						hud.disposeNote(note);

						if (!note.cpu) {
							health += note.hitHealth ?? 0.023;
							if (!note.isSustainNote) {
								songScore += rating.score;
								rating.hits++;
							}

							totalPlayed++;
							totalNotesHit += rating.factor;

							var ratingPop = Popup.recycle(300, 0, PrecacheUtil.image('gameplay/${ratingName}'));
							ratingPop.scale.set(0.6, 0.6);
							ratingPop.updateHitbox();
							ratingPop.pop();
							add(ratingPop);
						}

						return;
					}
				}
			}
			note.rating = '';
		} else noteMiss(note);
	}

	/**
     * Misses the specified note.
	 * Meant to be called internally.
	 * @param note The note to miss.
	 */
	public function noteMiss(note:Note) {
		var event = new NoteEvent(note);
		callHScript('noteMiss', [event]);
		if (note.strum.cpu) callHScript('cpuNoteMiss', [event]); // amusia is that you?
		else callHScript('playerNoteMiss', [event]);

		if (!event.cancelled) {
			if (!note.missed && !note.hit && note.spawned) {
				note.missed = true;
				if (note.character != null)
					note.character.playAnim('${singAnims[note.noteData]}miss' + note.animSuffix, true);

				FlxTween.tween(note, { 
					multAlpha: 0,
					multSpeed: 0.75,
					'colorTransform.redOffset': 255,
					'colorTransform.blueOffset': 255,
					'colorTransform.greenOffset': 255
				}, 0.2, { ease: FlxEase.cubeIn });

				if (!note.cpu) {
					health -= note.missHealth ?? 0.043;
				
					if (!note.isSustainNote) {
						songScore -= 10;
						songMisses++;
						totalPlayed++;
					}
				}
			}
		}
	}

	/*
	 * #########################
	 * ##   BACKEND HELPERS   ##
	 * #########################
	 */

    /**
     * Syncs the music time for both instrumental and voices to the Conductor's song position.
     */
    public function sync() {
		inst.time = Conductor.songPosition - Conductor.offset;
		voices.sync();
	}

	/**
	 * Starts the song.
	 */
	public function startSong() {
		inst.play();
		voices.play();

		Conductor.trackedMusic = inst;

		songStarted = true;
	}

	/**
	 * Ends the song.
	 */
    public function endSong() {
		songEnded = true;
		PrecacheUtil.clear();
	}

    /**
     * Loads the song data, meant to be called before PlayState's creation.
     * @param songName The song to load.
     * @param difficulty The target difficulty of the song, defaults to the song's first difficulty.
     */
    public static function loadSong(songName:String, ?difficulty:String) {
		difficulty ??= getDifficulties(songName)[0];
		if (Paths.chart(songName, difficulty) != null)
		{
			song = new SongData(songName, difficulty);
			Conductor.bpm = song.bpm;
		}
	}

	/**
	 * Fetches the list of a song's difficulties
	 * @param songName The song to fetch the difficulty list of. Defaults to the current song.
	 * @return an Array of difficulty names.
	 */
	public static function getDifficulties(?songName:String):Array<String> {
		var diffs:Array<String> = [];
		songName ??= song?.songName ?? '';
		if (Paths.exists(Paths.song('$songName/charts', true), true))
		{
			for (diff in FileSystem.readDirectory(Paths.song('$songName/charts', true)))
			{
				if (diff.endsWith('.json'))
				{
					diff = diff.replace('.json', '');
					diffs.push(diff);
				}
			}
		}
		return diffs;
	}

	/**
	 * Fetches the middle difficulty of a song.
	 * @param songName The song to fetch the median difficulty of. Defaults to the current song.
	 * @return The difficulty name.
	 */
	public static function getMedianDifficulty(?songName:String):String {
		songName ??= song?.songName ?? '';
		var difficulties = getDifficulties(songName);
		if (difficulties.length > 0)
			return difficulties[int(difficulties.length / 2)];

		return null;
	}

	/**
	 * Fetches the Character object from the specified ID.
	 * @param id The ID number of the target Character.
	 * @return The Character object, can be null.
	 */
	public function characterFromID(id:Int):Null<Character> {
		for (char in characters) {
			if (char == null) continue;
			if (char.characterID == id)
				return char;
		}
		return null;
	}

	/**
	 * Fetches the ID of the first Character found associated with the specified name.
	 * @param name The name of the target Character.
	 * @return The character's ID. `-1` is returned instead if the character isn't found.
	 */
	public function characterIDFromName(name:String):Int {
		for (char in characters) {
			if (char == null) continue;
			if (char.name == name)
				return char.characterID;
		}
		return -1;
	}

	/**
	 * Fetches the first Character object found associated with the specified name.
	 * @param name The name of the target Character.
	 * @return The Character object, can be null.
	 */
	public function characterFromName(name:String):Null<Character> {
		for (char in characters) {
			if (char == null) continue;
			if (char.name == name)
				return char;
		}
		return null;
	}

	public function getRank(?accuracy:Float):String {
		accuracy = FlxMath.bound(accuracy ?? songAccuracy, 0, 1);
		if (totalPlayed != 0) {
			if (accuracy >= 1)
				return 'X';

			var bestRank = 'N/A';
			var bestThreshold:Float = 0;
			for (rank => data in rankList) {
				var threshold:Float = data[0];

				if (rank == 'X') continue;
				if (accuracy >= threshold && threshold >= bestThreshold) {
					bestThreshold = threshold;
					bestRank = rank;
				}
			}
			return bestRank;
		}
		return 'N/A';
	}

	/*
	 * #####################
	 * ##   BEAT EVENTS   ##
	 * #####################
	 */

	override function stepHit(curStep:Int) {
		super.stepHit(curStep);

		call('stepHit', [curStep]);
		set('curStep', curStep);
		callBeatListeners(l -> l.stepHit(curStep));

		if (curStep == 0)
			voices.sync(); // apparently syncs up the vocals on song start?

		if (curStep % __camZoomInterval == 0)
		{
			camGame.zoom += gameBeatZoom;
			camHUD.zoom += hudBeatZoom;
		}
	}

	override function beatHit(curBeat:Int)
	{
		super.beatHit(curBeat);

		call('beatHit', [curBeat]);
		set('curBeat', curBeat);
		callBeatListeners(l -> l.beatHit(curBeat));
	}

	override function measureHit(curMeasure:Int)
	{
		super.measureHit(curMeasure);

		call('measureHit', [curMeasure]);
		set('curMeasure', curMeasure);
		callBeatListeners(l -> l.measureHit(curMeasure));
	}

    /**
     * Calls the corresponding beat function on the game's beat listeners.
     * Meant to be called internally.
     * @param f 
     */
    function callBeatListeners(f:Dynamic->Void) {
		for (character in characters)
			try {
				if (character != null)
					f(character);
			}
			catch (e:Dynamic)
				trace(e.toString());

		f(stage);
		f(hud);
	}

	/*
	 * ###################
	 * ##   SCRIPTING   ##
	 * ###################
	 */

    override function call(f:String, ?args:Array<Dynamic>) {
		super.call(f, args);
		stage.call(f, args);
	}

	/*
	 * #################
	 * ##   CLEANUP   ##
	 * #################
	 */

	override function destroy() {
		for (m in members) if (m != null) {
			FlxTween.cancelTweensOf(m);
			FlxDestroyUtil.destroy(m);
		}

		FlxG.cameras.reset();
		FlxG.camera.setFilters([]);

		FlxG.animationTimeScale = 1;
		
		inst.stop();
		voices.stop();

		call('destroy'); 
		for (script in hscripts) script.destroy();
		hscripts = null;

		for (character in characters) character.destroy();
		characters = null;

		hud.notes.destroy();
		hud.unspawnNotes = null;

		hud.destroy();
		stage.destroy();
		
		Popup.clear();
		PrecacheUtil.clear();

		instance = null;

		super.destroy();
	}
}