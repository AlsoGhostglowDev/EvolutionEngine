package funkin.backend;

import funkin.backend.scripting.HScript;

class ScriptableState extends MusicBeatState implements IScriptable {
	public var hscripts:Array<HScript> = [];
	// public var luas:Array<> = []; // to be implemented

	public function call(f:String, ?args:Array<Dynamic>) {
		callHScript(f, args ?? []);
		callLuas(f, args ?? []);
	}

    public function set(p:String, v:Dynamic):Void {
		setHScript(p, v);
		setLuas(p, v);
    }

	#if LUA_ALLOWED
	public function callLuas(property:String, ?args:Array<Dynamic>):Void {}
	public function setLuas(field:String, value:Dynamic):Void {}
	#end

	#if HSCRIPT_ALLOWED
	public function callHScript(property:String, ?args:Array<Dynamic>):Void {
		for (hscript in hscripts)
			hscript.call(property, args ?? []); 
	}

	public function setHScript(field:String, value:Dynamic):Void {
		for (hscript in hscripts)
			hscript.set(field, value);
	}
	#end
}