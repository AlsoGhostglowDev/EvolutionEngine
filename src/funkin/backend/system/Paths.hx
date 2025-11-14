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

	inline static function character(key:String):String
		return getPath('data/characters/$key', false, Flags.CHAR_EXT);

	inline static function exists(key:String, ?ignoreMods:Bool = #if MODS_ALLOWED false #else true #end):Bool
		return getPath(key, ignoreMods) != null;

	static function getPath(path:String, ?ignoreMods:Bool = false, ?extensions:Array<String>, ?includeDir:Array<String>):Null<String> {
		if (extensions != null)
			for (i => ext in extensions) {
				if (!ext.startsWith('.'))
					extensions[i] = '.$ext';
			}
		
		extensions ??= [''];
		if (includeDir == null) {
			includeDir ??= [ // sort in order of hierarchy
				#if MODS_ALLOWED Mods.currentModDirectory ,#end 
				'assets/shared', 'assets'
			];
			if (#if MODS_ALLOWED ignoreMods #else true #end) includeDir.shift();
		}

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
		return null;
	}
}