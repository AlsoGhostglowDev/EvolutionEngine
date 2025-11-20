package funkin.backend.scripting.events.game;

import funkin.game.Character;
import funkin.game.Note;
import funkin.game.Strum;

class NoteHitEvent extends CancellableEvent
{
	public var note:Note;

	public var strumTime:Float;
	public var noteData:Int;
	public var character:Character;
	public var characterID:Int;
	public var noteType:String;
	public var strum:Strum;
	public var cpu:Bool;

	public function new(note:Note)
	{
		super();

		this.note = note;
		strumTime = note.strumTime;
		noteData = note.noteData;
		character = note.character;
		characterID = note.characterID;
		noteType = note.noteType;
		strum = note.strum;
		cpu = strum.cpu;
	}
}
