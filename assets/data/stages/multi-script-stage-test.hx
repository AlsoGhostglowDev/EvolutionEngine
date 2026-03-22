package stages;

import funkin.backend.FunkinSprite;
import flixel.FlxSprite;

final IMAGE_DIR:String = "stages/week1/";

var bg:FlxSprite;
var stage:FlxSprite;
function create() {
	bg = new FlxSprite(0, 0, Paths.image(IMAGE_DIR + "stageback"));
	add(bg);

	trace("Main Stage Script created");
}
