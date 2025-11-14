package funkin.game.objects;

import flixel.math.FlxPoint;
import funkin.backend.system.Parser;
import sys.io.File;
import tjson.TJSON;

/*
 * Note to future selfs: classes with @:structInit do not work with Json parsing.
 */
typedef AnimationData = {
	animName:String,
	prefix:String,
	offset:Array<Int>,
	frameRate:Int,
	indices:Array<Int>,
	looped:Bool
}

typedef CharacterData = {
	name:String,
	icon:String,
	antialiasing:Bool,
	source:String,
	healthColors:Int,
	cameraOffsets:Array<Int>,
	holdTime:Float,
	scale:Float,
	flipped:Bool,
	animations:Array<AnimationData>
}

typedef PsychAnimationData = {
	anim:String,
	name:String,
	offsets:Array<Int>,
	fps:Int,
	indices:Array<Int>,
	loop:Bool
}

typedef PsychCharacter = {
	animations:Array<PsychAnimationData>,
	no_antialiasing:Bool,
	image:String,
	position:Array<Int>,
	healthicon:String,
	flip_x:Bool,
	healthbar_colors:Array<Int>,
	camera_position:Array<Int>,
	sing_duration:Float,
	scale:Float
}

typedef CodenameAnimationData = {
	name:String,
	anim:String,
	x:String,
	y:String,
	fps:String,
	loop:String,
	indices:String
}

typedef CodenameCharacter = {
	x:String,
	y:String,
	camx:String,
	camy:String,
	sprite:String,
	gameOverChar:String,
	holdTime:String,
	antialiasing:String,
	flipX:String,
	interval:String,
	isPlayer:String,
	icon:String,
	color:String,
	scale:String
}

class Character extends FlxSprite {
	public static var fallbackCharacter = 'bf';

	public var charData:CharacterData;

	public var name(default, null):String;
	public var icon(default, null):String;

	public var animationList:Array<String> = [];
	public var animationData:Map<String, AnimationData> = [];
	public var animationOffsets:Map<String, FlxPoint> = [];

	public function new(x, y, name) {
		super(x, y);

		if (!loadCharacter(name))
			loadCharacter(fallbackCharacter);
	}

	public function loadCharacter(charName:String):Bool {
		var sourceData = Paths.character(charName);
		var charJson = Parser.parseCharacter(File.getContent(sourceData), justifyEngine(sourceData));
		buildCharacter(charJson);

		if (charJson != null)
			return true;

		return false;
	}

	public function buildCharacter(data:CharacterData)
	{
		name = data.name;
		icon = data.icon;
		antialiasing = data.antialiasing;

		scale.set(data.scale, data.scale);
		updateHitbox();

		flipX = data.flipped;

		frames = FunkinUtil.loadSparrowAtlas('characters/${data.source}');
		for (i => anim in data.animations) { 
			if (anim.indices != null && anim.indices?.length ?? 0 > 0) {
                animation.addByIndices(anim.animName, anim.prefix, anim.indices, '.${Flags.IMAGE_EXT}', anim.frameRate, anim.looped);
            } else {
				animation.addByPrefix(anim.animName, anim.prefix, anim.frameRate, anim.looped);
            }

			animationData.set(anim.animName, anim);
			animationOffsets.set(anim.animName, FlxPoint.get(anim.offset[0], anim.offset[1]));
			animationList.push(anim.animName);
		}

		charData = data;
	}

	public var specialAnim:Bool = false; // disallow idle unless forced
	public var ignoreNotes:Bool = false; // to be used in playstate
	public var holdTime:Float = 0;
	public function playAnim(animName:String, ?forced:Bool = false) {
		animation.play(animName, forced);
		holdTime = 0;
	}

	var __danceDirection:String = 'left';
	public function dance(?forced:Bool = false) {
		if ((!specialAnim && holdTime >= charData.holdTime) || forced) {
			if (animationList.contains('danceLeft') && __danceDirection == 'right')
				playAnim('danceLeft', forced);
			else if (animationList.contains('danceRight') && __danceDirection == 'right')
				playAnim('danceRight', forced);
            else
			    playAnim('idle', forced);
		}
	}

	override function update(elapsed:Float)
		holdTime += elapsed;

	public static function justifyEngine(path:String) {
		if (path.endsWith('.xml'))
			return CODENAME
		else if (Reflect.hasField(TJSON.parse(File.getContent(path)), 'image'))
			return PSYCH;
		else
			return EVOLUTION;
	}
}
