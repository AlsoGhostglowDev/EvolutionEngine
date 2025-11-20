package funkin.game;

#if HSCRIPT_ALLOWED
import funkin.backend.scripting.HScript;
#end
import funkin.game.Stage.StageData;

import tjson.TJSON;

class ScriptableStage extends Stage implements IScriptable
{
	#if HSCRIPT_ALLOWED
	public var hscript:HScript;
	#else
	public var hscript:Dynamic;
	#end

	public function new(stage:String) {
		super(stage);

		#if HSCRIPT_ALLOWED
		hscript = new HScript(Paths.hscript(stage, 'data/stages'), {parent: MusicBeatState.getState(), ignoreErrors: false});
		#end
	}

	public function call(func:String, ?args:Array<Dynamic>)
	{
		#if HSCRIPT_ALLOWED
		if (hscript != null)
			hscript.call(func, args ?? []);
		#end
	}

	public function set(field:String, value:Dynamic)
	{
		#if HSCRIPT_ALLOWED
		if (hscript != null)
			hscript.set(field, value);
		#end
	}
}
