package funkin.backend.system;

#if MODS_ALLOWED
class Mods {
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
}
#end