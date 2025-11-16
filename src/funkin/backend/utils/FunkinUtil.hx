package funkin.backend.utils;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxAssets.FlxGraphicAsset;
import openfl.media.Sound;
#if web
import openfl.utils.Assets as OpenFLAssets;
#end

@:publicFields class FunkinUtil {
    static inline function getLerpRatio(ratio:Float, ?elapsed:Float)
		return 1.0 - Math.pow(1.0 - ratio, (elapsed ?? FlxG.elapsed) * 60);

	static inline function loadSparrowAtlas(path:String) {
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

	static inline function loadSound(path:String) {
		#if web
		return OpenFLAssets.getSound(path);
		#else
		return Sound.fromFile(path);
		#end
	}

	static inline function fromRGBArray(rgb:Array<Int>)
		return FlxColor.fromRGB(rgb[0], rgb[1], rgb[2]);

	static function attemptAddAnimationByPrefix(sprite:FlxSprite, animName:String, prefix:String, frameRate:Int, looped:Bool) {
		var success:Bool;
		var test:Array<flixel.graphics.frames.FlxFrame> = [];

		@:privateAccess
		sprite.animation.findByPrefix(test, prefix);
		success = test.length > 0;
		
		if (success && sprite.frames != null)
			sprite.animation.addByPrefix(animName, prefix, frameRate, looped);

		return success;
	}

	static inline function first<T>(list:Array<T>, ?toFind:T):T {
		if (toFind != null)
			return list.filter(e -> e == toFind).shift();
		else
			return list[0];
	}

	static inline function last<T>(list:Array<T>, ?toFind:T):T {
		if (toFind != null)
			return list.filter(e -> e == toFind).pop();
		else
			return list[list.length-1];
	}


	static function sum(...tally:Float) {
		var result:Float = 0;
		for (i in tally) 
			result += i;

		return result;
	}

    static function average(...tally:Float)
		return sum(...tally) / tally.length;

	/* HScript stuff */

	@:noUsing static inline function resolveAbstract(abs:String):Null<Dynamic> {
		return Type.resolveClass('${abs}_HSC');
	}

	// Not normally used, but a fun tool to have
	@:noUsing static inline function resolveExtendClass(ext:String):Null<Dynamic> {
		return Type.resolveClass('${ext}_HSX');
	}
}