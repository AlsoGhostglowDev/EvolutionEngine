package funkin.backend.utils;

import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.media.Sound;

@:publicFields class FunkinUtil {
    static function getLerpRatio(ratio:Float, ?elapsed:Float)
		return 1.0 - Math.pow(1.0 - ratio, (elapsed ?? FlxG.elapsed) * 60);

	static function loadSparrowAtlas(path:String) {
		var graphic = FlxGraphic.fromAssetKey(Paths.image(path));
		return FlxAtlasFrames.fromSparrow(graphic, Paths.sparrow(path));
	}

    /*
        Tries and load animated frames if there is an XML detected,
        else it'll fallback to a normal inanimated sprite.
    */
    static function tryLoadFrames(sprite:FlxSprite, path:String) {
        if (Paths.sparrowExists(path)) 
			sprite.frames = loadSparrowAtlas(path);
		else
			sprite.loadGraphic(Paths.image(path));
    }

	static function loadSound(path:String)
		return Sound.fromFile(path);

	static function fromRGBArray(rgb:Array<Int>)
		return FlxColor.fromRGB(rgb[0], rgb[1], rgb[2]);

	static function sum(...tally:Float) {
		var result:Float = 0;
		for (i in tally) 
			result += i;

		return result;
	}

    static function average(...tally:Float)
		return sum(...tally) / tally.length;
}