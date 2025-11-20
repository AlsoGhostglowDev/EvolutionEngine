package funkin.game;

import flixel.math.FlxPoint;
import funkin.game.Character;
import funkin.game.HUD;
import funkin.backend.system.Parser;
import funkin.backend.system.Parser.EngineType;

import tjson.TJSON;

typedef StageSprite = {
	?image:String,
	?x:Float,
	?y:Float,
	?alpha:Float,
	?visible:Bool
}

typedef StageCharacter = {
	?x:Float,
	?y:Float,
	?cameraOffsets:Array<Float>
}

typedef StageData = {
	characters:Array<StageCharacter>,
	?sprites:Array<StageSprite>,
	?defaultCamZoom:Float,
}

class Stage extends FlxSpriteGroup implements IBeatListener
{
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

	function getFromGame(?f:PlayState->Dynamic):Dynamic
	{
		if (state is PlayState)
			return f(cast(state, PlayState));
		else
			return null;
	}

	public var characterPositions:Array<FlxPoint> = [];
	public var cameraOffsets:Array<FlxPoint> = [];
	public var defaultCamZoom:Float = 0.9;

	public function new(?path:String)
	{
		super();
		state = MusicBeatState.getState();

		if (path != null) {
			final sourceData = Paths.stage(path);
			final stageEngine = justifyEngine(sourceData);
			trace([sourceData, stageEngine]);
			data = Parser.stage(FileUtil.getContent(sourceData), stageEngine);
		}

		data ??= {
			characters: [
				{x: -100, y: 0, cameraOffsets: [0, 0]},
				{x: 600, y: 200, cameraOffsets: [0, 0]},
				{x: 250, y: 150, cameraOffsets: [0, 0]}
			],
			sprites: [],
			defaultCamZoom: 0.9
		};

		for (char in data.characters)
		{
			final camOffsets = char.cameraOffsets;
			characterPositions.push(FlxPoint.get(char.x, char.y));
			cameraOffsets.push(FlxPoint.get(camOffsets[0], camOffsets[1]));
		}
		defaultCamZoom = data.defaultCamZoom;
	}

	public function justifyEngine(path:String):EngineType {
		if (path != null) {
			if (path.endsWith('.xml'))
				return CODENAME;
			final parsedJson = TJSON.parse(FileUtil.getContent(path));
			if (Reflect.hasField(parsedJson, 'evoStage'))
				return EVOLUTION;
		}
		return UNKNOWN;
	}

	public function beatHit(curBeat:Int):Void {}
	public function stepHit(curStep:Int):Void {}
	public function measureHit(curMeasure:Int):Void {}
}
