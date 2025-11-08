package funkin.backend.system;

import funkin.backend.Flags;

@:publicFields class Paths {
    inline static function image(key:String):String
        return 'assets/images/$key.${Flags.IMAGE_EXT}';
}