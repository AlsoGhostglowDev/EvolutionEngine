package funkin.game;

import funkin.game.objects.Character;
import funkin.game.objects.HUD;

import haxe.extern.EitherType;

import flixel.math.FlxPoint;

typedef StageSprite = {
    ?image:String,
    ?x:Float, ?y:Float,
    ?alpha:Float, ?visible:Bool
}

typedef StageCharacter = {
    ?x:Float, ?y:Float,
    ?cameraOffsets:Array<Float>
}

typedef StageData = {
    characters:Array<StageCharacter>,
    sprites:Array<StageSprite>,
}

class Stage extends FlxSpriteGroup implements IBeatListener {
    public var state:MusicBeatState;

    public var data:StageData;

    public var characters(get, never):Array<Character>;
	public var hud(get, never):HUD;

    public var songName(get, never):String;
	public var songPath(get, never):String;

    function get_characters()
		return getFromGame(s -> return s.characters);

    function get_hud()
		return getFromGame(s -> return s.hud);

    function get_songName()
		return getFromGame(s -> return s.songName);

    function get_songPath()
        return getFromGame(s -> return s.songPath);

    function getFromGame(?f:PlayState->Dynamic):Dynamic {
        if (state is PlayState)
            return f(cast(state, PlayState));
        else
            return null;
    }

    public var characterPos:Array<FlxPoint> = [];

    public function new(?stage:StageData) {
        super();
        state = MusicBeatState.getState();

        stage ??= {
            characters: [],
            sprites: []
        };
    }

    public function beatHit(curBeat:Int):Void {}
    public function stepHit(curStep:Int):Void {}
    public function measureHit(curMeasure:Int):Void {}
}