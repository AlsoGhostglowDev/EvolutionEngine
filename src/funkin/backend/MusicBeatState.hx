package funkin.backend;

import funkin.backend.input.Controls;
import funkin.states.*;

class MusicBeatState extends FlxState {
    public var controls:Controls;
    public var fallbackState:Class<MusicBeatState>;

    public function new() {
        super();

        controls = new Controls();
        fallbackState = MainMenuState;
    }

	public function lerp(a:Float, b:Float, ratio:Float, ?fpsSensitive:Bool = false) {
        final lerpRatio = fpsSensitive ? FunkinUtil.getLerpRatio(ratio) : ratio;
        return FlxMath.lerp(a, b, lerpRatio);
    }
}