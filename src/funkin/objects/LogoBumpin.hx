package funkin.objects;

import flixel.system.FlxAssets.FlxGraphicAsset;

class LogoBumpin extends FlxSprite {
    public var idleAnimation(default, set):String;

    public var shouldBump:Bool = true;
	public var initialScale:Float = 1;
	public var bumpFactor:Float = 1.05;
	public var lerpFactor(default, set):Float = 0.4;

    public var onBump:FlxTypedSignal<Void->Void>;

    function set_lerpFactor(value:Float)
        return lerpFactor = FlxMath.bound(Math.abs(value), 0, 1);

    function set_idleAnimation(value:String) {
        animation.addByPrefix('idle', value, 24);
        return idleAnimation = value;
    }

    public function new(x:Float = 0, y:Float = 0, ?graphic:String) {
        super(x, y);

        onBump = new FlxTypedSignal();

        tryLoadFrames(this, graphic); // from FunkinUtil
        idleAnimation = 'idle';
    }

    public function bump() {
        if (shouldBump) {
            scale.set(bumpFactor, bumpFactor);
            onBump.dispatch();
        }
    }

    override function update(elapsed:Float) {
        if (shouldBump) {
            final lerpScale = FlxMath.lerp( scale.x, initialScale, getLerpRatio(lerpFactor) );
            scale.set(lerpScale, lerpScale);
        }

        super.update(elapsed);
    }
}