package funkin.states;

import funkin.objects.LogoBumpin;
import funkin.game.objects.Character;

class MainMenuState extends SelectableState {
    var buttons:Array<String> = [];

	var logoBumpin:LogoBumpin;
    public function new() {
        super(0, 4);

        var bg = new FlxSprite();
        bg.loadGraphic(Paths.image('menuDesat'));
        bg.color = 0xFFF9DB69;
        add(bg);

        logoBumpin = new LogoBumpin(0, 0, 'logoBumpin');
        logoBumpin.screenCenter();
        add(logoBumpin);

        FlxG.sound.playMusic(loadSound(Paths.music('freakyMenu')));
        Conductor.trackedMusic = FlxG.sound.music;
        Conductor.bpm = 102;
    }

    override function update(elapsed:Float)
        super.update(elapsed);

    override function beatHit(curBeat:Int) {
        super.beatHit(curBeat);

        if (curBeat % 2 == 0)
            logoBumpin.bump();
    }
}

class MenuButton extends FlxSprite {
    
}