package funkin.backend;

class SelectableState extends MusicBeatState {
    public var curSelected:Int = 0;
    public var CHANGE_ADD(get, never):Bool;
	public var CHANGE_SUB(get, never):Bool;
    public var CHANGED(get, never):Bool;
    public var delta(get, never):Int;

    public var allowScrolling:Bool = false;
    public var allowWrapping:Bool = true;

    public var minimum:Int = 0;
    public var maximum:Int = 0;

    public dynamic function get_CHANGE_ADD():Bool 
        return FlxG.keys.justPressed.DOWN;

    public dynamic function get_CHANGE_SUB():Bool 
        return FlxG.keys.justPressed.UP;

	public dynamic function get_CHANGED():Bool 
		return CHANGE_ADD || CHANGE_SUB || (allowScrolling && FlxG.mouse.wheel != 0);

    public dynamic function get_delta():Int {
        if (CHANGED)
            return CHANGE_ADD ? 1 : (CHANGE_SUB ? -1 : FlxG.mouse.wheel);

        return 0;
    }

    public var onItemSelected:FlxTypedSignal<Int->Void>;
	public var onItemChanged:FlxTypedSignal<Int->Void>;

	var __previousSelected:Int = -1;

    public function new(?minimum:Int = 0, ?maximum:Int = 0) {
        super();

        this.minimum = minimum;
        this.maximum = maximum;

        onItemSelected = new FlxTypedSignal();
		onItemChanged = new FlxTypedSignal();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (CHANGED)
            changeItem(delta);

        if (controls.ACCEPT)
            onItemSelected.dispatch(curSelected);
    }

    public function changeItem(delta:Int) {
        __previousSelected = curSelected;
		curSelected += delta;

        if (allowWrapping) {
            curSelected = (curSelected > maximum) ? minimum : curSelected;
            curSelected = (curSelected < minimum) ? maximum : curSelected; 
        } else FlxMath.bound(curSelected, minimum, maximum);

        onItemChanged.dispatch(delta);
    }
}