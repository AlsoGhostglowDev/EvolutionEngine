package funkin.backend;

#if HSCRIPT_ALLOWED
import funkin.backend.scripting.HScript;
#end

class ScriptableState extends MusicBeatState implements IScriptable {
	#if HSCRIPT_ALLOWED
	public var hscripts:Array<HScript> = [];
	#end
	// public var luas:Array<> = []; // to be implemented

	public function call(f:String, ?args:Array<Dynamic>) {
		callHScript(f, args ?? []);
		callLuas(f, args ?? []);
	}

    public function set(p:String, v:Dynamic):Void {
		setHScript(p, v);
		setLuas(p, v);
    }

	public function callLuas(property:String, ?args:Array<Dynamic>):Void {}
	public function setLuas(field:String, value:Dynamic):Void {}

	public function callHScript(property:String, ?args:Array<Dynamic>):Void {
		#if HSCRIPT_ALLOWED
		for (hscript in hscripts)
			hscript.call(property, args ?? []); 
		#end
	}

	public function setHScript(field:String, value:Dynamic):Void {
		#if HSCRIPT_ALLOWED
		for (hscript in hscripts)
			hscript.set(field, value);
		#end
	}
}