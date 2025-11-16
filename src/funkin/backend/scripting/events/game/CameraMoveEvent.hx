package funkin.backend.scripting.events.game;

import flixel.math.FlxPoint;

import funkin.game.objects.Character;
import funkin.game.objects.hud.Strumline;

class CameraMoveEvent extends CancellableEvent {
    public var character:Character;
    public var characterID:Int;
    public var strumLine:Strumline;
    public var position:FlxPoint;

    public function new(strumLine:Strumline, position:FlxPoint) {
        super();

        this.strumLine = strumLine;
        this.position = position;
        character = strumLine.character;
        characterID = character.characterID;
    }
}