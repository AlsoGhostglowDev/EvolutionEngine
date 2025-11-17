package funkin.backend;

import funkin.game.objects.Character;
import funkin.backend.input.Controls;
import funkin.states.*;

typedef BeatHitSignal = FlxTypedSignal<Int->Void>;

@:access(funkin.backend.system.Conductor)
class MusicBeatState extends FlxState implements IBeatListener {
    public var controls:Controls;
    public var fallbackState:Class<MusicBeatState>;

    public var onStepHit:BeatHitSignal;
    public var onBeatHit:BeatHitSignal;
    public var onMeasureHit:BeatHitSignal;

    // for hscript and lua
    public static var instance:MusicBeatState;

    public function new() {
        super();

        instance = this;

        controls = new Controls();
        fallbackState = MainMenuState;

        if (FlxG.sound.music != null && Conductor.trackedMusic == null)
            Conductor.trackedMusic = FlxG.sound.music;

        onStepHit = new BeatHitSignal();
		onBeatHit = new BeatHitSignal();
		onMeasureHit = new BeatHitSignal();

        onStepHit.add(stepHit);
		onBeatHit.add(beatHit);
		onMeasureHit.add(measureHit);
    }

	public function lerp(a:Float, b:Float, ratio:Float, ?fpsSensitive:Bool = false) {
        final lerpRatio = fpsSensitive ? getLerpRatio(ratio) : ratio;
        return FlxMath.lerp(a, b, lerpRatio);
    }

    public static function getState():MusicBeatState
        return cast(FlxG.state, MusicBeatState);

	var __lastStep:Int = -1;
	var __lastBeat:Int = -1;
	var __lastMeasure:Int = -1;
    override function update(elapsed:Float) {
		super.update(elapsed);

        if (__lastStep != Conductor.curStep)
            for (step in (__lastStep + 1)...Conductor.curStep + 1)
                onStepHit.dispatch(step);

		if (__lastBeat != Conductor.curBeat)
			for (beat in (__lastBeat + 1)...Conductor.curBeat + 1)
			    onBeatHit.dispatch(beat);

		if (__lastMeasure != Conductor.curMeasure)
			for (measure in (__lastMeasure + 1)...Conductor.curMeasure + 1)
			    onMeasureHit.dispatch(measure);

        __lastStep    = Conductor.curStep;
		__lastBeat    = Conductor.curBeat;
		__lastMeasure = Conductor.curMeasure;
    }

    public function stepHit(curStep:Int) {}
	public function beatHit(curBeat:Int) {}
	public function measureHit(curMeasure:Int) {}
}