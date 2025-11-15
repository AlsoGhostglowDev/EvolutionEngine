package funkin.backend.system;

class Conductor {
    public static var songPosition(get, never):Float;
    public static var bpm(default, set):Float = 100;

    public static var curStep(get, never):Int;
	public static var curBeat(get, never):Int;
    public static var curMeasure(get, never):Int;

	public static var curDecStep(get, never):Float;
	public static var curDecBeat(get, never):Float;
	public static var curDecMeasure(get, never):Float;

	public static var crochet(get, never):Float;
	public static var stepCrochet(get, never):Float;

    public static var trackedMusic:FlxSound;
    public static var offset:Float = 0;

	static function get_songPosition()
        return trackedMusic?.time + offset ?? 0;

    static function get_curStep() return int(curDecStep);
    static function get_curBeat() return int(curDecBeat);
    static function get_curMeasure() return int(curDecMeasure);

    static function get_curDecStep() return songPosition / stepCrochet;
    static function get_curDecBeat() return songPosition / crochet;
    
    // temporary
	static function get_curDecMeasure() return curDecBeat / 4;

    static function get_crochet() return 60000 / bpm;
	static function get_stepCrochet() return crochet / 4;

	static function set_bpm(newBPM:Float) {
        // wip
        return bpm = newBPM; 
    }
}