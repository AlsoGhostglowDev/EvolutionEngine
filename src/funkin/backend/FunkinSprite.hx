package funkin.backend;

import flixel.system.FlxAssets.FlxGraphicAsset;

class FunkinSprite extends FlxSprite {
    public var followAntialiasing:Bool = true;
    public function new(X:Float = 0, Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset) {
        super(X, Y, SimpleGraphic);
        antialiasing = true; // wip ; placeholder. Preferences isn't made yet.
    }
}