package funkin.backend.system;

import funkin.backend.system.Mods;

@:publicFields class Paths {
	inline static function image(key:String):String
		return getPath('images/$key.${Flags.IMAGE_EXT}');

	inline static function xml(key:String):String
		return getPath('$key.xml');

	inline static function sparrow(key:String):String
		return xml('images/$key');

	inline static function sparrowExists(key:String):Bool
		return sparrow(key) != null;

	inline static function sound(key:String):String
		return getPath('sounds/$key.${Flags.SOUND_EXT}');

	inline static function music(key:String):String
		return getPath('music/$key.${Flags.MUSIC_EXT}');

	inline static function inst(key:String, ?postfix:String = ''):String {
		final prePath:String = song(key);
		if (prePath != null)
			return getPath('$prePath/song/Inst$postfix.${Flags.MUSIC_EXT}');

		return null;
	}

	inline static function voices(key:String, ?postfix:String = ''):String {
		final prePath:String = song(key);
		if (prePath != null)
			return getPath('$prePath/song/Voices$postfix.${Flags.MUSIC_EXT}');

		return null;
	}

	inline static function chart(key:String, ?difficulty:String = 'normal')
		return getPath('songs/$key/charts/$difficulty', false, Flags.CHART_EXT);

	inline static function character(key:String):String
		return getPath('data/characters/$key', false, Flags.CHAR_EXT);

	inline static function exists(key:String, ?absolute:Bool = false, ?ignoreMods:Bool = #if MODS_ALLOWED false #else true #end):Bool {
		if (key == null) return false;
		return absolute ? FileUtil.exists(key) : (getPath(key, ignoreMods) != null);
	}

	// For scripts
	#if HSCRIPT_ALLOWED
	static function hscript(key:String, ?folder:String = "scripts"):String {
		return getPath('$folder/$key', false, Flags.HSCRIPT_EXT);
	}
	#end
	#if LUA_ALLOWED
	static function lua(key:String, ?folder:String = "scripts"):String {
		return getPath('$folder/$key', false, Flags.LUA_EXT);
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

	static function getPath(path:String, ?ignoreMods:Bool = false, ?extensions:Array<String>, ?includeDir:Array<String>):Null<String> {
		if (path != null) {
			if (extensions != null)
				for (i => ext in extensions) {
					if (!ext.startsWith('.'))
						extensions[i] = '.$ext';
				}

			extensions ??= [''];
			if (includeDir == null) {
				includeDir ??= [ // sort in order of hierarchy
					#if MODS_ALLOWED '${Flags.MODS_FOLDER}/${Mods.currentModDirectory}', #end 
					'assets/shared', 'assets'
				];
				if (#if MODS_ALLOWED ignoreMods #else true #end) includeDir.shift();
			}

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

			for (dir in includeDir) {
				for (ext in extensions) {
					final trackedPath = '$dir/$path$ext';
					if (FileUtil.exists(trackedPath)) {
						trace('Path found!: $trackedPath');
						return trackedPath;
					}
				}
			}
			trace('Path not found for: $path');
		}
		return null;
	}
}