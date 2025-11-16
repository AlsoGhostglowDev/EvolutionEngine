package funkin.game.objects.hud;

@:access(funkin.game.objects.hud.Note)
class NoteGroup extends FlxTypedSpriteGroup<Note> {
    public function getFirstHittable(?noteData:Int) {
    
    } 

    public inline function getPlayerNotes()
        return members.filter( n -> return !n.cpu );

    public inline function getCPUNotes()
		return members.filter(n -> return n.cpu);
}