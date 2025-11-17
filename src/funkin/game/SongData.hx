package funkin.game;

import funkin.backend.system.Parser;
import tjson.TJSON;

typedef Player =
{
	name:String,
	isPlayer:Bool,
	?isBopper:Bool
}

typedef ChartNote =
{
	strumTime:Float,
	noteData:Int,
	sustainLength:Float,
	character:Int,
	?noteType:String
}

typedef Song =
{
	characters:Array<Player>,
	song:String,
	hasVoices:Bool,
	stage:String,
	bpm:Float,
	scrollSpeed:Float,
	notes:Array<ChartNote>,
	keys:Int,
	postfix:String, // for unique Inst/Voices for each difficulties
	evoChart:Bool
}

typedef PsychSection =
{
	sectionBeats:Int,
	sectionNotes:Array<Array<Dynamic>>,
	/* [0] strumTime, (float)
	 * [1] noteData, (int)
	 * [2] sustainLength, (float)
	 * [3] noteType (string, optional)
	 */
	typeOfSection:Int, // unused
	gfSection:Bool,
	altAnim:Bool,
	mustHitSection:Bool,
	changeBPM:Bool,
	bpm:Float
}

typedef PsychSong =
{
	player1:String, // boyfriend
	player2:String, // dad
	gfVersion:String, // gf
	notes:Array<PsychSection>,
	splashSkin:String,
	song:String,
	needsVoices:Bool,
	arrowSkin:String,
	stage:String,
	validScore:Bool, // unused
	bpm:Float,
	speed:Float
}

class SongData
{
	public var chart:Song;

	public var songName:String;
	public var songPath:String;
	public var stage:String;
	public var characters:Array<Player>;
	public var bpm:Float;

	public function new(songPath:String, ?difficulty:String)
	{
		difficulty ??= PlayState.getDifficulties(songPath)[0];

		final sourceData = Paths.chart(songPath, difficulty);
		final chartEngine = justifyEngine(sourceData);

		#if !web
		trace([sourceData, chartEngine]);
		#end

		var chart:Song;
		if (sourceData != null)
		{
			chart = Parser.chart(FileUtil.getContent(sourceData), chartEngine);

			if (chartEngine != EVOLUTION)
				Parser.saveJson('songs/$songPath/charts/$difficulty', chart);

			this.songPath = songPath;
			songName = chart.song;
			stage = chart.stage;
			characters = chart.characters;
			bpm = chart.bpm;

			this.chart = chart;
		}
	}

	public static function justifyEngine(path:String):ChartEngineType
	{
		if (path != null)
		{
			if (path.endsWith('.fnfc'))
				return VSLICE;

			var json = TJSON.parse(FileUtil.getContent(path));
			if (Reflect.hasField(json, 'evoChart') && json.evoChart ?? false == true)
				return EVOLUTION;
			else if (Reflect.hasField(json, 'validScore'))
				return PSYCH;
			else if (Reflect.hasField(json, 'song') && !(json.song is String))
				if (Reflect.hasField(json.song, 'validScore'))
					return PSYCH_LEGACY;
				else
					return CODENAME;
		}
		return UNKNOWN;
	}
}
