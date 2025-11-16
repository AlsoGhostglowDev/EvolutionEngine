package funkin.game.objects;

import funkin.game.objects.Character;

class Strum extends FlxSprite {
	public static var FALLBACK_TEXTURE:String = 'NOTE_assets';
    public static var directions:Array<String> = [ '' ];
    public var cpu:Bool;

    public var character(default, null):Character;
	public var characterID(default, null):Int;

    public var texture:String = '';

    public function new(x:Float = 0, y:Float = 0, noteData:Int = 0, ?texture:String) {
        super(x, y);
    }
}