package funkin.backend.utils;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxAssets.FlxGraphicAsset;
import openfl.media.Sound;
#if web
import openfl.utils.Assets as OpenFLAssets;
#end

import lime.app.Promise;
import lime.app.Future;
#if sys
import sys.thread.Thread;
#end
#if hl
import hl.UI;
import haxe.EnumFlags;
#end

@:publicFields class FunkinUtil
{
	/*
	 * This is because hashlink has this weird issue with base window.alert that
	 * messes up the text.
	 */
	static inline function windowAlert(title:String, body:String) {
		#if !hl
		FlxG.stage.window.alert(body, title);
		#else
		UI.dialog(title, body, new EnumFlags<DialogFlags>());
		#end
	}

	static inline function getLerpRatio(ratio:Float, ?elapsed:Float)
		return 1.0 - Math.pow(1.0 - ratio, (elapsed ?? FlxG.elapsed) * 60);

	static inline function loadSparrowAtlas(path:String, ?showError:Bool)
		return FlxAtlasFrames.fromSparrow(PrecacheUtil.image(path), Paths.sparrow(path, showError));

	/*
		Tries and load animated frames if there is an XML detected,
		else it'll fallback to a normal inanimated sprite.
	 */
	static function tryLoadFrames(sprite:FlxSprite, path:String, ?showError:Bool) {
		if (Paths.sparrowExists(path))
			sprite.frames = loadSparrowAtlas(path, showError);
		else
			sprite.loadGraphic(PrecacheUtil.image(path));
	}

	static inline function loadSound(path:String, ?reload:Bool = false) {
		return PrecacheUtil.sound(path, reload);
	}

	static inline function fromRGBArray(rgb:Array<Int>)
		return FlxColor.fromRGB(rgb[0], rgb[1], rgb[2]);

	static inline function copyStruct<T>(struct:T):T {
		var ret:Dynamic = {};
		for (field in Reflect.fields(struct))
			Reflect.setField(ret, field, Reflect.field(struct, field));

		return cast ret;
	}

	static function attemptAddAnimationByPrefix(sprite:FlxSprite, animName:String, prefix:String, frameRate:Int, looped:Bool)
	{
		var success:Bool;
		var test:Array<flixel.graphics.frames.FlxFrame> = [];

		@:privateAccess
		sprite.animation.findByPrefix(test, prefix);
		success = test.length > 0;

		if (success && sprite.frames != null)
			sprite.animation.addByPrefix(animName, prefix, frameRate, looped);

		return success;
	}

	static function first<T>(list:Array<T>, ?toFind:T):T
	{
		if (toFind != null)
			return list.filter(e -> e == toFind).shift();
		else if (list.length > 0)
			return list[0];

		return null;
	}

	static function floorDecimal(value:Float, decimals:Int):Float
	{
		if (decimals < 1)
			return Math.floor(value);

		return Math.floor(value * Math.pow(10, decimals)) / Math.pow(10, decimals);
	}

	static function last<T>(list:Array<T>, ?toFind:T):T
	{
		if (toFind != null)
			return list.filter(e -> e == toFind).pop();
		else if (list.length > 0)
			return list[list.length - 1];

		return null;
	}

	static function async<T>(f:Void->T):Future<T> {
		#if sys
		var promise = new Promise<T>();
		Thread.create(() -> {
			final result = f();
			promise.complete(result); 
		});
		return promise.future;
		#else
		return f();
		#end
	}

	static function record(tag:String = '', newRec:Bool = false) {
		static var _prevRecord:Float = 0;
		if (newRec)
			_prevRecord = 0;

		final elapsed:Float = Sys.cpuTime();
		final diff:Float = newRec ? 0 : elapsed - _prevRecord;
		_prevRecord = elapsed;

		trace('[$tag] delta: $diff');

		return diff;
	}

	static function startsWithAny(str:String, starts:Array<String>)
	{
		for (start in starts)
		{
			if (str.startsWith(start))
				return true;
		}
		return false;
	}

	static function endsWithAny(str:String, ends:Array<String>)
	{
		for (end in ends)
		{
			if (str.endsWith(end))
				return true;
		}
		return false;
	}

	static function sum(...tally:Float)
	{
		var result:Float = 0;
		for (i in tally)
			result += i;

		return result;
	}

	static function average(...tally:Float)
		return sum(...tally) / tally.length;
}
