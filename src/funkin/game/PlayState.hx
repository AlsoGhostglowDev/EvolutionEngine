package funkin.game;

import funkin.game.*;
import funkin.game.system.*;
import funkin.game.objects.*;

@:access(funkin.game.SongData)
@:access(funkin.game.objects.HUD)
@:access(funkin.game.objects.Character)
@:access(funkin.game.objects.Stage)
class PlayState extends ScriptableState {
    public var characters:Array<Character> = [];
    public var stage:Stage;
    public var hud:HUD;

    public var inst:FlxSound;
    public var voices:VoicesHandler;

    public static var song:SongData; 
    public static var isPixelStage(default, set):Bool = false;

    // wip
    static function set_isPixelStage(value:Bool)
        return isPixelStage = value;

    public function new() {
        super();
    }

    override function create() {
        call('create', []);
        super.create();
    }
}