package funkin.states;

import flixel.util.FlxTimer;
import funkin.objects.LogoBumpin;
import funkin.game.objects.Character;

class MainMenuState extends SelectableState {
    var buttons:Array<String> = [];

	var logoBumpin:LogoBumpin;
    var char:Character;
    public function new() {
        super(0, 4);

        var bg = new FlxSprite();
        bg.loadGraphic(Paths.image('menuDesat'));
        bg.color = 0xFFF9DB69;
        add(bg);

        logoBumpin = new LogoBumpin(0, 0, 'logoBumpin');
        logoBumpin.screenCenter();
        add(logoBumpin);

        char = new Character(100, 100, 'bf');
        add(char);

        FlxG.sound.playMusic(FunkinUtil.loadSound(Paths.music('freakyMenu')));
        Conductor.trackedMusic = FlxG.sound.music;
        Conductor.bpm = 102;
    }

    override function update(elapsed:Float)
        super.update(elapsed);

    override function beatHit(curBeat:Int) {
        super.beatHit(curBeat);

        if (curBeat % 2 == 0) {
            logoBumpin.bump();
            char.animation.play('idle', false);
        }
    }
}

class MenuButton extends FlxSprite {
    
}