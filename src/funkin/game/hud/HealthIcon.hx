package funkin.game.hud;

import funkin.backend.utils.FunkinUtil;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;

enum HealthState {
    NORMAL;
    LOSING;
    CUSTOM(name:String);
}

class HealthIcon extends FunkinSprite {
	public var image(default, set):String;
	public var trackerOffset:FlxPoint = new FlxPoint(0, 0);
    public var isPlayer(default, set):Bool;
	public var state(default, set):HealthState = NORMAL;

    public var followObject:Bool = false;
	public var posTracker:FlxPoint;
	
	public var baseScale:FlxPoint = new FlxPoint(1, 1);
	public var lerpFactor:Float = 0.18;
	public var shouldLerp:Bool = true;

    override public function new(x:Float, y:Float, icon:String, ?isPlayer:Bool = false) {
        super(x, y);
		this.image = icon;
		this.isPlayer = isPlayer;
		this.baseScale.set(this.scale.x, this.scale.y);
		this.posTracker = FlxPoint.get(0, 0);
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

		if(followObject && posTracker != null) {
			setPosition((posTracker.x ?? 0) + trackerOffset.x, (posTracker.y ?? 0) + trackerOffset.y);
        }

		if (shouldLerp) { // Idk I think using a tween is better but sure -TBar
			scale.set(
				FlxMath.lerp(scale.x, baseScale.x, getLerpRatio(lerpFactor)),
				FlxMath.lerp(scale.y, baseScale.y, getLerpRatio(lerpFactor))
			);
		}
    }

    public function bop(bopAmount:Float = 0.3)
		scale.set(baseScale.x + bopAmount, baseScale.y + bopAmount);

    // Just for backwards compatibility
    public function changeIcon(path:String) {
        image = path;
    }

	public function set_image(val:String):String {
        image = val;
		var iconGraphic:FlxGraphic = Paths.getImage("icons/icon-" + val);
		iconGraphic ??= Paths.getImage("icons/" + val);
		iconGraphic ??= Paths.getImage("icons/icon-face");

		loadGraphic(iconGraphic, true, Math.floor(iconGraphic.width / 2), Math.floor(iconGraphic.height));
		updateHitbox();

		animation.add("idle", [0], 0, false, isPlayer);
		animation.add("losing", [1], 0, false, isPlayer);
		animation.play("idle");

		return val;
	}

    public function set_isPlayer(val:Bool):Bool {
		isPlayer = this.flipX = val;
        return val;
    }

    public function set_state(val:HealthState):HealthState
    {
        state = val;
		switch (state) {
			case NORMAL:
				if(hasAnimation("idle")) animation.play("idle");
            case LOSING:
				if(hasAnimation("losing")) animation.play("losing");
            case CUSTOM(name):
				if(hasAnimation(name)) animation.play(name);
        }
        return val;
    }
}