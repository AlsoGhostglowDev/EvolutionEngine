package funkin.game;

import funkin.game.*;
import funkin.game.system.*;
import funkin.game.system.SongData.Player;
#if sys
import sys.FileSystem;
#end

import funkin.backend.scripting.events.game.*;

enum BeatType
{
	STEP;
	BEAT;
	MEASURE;
}

@:access(funkin.game.system.SongData)
@:access(funkin.game.Stage)
@:access(funkin.game.objects.HUD)
@:access(funkin.game.objects.Character)
class PlayState extends ScriptableState
{
	public var characters:Array<Character> = [];
	public var stage:ScriptableStage;

	var __camZoomInterval(get, never):Int;
	public var camZoomInterval:Int = 1;
	public var camBeatEvery:BeatType = MEASURE;
	public var gameBeatZoom:Float = 0.028;
	public var hudBeatZoom:Float = 0.023;

	function get___camZoomInterval()
	{
		final mult = switch (camBeatEvery)
		{
			case MEASURE: 16;
			case BEAT: 4;
			case STEP: 1;
		}
		return camZoomInterval * mult;
	}

	public var camGame:FunkinCamera;
	public var camHUD:FunkinCamera;
	public var hud:HUD;

	public var inst:FlxSound;
	public var voices:VoicesHandler;

	public var songName(get, never):String;
	public var songPath(get, never):String;
	public var syncThreshold:Float = 500;
	
	public var scrollSpeed:Float = 1;

	function get_songName()
		return song?.songName ?? '';

	function get_songPath()
		return song?.songPath ?? '';

	public var singAnimations:Array<String> = [ 'singLEFT', 'singDOWN', 'singUP', 'singRIGHT' ];

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

	override function create() {
		loadSong('say-my-name', getMedianDifficulty('say-my-name'));

		if (songPath != null && Paths.exists('songs/$songPath/scripts'))
			addScriptsFromDirectory('songs/$songPath/scripts');

		set('game', this);

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		camGame = new FunkinCamera();
		FlxG.cameras.add(camGame);

		camHUD = new FunkinCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD, false);

		hud = new HUD(this);
		hud.camera = camHUD;
		add(hud);

		stage = new ScriptableStage(song.stage);
		add(stage);
		camGame.defaultCamZoom = stage?.defaultCamZoom ?? 0.9;

		scrollSpeed = (song?.scrollSpeed ?? 1) * GameplayModifiers.scrollMult;

		call('create');

		var sortedCharacter:Array<Player> = song?.characters ?? [];
		sortedCharacter.reverse(); // so the last added gets to the bottom
		for (j => char in sortedCharacter)
		{
			final i = sortedCharacter.length - 1 - j;
			var character = new Character(stage.characterPositions[i]?.x ?? 0, stage.characterPositions[i]?.y ?? 0, char.name, char.isPlayer);
			characters.push(character);
			character.hideStrumline = char.hideStrumline ?? false;
			character.characterID = i;
			add(character);
		}

		inst = FlxG.sound.play(loadSound(Paths.inst(songPath)), 0.8, false);
		if (Paths.exists(Paths.voices(songPath, null, false), false))
			voices = new VoicesHandler(inst, songPath);

		for (character in characters)
			if (Paths.exists(Paths.voices(songPath, '-${character.name}', false), false))
				voices.addVoices('-${character.name}');

		for (postfix in ['-Player', '-Opponent', '-player', '-opponent'])
			if (Paths.exists(Paths.voices(songPath, postfix, false), false))
				voices.addVoices(postfix);

		hud.loadStrums();
		hud.loadNotes();

		super.create();

		call('createPost');

		// remove in final builds
		startSong(); 
	}

	override function update(elapsed:Float) {
		call('update', [elapsed]);

		if (FlxG.sound.music != null)
		{
			if (Math.abs(inst.time - (Conductor.songPosition + Conductor.offset)) > syncThreshold)
				sync();
		}

		// this is obv wip, im js lazy rn
		for (key in ['A', 'S', 'UP', 'RIGHT']) {
			final pressed = Reflect.getProperty(FlxG.keys.pressed, key);
			final justPressed = Reflect.getProperty(FlxG.keys.justPressed, key);
			final justReleased = Reflect.getProperty(FlxG.keys.justReleased, key);

			if (pressed) keyPressed(key);
			if (justPressed) keyJustPressed(key);
			if (justReleased) keyJustReleased(key);
		}

		super.update(elapsed);

		call('updatePost', [elapsed]);
	}

	function keyPressed(key:String) {
		call('keyPressed', [key]);

		final index = (['A', 'S', 'UP', 'RIGHT']).indexOf(key);
		final strum = hud.strumlines[1].members[index];
		if (!strum.animation.name.contains('confirm')) {
			strum.allowStatic = false;
			strum.playAnim('press');
		}
	}

	function keyJustPressed(key:String) {
		call('keyJustPressed', [key]);

		final index = (['A', 'S', 'UP', 'RIGHT']).indexOf(key);
		for (note in hud.notes) {
			if (note.noteData == index && !note.strum.cpu) {
				if (note.canBeHit) {
					hitNote(note);
					break;
				}
			}
		}
	}

	function keyJustReleased(key:String) {
		call('keyJustReleased', [key]);

		final index = (['A', 'S', 'UP', 'RIGHT']).indexOf(key);
		final strum = hud.strumlines[1].members[index];
		strum.playStatic();
	}

	public function sync() {
		inst.time = Conductor.songPosition - Conductor.offset;
		voices.sync();
	}

	public function startSong() {
		inst.play();
		if (voices != null)
			voices.play();

		Conductor.trackedMusic = inst;
	}

	public static function loadSong(songName:String, ?difficulty:String) {
		difficulty ??= getDifficulties(songName)[0];
		if (Paths.chart(songName, difficulty) != null)
		{
			song = new SongData(songName, difficulty);
			Conductor.bpm = song.bpm;
		}
	}

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

	public static function getMedianDifficulty(?songName:String):String {
		songName ??= song?.songName ?? '';
		var difficulties = getDifficulties(songName);
		if (difficulties.length > 0)
			return difficulties[int(difficulties.length / 2)];

		return null;
	}

	public function characterFromID(id:Int)
		return characters[id];

	public function characterIDFromName(name:String):Int {
		for (i => char in characters) {
			if (char.name == name)
				return char.characterID;
		}
		return -1;
	}

	public function characterFromName(name:String) {
		for (char in characters) {
			if (char.name == name)
				return char;
		}
		return null;
	}

	public function hitNote(note:Note) {
		var event = new NoteHitEvent(note);
		callHScript('noteHit', [event]);
		if (note.strum.cpu) callHScript('cpuNoteHit', [event]);
		else callHScript('playerNoteHit', [event]);

		if (!event.cancelled) {
			if (!note.hit && note.spawned) {
				if (note.canBeHit) {
					note.hit = true;
					note.kill();
					note.strum.playAnim('confirm', true);

					if (note.character != null)
						note.character.playAnim(singAnimations[note.noteData] + note.animSuffix, true);
				}
			}
		}
	}

	override function stepHit(curStep:Int) {
		super.stepHit(curStep);

		call('stepHit', [curStep]);
		callBeatListeners(l -> l.stepHit(curStep));

		if (curStep % __camZoomInterval == 0)
		{
			camGame.zoom += gameBeatZoom;
			camHUD.zoom += hudBeatZoom;
		}
	}

	override function beatHit(curBeat:Int) {
		super.beatHit(curBeat);

		call('beatHit', [curBeat]);
		callBeatListeners(l -> l.beatHit(curBeat));
	}

	override function call(f:String, ?args:Array<Dynamic>) {
		super.call(f, args);
		stage.call(f, args);
	}

	function callBeatListeners(f:Dynamic->Void) {
		for (character in characters)
			f(character);

		f(stage);
		f(hud);
	}
}
