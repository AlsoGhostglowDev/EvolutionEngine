package funkin.game.system;

class VoicesHandler {
	public var inst:FlxSound;
	public var container:Array<FlxSound> = [];
	public var postfixes:Map<String, FlxSound> = [];

	public var playing:Bool = false;
	public var paused:Bool = false;
	public var offset:Float = 0;
	public var time(get, never):Float;
	public var songPath:String;

	var __playing:Bool = false;

	function get_time()
		return (inst?.time ?? 0) + offset;

	public function new(trackedMusic:FlxSound, songName:String, ?postfix:String = '') {
		try {
			if (Paths.exists(Paths.song(songName), true))
				songPath = songName;
		} catch(e:Dynamic)
			trace('error: ${e.toString()}');

		inst = trackedMusic;
		addVoices(); // add the default voices
	}

	public function addVoices(?postfix:String = '') {
		final path = Paths.voices('$songPath$postfix');
		if (Paths.exists(path, true) && !postfixes.exists(postfix)) {
			var voices = new FlxSound();
			voices.loadEmbedded(loadSound(path));
			postfixes.set(postfix, voices);

			if (playing)
				voices.play();
		}
	}

	public function play() {
		for (voices in container)
			voices.play();

		playing = true;
		__playing = true;
	}

	public function sync() {
		for (voices in container)
			voices.time = time;
	}

	public function pause() {
		for (voices in container)
			voices.pause();

		paused = true;
		playing = false;
	}

	public function resume() {
		for (voices in container)
			voices.resume();

		paused = false;
		if (__playing)
			playing = true;
	}

	public function destroy() {
		for (voices in container) {
			voices.stop();
			voices.destroy();
		}
		playing = false;
		__playing = false;
	}
}