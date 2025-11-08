package funkin.states;

class MainMenuState extends SelectableState {
    public function new() {
        super(0, 4);

        var bg = new FlxSprite();
        bg.loadGraphic(Paths.image('menuDesat'));
        bg.color = 0xFFF9DB69;
        add(bg);
    }
}