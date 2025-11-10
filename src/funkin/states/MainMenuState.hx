package funkin.states;

class MainMenuState extends SelectableState {
    var buttons:Array<String> = [];

    public function new() {
        super(0, 4);

        var bg = new FlxSprite();
        bg.loadGraphic(Paths.image('menuDesat'));
        bg.color = 0xFFF9DB69;
        add(bg);

        var logoBumpin = new funkin.objects.LogoBumpin(0, 0, 'logoBumpin');
        logoBumpin.screenCenter();
        add(logoBumpin);
    }
}

class MenuButton extends FlxSprite {
    
}