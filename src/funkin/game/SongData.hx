package funkin.game;

import tjson.TJSON;
import funkin.backend.system.Parser;

typedef Player = {
    name:String,
    isPlayer:Bool,
    ?isSpeaker:Bool
}

typedef ChartNote = {
    strumTime:Float,
    noteData:Int,
    sustainLength:Float,
    character:Int,
    ?noteType:String
}

typedef Song = {
    characters:Array<Player>,
	song:String,
	hasVoices:Bool,
	stage:String,
	bpm:Float,
	scrollSpeed:Float,
	notes:Array<ChartNote>,
    postfix:String // for unique Inst/Voices for each difficulties
}

typedef PsychSection = {
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

typedef PsychSong = {
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

class SongData {
    public var chartData:Song;

    public var songName:String;
    public var songPath:String;
    public var stage:String;
    public var characters:Array<Player>;
    public var bpm:Float;

    public function new(songPath:String, ?difficulty:String = 'normal') {
		final sourceData = Paths.chart(songPath, difficulty);
		final chartEngine = justifyEngine(sourceData);

        #if !web
        trace([sourceData, chartEngine]);
        #end
		var chartData = Parser.chart(FileUtil.getContent(sourceData), chartEngine);

        //if (chartEngine != EVOLUTION)
		//	Parser.saveJson('songs/$songPath/charts/$difficulty', chartData);

        this.songPath = songPath;
        songName = chartData.song;
        stage = chartData.stage;
        characters = chartData.characters;
        bpm = chartData.bpm;

        this.chartData = chartData;
    }

    public static function justifyEngine(path:String):ChartEngineType {
        if (path != null) {
            if (path.endsWith('.fnfc'))
                return VSLICE;

			var json = TJSON.parse(FileUtil.getContent(path));
			if (Reflect.hasField(json, 'songPath'))
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