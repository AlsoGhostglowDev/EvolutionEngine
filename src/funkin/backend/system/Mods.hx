package funkin.backend.system;

class Mods {
	#if MODS_ALLOWED
    public static var currentMod:String = '';
    public static var currentModDirectory(get, never):String;

    static function get_currentModDirectory()
        return currentMod != '' ? '$currentMod/' : '';

    public static function getCurrentDirectory()
        return 'mods/${currentModDirectory.replace('/', '')}';

    public static function loadMod() {

    } 

    public static function getLoadedMods() {

    }

    public static function getActiveMods() {

    }
	#end
}