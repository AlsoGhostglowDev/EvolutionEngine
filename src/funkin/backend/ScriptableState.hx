package funkin.backend;

#if HSCRIPT_ALLOWED
import funkin.backend.scripting.HScript;
#end

#if sys
import sys.FileSystem;
#end

typedef HScriptArray = Array<#if HSCRIPT_ALLOWED HScript #else Dynamic #end>;

class ScriptableState extends MusicBeatState implements IScriptable {
	public var hscripts:HScriptArray = [];
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

	public function addHScript(path:String) {
		var hscript = new HScript(path);
		hscripts.push(hscript);
	}

	public function addScriptsFromDirectory(path:String) {
		if (Paths.exists(path))
			path = Paths.getPath(path);

		if (FileSystem.isDirectory(path)) {
			for (file in FileSystem.readDirectory(path)) {
				var haxeFile = endsWithAny(file, Flags.HSCRIPT_EXT);
				if (haxeFile || endsWithAny(file, Flags.LUA_EXT)) {
					if (haxeFile)
						hscripts.push(new HScript(file));
					// else
					//	 luas.push(new LuaScript(file));
				}
			}
		}
		trace('error: addScriptsFromDirectory: Path given isn\'t directed to a directory');
	}
}