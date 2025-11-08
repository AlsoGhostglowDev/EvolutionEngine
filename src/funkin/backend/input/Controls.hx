package funkin.backend.input;

// wip: make this shit better
class Controls {
    public var ACCEPT(get, never):Bool;
    
    function get_ACCEPT() 
        return FlxG.keys.justPressed.ENTER && !FlxG.keys.pressed.ALT;

    public function new() {}
}