package funkin.game.system;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;

class VoicesHandler implements IFlxDestroyable {
	public var inst:FlxSound;
	public var container:Array<FlxSound> = [];
	public var postfixes:Map<String, FlxSound> = [];

	public var playing(default, null):Bool = false;
	public var paused(default, null):Bool = false;
	public var muted(default, null):Bool = false;
	public var length(get, null):Float = 0;

	public var offset(default, set):Float = 0;
	public var volume(default, set):Float = 0;
	public var persist(default, set):Bool= false;
	public var looped(default, set):Bool = false;
	public var loopTime(default, set):Float = 0;

	public var time(get, never):Float;
	public var songPath:String;

	var __playing:Bool = false;
	var __volume:Float = 1;

	function get_time()
		return (inst?.time ?? 0) + offset;

	function get_length()
		return inst.length;

	function set_offset(value:Float) {
		offset = value;
		sync();
		return value;
	}

	function set_volume(value:Float) {
		__volume = value;
		if (!muted) {
			forEach(v -> v.volume = value);
			volume = value;
		}
		return value;
	}

	function set_persist(value:Bool) {
		forEach(v -> v.persist = value);
		return persist = value;
	}

	function set_looped(value:Bool) {
		forEach(v -> v.looped = value);
		return looped = value;
	}

	function set_loopTime(value:Float) {
		forEach(v -> v.loopTime = value);
		return loopTime = value;
	}

	public function new(trackedMusic:FlxSound, songName:String, ?postfix:String = '') {
		try {
			if (Paths.exists(Paths.song(songName), true))
				songPath = songName;
		} catch(e:Dynamic)
			trace('error: ${e.toString()}');

		inst = trackedMusic;
		addVoices(postfix);
	}

	public function addVoices(?postfix:String = '') {
		final path = Paths.voices('$songPath$postfix');
		if (Paths.exists(path, true) && !postfixes.exists(postfix)) {
			var voices = new FlxSound();
			voices.loadEmbedded(loadSound(path));
			voices.endTime = inst.endTime;
			postfixes.set(postfix, voices);

			if (playing)
				voices.play();
		}
	}

	public function play() {
		forEach(v -> v.play());

		playing = true;
		__playing = true;
	}

	public function mute() {
		forEach(v -> v.volume = 0);
		muted = true;
	}

	public function unmute() {
		forEach(v -> v.volume = __volume);
		muted = false;
	}

	public function muteByPostfix(?postfix:String = '') {
		var voices = find(postfix);
		if (voices != null)
			voices.volume = 0;
	}

	public function unmuteByPostfix(?postfix:String = '') {
		var voices = find(postfix);
		if (voices != null)
			voices.volume = __volume;
	}

	public function sync()
		forEach(v -> v.time = time);

	public function pause() {
		forEach(v -> v.pause());

		paused = true;
		playing = false;
	}

	public function resume() {
		forEach(v -> v.resume());

		paused = false;
		if (__playing)
			playing = true;
	}

	public function forEach(f:(FlxSound)->Void) {
		for (voices in container)
			f(voices);
	}

	public function forEachPostfix(f:(String, FlxSound)->Void) {
		for (postfix => voices in postfixes)
			f(postfix, voices);
	}

	public function filter(f:(String, FlxSound)->Bool):Array<FlxSound> {
		var filtered:Array<FlxSound> = [];
		forEachPostfix((p:String, v:FlxSound) -> {
			if (f(p, v))
				filtered.push(v);
		});
		return filtered;
	}

	public function filterPostfixes(f:(String, FlxSound)->Bool):Array<String> {
		var filtered:Array<String> = [];
		forEachPostfix((p:String, v:FlxSound) -> {
			if (f(p, v))
				filtered.push(p);
		});
		return filtered;
	}

	public function find(?postfix:String = ''):FlxSound {
		final ret = filter( (p, v) -> p == postfix );
		if (ret.length > 0)
			return ret[0];
		else
			return null;
	}

	public function destroy() {
		forEach(v -> {
			v.stop();
			v.destroy();
		});
		playing = false;
		__playing = false;
	}
}