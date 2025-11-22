package;

import openfl.display.StageScaleMode;
import openfl.Lib;
import flixel.FlxGame;
import openfl.display.Sprite;

import funkin.backend.debug.Framerate;

class Main extends Sprite {
	public var framerate:Framerate;
	public function new() {
		super();
		addChild(new FlxGame(0, 0, funkin.game.PlayState, 60, 60, true));
		addChild(framerate = new Framerate());

		FlxG.signals.postUpdate.add(() -> {
			if (FlxG.keys.justPressed.F3)
				framerate.toggleVisibility();
		});

		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
	}
}
