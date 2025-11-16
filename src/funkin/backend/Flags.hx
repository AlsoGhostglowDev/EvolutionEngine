package funkin.backend;

@:publicFields class Flags {
    static var IMAGE_EXT:String = 'png';
	static var SOUND_EXT:String = #if web 'mp3' #else 'ogg' #end;
	static var MUSIC_EXT:String = #if web 'mp3' #else 'ogg' #end;
	static var VIDEO_EXT:String = 'mp4';
	static var CHAR_EXT:Array<String> = ['json', 'xml'];
	static var CHART_EXT:Array<String> = ['json', 'fnfc'];
	static var LUA_EXT:Array<String> = ['lua'];
	static var HSCRIPT_EXT:Array<String> = ['hx', 'hscript', 'hxscript', 'hxc'];

	static var MODS_FOLDER:String = "mods";
	// static var MULTIPLE_MODS_ALLOWED:Bool = true;
}