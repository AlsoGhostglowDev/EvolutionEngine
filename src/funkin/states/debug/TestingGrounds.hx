package funkin.states.debug;

import funkin.objects.LogoBumpin;
import funkin.game.objects.Character;

import funkin.game.SongData;

class TestingGrounds extends DebugState {
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
		loadNotes(songData.chartData);
	}

    function loadSong(songName:String, ?difficulty:String = 'normal') {
		if (Paths.chart(songName, difficulty) != null) {
        	FlxG.sound.playMusic(loadSound(Paths.inst(songName)));
        	if (Paths.exists(Paths.voices(songName), false)) {
        	    var voices = new FlxSound();
        	    voices.loadEmbedded(loadSound(Paths.voices(songName)));
        	    voices.play();
        	}

			songData = new SongData(songName, difficulty);

			Conductor.trackedMusic = FlxG.sound.music;
			Conductor.bpm = songData.bpm;
		}
    }

	override function beatHit(curBeat:Int) {
		super.beatHit(curBeat);

		if (curBeat % 2 == 0)
		{
			logoBumpin.bump();
			
			dad.dance();
			bf.dance();
		}
	}

	var strums:Array<FlxSprite> = [];
	var strumPos:Array<Array<Float>> = [];
	var notes:Array<Note> = [];
	function loadNotes(data:Song) {
		for (i in 0...8) {
			var strum = new FlxSprite(112 * i, 50);
			strum.makeGraphic(112, 112, 0xFFFFFFFF);
			strum.color = 0xFF858585;
			if (i > 3) strum.x += FlxG.width / 4;
			strums.push(strum);
			strumPos.push([strum.x, strum.y]);
			add(strum);
		}

		for (note in data.notes) {
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

	function positionNotes(strumTime:Float) {
		for (note in notes) {
			note.angle = note.strum.angle;
			note.x = note.strum.x;
			note.y = (100000 * ((note.strumTime - Conductor.songPosition) / FlxG.sound.music.length)) + note.strum.y;
		}
	}

	override function update(elapsed:Float) {
		positionNotes(Conductor.songPosition);

		for (i in 4...8) {
			final strum = strums[i];
			final pos = strumPos[i];
			strum.setPosition(pos[0] + Math.sin(FlxG.game.ticks/400 + i/2) * 25, pos[1] + Math.cos(FlxG.game.ticks/400 + i/2) * 25);
			strum.angle = Math.cos(FlxG.game.ticks/400 + i/2) * 2;
		}

		for (note in notes) {
			if (!note.hit) {
				if (Conductor.songPosition >= note.strumTime) {
					FlxTween.cancelTweensOf(note.strum);
					FlxTween.color(note.strum, 0.8, 0xFFFFFFFF, 0xFF858585, {ease: FlxEase.expoOut});

					note.kill();
					note.hit = true;

					final singAnim = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
					characters[note.character].playAnim(singAnim[note.noteData], true);
				}
			}
		}

		super.update(elapsed);
	}
}

class Note extends FlxSprite { 
	public var spawned:Bool = false; 
	public var strumTime:Float = 0;
	public var noteData:Int = 0;
	public var character:Int = 0;
	public var strum:FlxSprite;
	public var hit:Bool = false;
}