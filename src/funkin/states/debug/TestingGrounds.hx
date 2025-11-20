package funkin.states.debug;

import flixel.input.keyboard.FlxKey;
import funkin.game.Character;
import funkin.objects.LogoBumpin;
import funkin.game.system.SongData;

class TestingGrounds extends DebugState
{
	var logoBumpin:LogoBumpin;

	var dad:Character;
	var bf:Character;

	var songData:SongData;

	var characters:Array<Character> = [];

	public function new()
	{
		super();

		logoBumpin = new LogoBumpin(0, 0, 'logoBumpin');
		logoBumpin.screenCenter();
		add(logoBumpin);

		dad = new Character(-100, -100, 'night', false);
		characters.push(dad);
		add(dad);

		bf = new Character(700, 300, 'bf', true);
		characters.push(bf);
		add(bf);

		loadSong('say-my-name', 'hard');
		loadNotes(songData.chart);
	}

	function loadSong(songName:String, ?difficulty:String = 'normal')
	{
		if (Paths.chart(songName, difficulty) != null)
		{
			FlxG.sound.playMusic(loadSound(Paths.inst(songName)));
			if (Paths.exists(Paths.voices(songName), false))
			{
				var voices = new FlxSound();
				voices.loadEmbedded(loadSound(Paths.voices(songName)));
				voices.play();
			}

			songData = new SongData(songName, difficulty);

			Conductor.trackedMusic = FlxG.sound.music;
			Conductor.bpm = songData.bpm;
		}
	}

	override function beatHit(curBeat:Int)
	{
		super.beatHit(curBeat);

		if (curBeat % 2 == 0)
		{
			logoBumpin.bump();

			dad.beatHit(curBeat);
			bf.beatHit(curBeat);
			// dad.dance();
			// bf.dance();
		}
	}

	var strums:Array<Strum> = [];
	var strumPos:Array<Array<Float>> = [];
	var notes:Array<Note> = [];

	function loadNotes(data:Song)
	{
		for (i in 0...8)
		{
			var strum = new Strum(112 * i, 50);
			strum.makeGraphic(112, 112, 0xFFFFFFFF);
			strum.color = 0xFF858585;
			if (i > 3)
				strum.x += FlxG.width / 4;
			else
				strum.cpu = true;
			strums.push(strum);
			strumPos.push([strum.x, strum.y]);
			add(strum);
		}

		for (note in data.notes)
		{
			var leNote = new Note(112 * note.noteData, 0);
			leNote.makeGraphic(112, 112, 0xFFFF0000);
			leNote.strum = strums[note.noteData + (4 * note.character)];

			leNote.strumTime = note.strumTime;
			leNote.noteData = note.noteData;
			leNote.character = note.character;
			notes.push(leNote);
			add(leNote);
		}
	}

	function positionNotes(strumTime:Float)
	{
		for (note in notes)
		{
			note.angle = note.strum.angle;
			note.x = note.strum.x;
			note.y = (100000 * ((note.strumTime - Conductor.songPosition) / FlxG.sound.music.length)) + note.strum.y;
		}
	}

	var keys:Array<FlxKey> = [A, S, UP, RIGHT];

	function keyJustPressed(key:Int)
	{
		final key = cast(key, FlxKey);
		final noteData = keys.indexOf(key);

		FlxTween.cancelTweensOf(strums[noteData + 4]);
		FlxTween.color(strums[noteData + 4], 0.8, 0xFFFFFFFF, 0xFF858585, {ease: FlxEase.expoOut});

		for (note in notes)
		{
			if (note.noteData == noteData && !note.hit && Math.abs(note.strum.y - note.y) <= 120 && !note.strum.cpu)
			{
				note.kill();

				final singAnim = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
				characters[note.character].playAnim(singAnim[note.noteData], true);

				FlxTween.cancelTweensOf(note.strum);
				FlxTween.color(note.strum, 0.8, 0xFF00FF00, 0xFF858585, {ease: FlxEase.expoOut});
				break;
			}
		}
	}

	override function update(elapsed:Float)
	{
		positionNotes(Conductor.songPosition);

		for (i in 4...8)
		{
			final strum = strums[i];
			final pos = strumPos[i];
			strum.setPosition(pos[0] + Math.sin(FlxG.game.ticks / 400 + i / 2) * 25, pos[1] + Math.cos(FlxG.game.ticks / 400 + i / 2) * 25);
			strum.angle = Math.cos(FlxG.game.ticks / 400 + i / 2) * 2;
		}

		for (note in notes)
		{
			if (!note.hit && note.strum.cpu)
			{
				if (Conductor.songPosition >= note.strumTime)
				{
					FlxTween.cancelTweensOf(note.strum);
					FlxTween.color(note.strum, 0.8, 0xFFFFFFFF, 0xFF858585, {ease: FlxEase.expoOut});

					note.kill();
					note.hit = true;

					final singAnim = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
					characters[note.character].playAnim(singAnim[note.noteData], true);
				}
			}
		}

		if (FlxG.keys.justPressed.R)
		{
			for (note in notes)
			{
				note.hit = false;
				note.revive();
			}
			FlxG.sound.music.time = 0;

			dad.dance(true);
			bf.dance(true);
		}

		if (FlxG.keys.anyJustPressed(keys))
			keyJustPressed(FlxG.keys.firstJustPressed());

		super.update(elapsed);
	}
}

class Note extends FlxSprite
{
	public var spawned:Bool = false;
	public var strumTime:Float = 0;
	public var noteData:Int = 0;
	public var character:Int = 0;
	public var strum:Strum;
	public var hit:Bool = false;
}

class Strum extends FlxSprite
{
	public var cpu:Bool = false;
}
