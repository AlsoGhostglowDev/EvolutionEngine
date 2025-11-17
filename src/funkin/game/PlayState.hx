package funkin.game;

import funkin.game.*;
import funkin.game.objects.*;
import funkin.game.system.*;
#if sys
import sys.FileSystem;
#end

@:access(funkin.game.SongData)
@:access(funkin.game.Stage)
@:access(funkin.game.objects.HUD)
@:access(funkin.game.objects.Character)
class PlayState extends ScriptableState {
	public var characters:Array<Character> = [];
	public var stage:Stage;

	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;
	public var hud:HUD;

	public var inst:FlxSound;
	public var voices:VoicesHandler;

	public var songName(get, never):String;
	public var songPath(get, never):String;
	public var syncThreshold:Float = 500;

	function get_songName()
		return song.songName;

	function get_songPath()
		return song.songPath;

	public static var song(default, set):SongData;
	public static var isPixelStage(default, set):Bool = false;

	static function set_song(data:SongData) {
		if (data.chart == null)
			return song = null;

		return song = data;
	}

	// wip
	static function set_isPixelStage(value:Bool)
		return isPixelStage = value;

	public function new()
		super();

	override function create() {
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		camGame = FlxG.camera;

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD, false);

		hud = new HUD();
		hud.camera = camHUD;

		call('create', []);

		loadSong('say-my-name', getMedianDifficulty('say-my-name'));

		stage = new Stage();

		for (i => char in song?.characters ?? []) {
			var character = new Character(stage.characterPos[i]?.x ?? 0, stage.characterPos[i]?.y ?? 0, char.name, char.isPlayer);
			characters.push(character);
			character.fetchID();
			add(character);
		}

		inst = FlxG.sound.play(loadSound(Paths.inst(songPath)), 0.8, false);
		if (Paths.exists(Paths.voices(songPath), false))
			voices = new VoicesHandler(inst, songPath);

		for (character in characters)
			if (Paths.exists(Paths.voices(songPath, '-${character.name}'), false))
				voices.addVoices('-${character.name}');

		for (postfix in ['-Player', '-Opponent', '-player', '-opponent'])
			if (Paths.exists(Paths.voices(songPath, postfix), false))
				voices.addVoices(postfix);

		super.create();

		startSong();
	}

	override function update(elapsed:Float) {
		call('update', [elapsed]);

		if (FlxG.sound.music != null)
		{
			if (Math.abs(inst.time - (Conductor.songPosition + Conductor.offset)) > syncThreshold)
				sync();
		}

		super.update(elapsed);
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
		for (diff in FileSystem.readDirectory(Paths.song('$songName/charts', true)))
		{
			if (diff.endsWith('.json'))
			{
				diff = diff.replace('.json', '');
				diffs.push(diff);
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

	override function beatHit(curBeat:Int) {
		super.beatHit(curBeat);
		call('beatHit', [curBeat]);
		callBeatListeners(l -> l.beatHit(curBeat));
	}

	function callBeatListeners(f:Dynamic->Void) {
		for (character in characters)
			f(character);

		f(stage);
		f(hud);
	}
}
