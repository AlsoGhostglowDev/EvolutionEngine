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
}