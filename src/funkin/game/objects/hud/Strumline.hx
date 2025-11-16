package funkin.game.objects.hud;

import funkin.game.objects.Strum;

@:access(funkin.game.objects.Strum)
class Strumline extends FlxTypedSpriteGroup<Strum> {
	public var character(default, null):Character;
	public var characterID(default, null):Int;
    public var cpu(default, set):Bool;

    function set_cpu(value:Bool) {
        forEach(s -> s.cpu = value);
        return cpu = value;
    } 
}