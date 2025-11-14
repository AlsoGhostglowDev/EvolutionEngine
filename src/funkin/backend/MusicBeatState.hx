package funkin.backend;

import funkin.game.objects.Character;
import funkin.backend.input.Controls;
import funkin.states.*;

typedef BeatHitSignal = FlxTypedSignal<Int->Void>;

@:access(funkin.backend.system.Conductor)
class MusicBeatState extends FlxState {
    public var controls:Controls;
    public var fallbackState:Class<MusicBeatState>;

    public var onStepHit:BeatHitSignal;
    public var onBeatHit:BeatHitSignal;
    public var onMeasureHit:BeatHitSignal;

    public function new() {
        super();

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
        final lerpRatio = fpsSensitive ? FunkinUtil.getLerpRatio(ratio) : ratio;
        return FlxMath.lerp(a, b, lerpRatio);
    }

	var __lastStep:Int = -1;
	var __lastBeat:Int = -1;
	var __lastMeasure:Int = -1;
    override function update(elapsed:Float) {
		super.update(elapsed);

        if (__lastStep != Conductor.curStep)
            onStepHit.dispatch(Conductor.curStep);

		if (__lastBeat != Conductor.curBeat)
			onBeatHit.dispatch(Conductor.curBeat);

		// if (__lastMeasure != Conductor.curStep)
		// 	onMeasureHit.dispatch(Conductor.curMeasure);

        __lastStep    = Conductor.curStep;
		__lastBeat    = Conductor.curBeat;
		// __lastMeasure = Conductor.curMeasure;
    }

    public function stepHit(curStep:Int) {}
	public function beatHit(curBeat:Int) {}
	public function measureHit(curMeasure:Int) {}
}