package funkin.backend.system;

import sys.FileSystem;
import sys.io.File;

import funkin.backend.system.Mods;

@:publicFields class Paths {
    inline static function image(key:String):String
        return getPath('images/$key.${Flags.IMAGE_EXT}');

	inline static function xml(key:String):String
		return getPath('$key.xml');

    inline static function sparrow(key:String):String
        return xml('images/$key');

    inline static function sparrowExists(key:String):Bool
        return sparrow(key) != '';

    static function getPath(path:String, ?includeDir:Array<String>):String {
        includeDir ??= [ // sort in order of hierarchy
            #if MODS_ALLOWED Mods.currentModDirectory ,#end 
            'assets/shared', 'assets'
        ];

        for (dir in includeDir) {
			final trackedPath = '$dir/$path';
            if (FileSystem.exists(trackedPath)) {
                trace('Path found!: $trackedPath');
                return trackedPath;
            }
        }
        trace('Path not found for: $path.');
        return '';
    }
}