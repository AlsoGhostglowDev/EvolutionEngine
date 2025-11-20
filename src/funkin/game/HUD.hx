package funkin.game;

import funkin.game.hud.Strumline;
import funkin.game.hud.NoteGroup;
import funkin.game.system.SongData;
import funkin.game.system.SongData.Song;

class HUD extends FlxSpriteGroup implements IBeatListener {
	public var strumlines:Array<Strumline> = [];
	public var strums:Array<Strum> = [];
	public var notes:NoteGroup;
	public var game:PlayState;

	public function new(game:PlayState) {
		super();

		this.game = game;
		notes = new NoteGroup();
	}

	public function loadStrums() {
		var characters = game.characters;
		characters.reverse();

		for (char in characters) {
			var strumline = new Strumline(0, 50, 4, char.characterID, !char.isPlayer, null, PlayState.isPixelStage);
			strumline.visible = !char.hideStrumline;
			add(strumline);
			strumlines.push(strumline);

			for (strum in strumline) strums.push(strum);

			strumline.x = ((FlxG.width / 2) - strumline.width) / 2;
			if (char.isPlayer)
				strumline.x += FlxG.width/2;
		}
	}

	public function loadNotes() {
		final song = PlayState.song;
		for (i => note in song.chart.notes) {
			var leNote = new Note(note.noteData, false, note.character, null, PlayState.isPixelStage);
			leNote.strumTime = note.strumTime;
			leNote.spawned = true;
			leNote.strum = strumlines[note.character].members[note.noteData];
			strumlines[note.character].notes.push(leNote);
			notes.add(leNote);
			add(leNote);

			leNote.get_canBeHit = function() {
				return Math.abs(Conductor.songPosition - leNote.strumTime) <= 188;
			}
		}
	}

	public function updateNotes() {
		for (note in notes) {
			if (!note.hit && note.spawned) {
				note.y = FlxMath.lerp(note.strum.y, (59500 + note.strum.y) * game.scrollSpeed, (note.strumTime - Conductor.songPosition) / game.inst.length);
		
				if (Conductor.songPosition >= note.strumTime && note.strum.cpu && !note.ignoreNote)
					game.hitNote(note);
			}
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		updateNotes();
	}

	public function beatHit(curBeat:Int):Void {}
	public function stepHit(curStep:Int):Void {}
	public function measureHit(curMeasure:Int):Void {}
}
