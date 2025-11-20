package funkin.backend.system;

import funkin.backend.system.Mods;

@:publicFields class Paths {
	public static var DEBUG_MODE:Bool = true;

	inline static function image(key:String, ?showError:Bool):String
		return getPath('images/$key.${Flags.IMAGE_EXT}', null, null, null, showError);

	inline static function xml(key:String):String
		return getPath('$key.xml');

	inline static function json(key:String, ?library:String = 'data') {
		if (!library.endsWith('/')) library += '/';
		return getPath('$library$key.json');
	}

	inline static function sparrow(key:String):String
		return xml('images/$key');

	inline static function sparrowExists(key:String):Bool
		return sparrow(key) != null;

	inline static function sound(key:String):String
		return getPath('sounds/$key.${Flags.SOUND_EXT}');

	inline static function music(key:String):String
		return getPath('music/$key.${Flags.MUSIC_EXT}');

	inline static function inst(key:String, ?postfix:String = '', ?showError:Bool):String {
		final prePath:String = song(key);
		if (prePath != null)
			return getPath('$prePath/song/Inst$postfix.${Flags.MUSIC_EXT}', null, null, null, showError);

		return null;
	}

	inline static function voices(key:String, ?postfix:String = '', ?showError:Bool):String {
		final prePath:String = song(key);
		if (prePath != null)
			return getPath('$prePath/song/Voices$postfix.${Flags.MUSIC_EXT}', null, null, null, showError);

		return null;
	}

	inline static function chart(key:String, ?difficulty:String = 'normal')
		return getPath('songs/$key/charts/$difficulty', false, Flags.CHART_EXT);

	inline static function character(key:String):String
		return getPath('data/characters/$key', false, Flags.CHAR_EXT);

	inline static function stage(key:String):String
		return json(key, 'data/stages');

	inline static function exists(key:String, ?absolute:Bool = false, 
		?ignoreMods:Bool, ?extensions:Array<String>, ?showError:Bool = false):Bool {

		if (key == null) return false;
		return getPath(key, ignoreMods, extensions, absolute ? [''] : null, showError) != null;
	}

	// For scripts
	#if HSCRIPT_ALLOWED
	static function hscript(key:String, ?library:String = "scripts"):String {
		if (!library.endsWith('/')) library += '/';
		return getPath('$library$key', false, Flags.HSCRIPT_EXT);
	}
	#end
	#if LUA_ALLOWED
	static function lua(key:String, ?library:String = "scripts"):String {
		if (!library.endsWith('/')) library += '/';
		return getPath('$library$key', false, Flags.LUA_EXT);
	}
	#end

	static function song(key:String, ?returnAbsolute:Bool = false):String {
		var curPath:String = 'songs/$key'; 
		var path:String = null;

		if (Paths.exists(curPath))
			path = curPath;
		else if (Paths.exists(curPath = 'songs/${key.toLowerCase()}'))
			path = curPath;
		else if (Paths.exists(curPath = 'songs/${key.replace(' ', '-')}'))
			path = curPath;

		return returnAbsolute ? getPath(path) : path;
	}

	static function getPath(path:String, ?ignoreMods:Bool = false, ?extensions:Array<String>, ?includeDir:Array<String>, ?showError:Bool):Null<String> {
		showError ??= DEBUG_MODE;
		if (path != null) {
			if (extensions != null)
				for (i => ext in extensions) {
					if (!ext.startsWith('.'))
						extensions[i] = '.$ext';
				}

			extensions ??= [''];
			if (includeDir == null) {
				includeDir ??= [ // sort in order of hierarchy
					#if MODS_ALLOWED Mods.getCurrentDirectory(), #end 
					'assets'
				];
				if (#if MODS_ALLOWED ignoreMods #else true #end) includeDir.shift();
			} else if (includeDir.length == 0)
				includeDir = [''];

			// Me when haxe.io.Path.normalize -TBar
			while (path.startsWith('../')) {
				for (i => dir in includeDir) {
					var ret = dir.split('/');
					if (ret.length > 1) {
						ret.shift(); 
						includeDir[i] = ret.join('/');
					} else
						includeDir[i] = ''; // root
				}
				var splPath = path.split('/');
				splPath.shift();
				path = splPath.join('/'); 
			}

			for (i => dir in includeDir) {
				if (dir != '')
					dir += '/';
				for (j => ext in extensions) {
					final trackedPath = '$dir$path$ext';
					// uncomment for a more detailed debug
					// trace('[$i:$j] trackedPath: ${trackedPath} | [$dir | $path | ${ext == '' ? 'no-ext' : ext}] (${FileUtil.exists(trackedPath) ? 'success' : 'failed'})');
					if (FileUtil.exists(trackedPath)) {
						if (showError)
							trace('Path found!: $trackedPath');
						return trackedPath;
					}
				}
			}

			if (showError)
				trace('Path not found for: $path');

			return null;
		}
		return null;
	}
}