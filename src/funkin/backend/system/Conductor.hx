package funkin.backend.system;

class Conductor {
    public var songPosition(get, never):Float;
    public var bpm(default, set):Int = 100;

    public var curStep(get, never):Int;
	public var curBeat(get, never):Int;
    public var curMeasure(get, never):Int;

	public var curDecStep(get, never):Float;
	public var curDecBeat(get, never):Float;
	public var curDecMeasure(get, never):Float;

	public var crochet(get, never):Float;
	public var stepCrochet(get, never):Float;

    public var trackedMusic:FlxSound;
    public var offset:Float = 0;

    function get_songPosition()
        return trackedMusic?.time + offset ?? 0;

    function get_curStep() return int(curDecStep);
    function get_curBeat() return int(curDecBeat);
    function get_curMeasure() return int(curDecMeasure);

    function get_curDecStep() return curDecBeat * 4;
    function get_curDecBeat() return songPosition / crochet;
    
    // temporary
	function get_curDecMeasure() return curDecBeat / 4;

    function get_crochet() return (bpm / 60) * 1000;
	function get_stepCrochet() return crochet / 4;

    function set_bpm(newBPM:Int) {
        // wip
        return bpm = newBPM; 
    }
}