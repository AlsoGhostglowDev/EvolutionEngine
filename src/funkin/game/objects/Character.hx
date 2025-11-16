package funkin.game.objects;

import flixel.math.FlxPoint;
import funkin.backend.system.Parser;
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
	public static var FALLBACK_CHARACTER = 'bf';

	public var charData:CharacterData;

	public var name(default, null):String;
	public var icon(default, null):String;
	public var isPlayer(default, set):Bool = false;

	public var animationList:Array<String> = [];
	public var animationData:Map<String, AnimationData> = [];
	public var animationOffsets:Map<String, FlxPoint> = [];

	public var characterID:Int = 0;

	var __initialized:Bool = false;

	function set_isPlayer(value:Bool) {
		isPlayer = value;
		if (__initialized)
			loadCharacter(name);
		return value;
	}

	public function new(x:Float = 0, y:Float = 0, name:String, ?isPlayer:Bool = false) {
		super(x, y);

		this.name = name;
		this.isPlayer = isPlayer;

		if (!loadCharacter(name)) {
			loadCharacter(FALLBACK_CHARACTER);
			__initialized = true;
		}
	}

	// playstate only
	public function fetchID() {
		if (MusicBeatState.getState() is PlayState) {
			final game = cast(MusicBeatState.getState(), PlayState);
			game.characters.indexOf(this);
		}
	}

	public function loadCharacter(charName:String):Bool {
		final sourceData = Paths.character(charName);
		final charEngine = justifyEngine(sourceData);
		var charData = Parser.character(FileUtil.getContent(sourceData), charEngine);

		if (charEngine != EVOLUTION) {
			charData.name = name; 
			Parser.saveJson('data/characters/$charName', charData);
		}

		buildCharacter(charData);

		if (charData != null)
			return true;

		return false;
	}

	public function buildCharacter(data:CharacterData) {
		name = data.name;
		icon = data.icon;
		antialiasing = data.antialiasing;

		scale.set(data.scale, data.scale);
		updateHitbox();

		flipX = isPlayer;

		frames = loadSparrowAtlas('characters/${data.source}');
		for (anim in data.animations) {
			if (anim.indices != null && anim.indices?.length ?? 0 > 0)
				animation.addByIndices(anim.animName, anim.prefix, anim.indices, '.${Flags.IMAGE_EXT}', anim.frameRate, anim.looped, data.flipped);
            else
				animation.addByPrefix(anim.animName, anim.prefix, anim.frameRate, anim.looped, data.flipped);

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
		if (animName.contains('sing'))
			holdTime = 0;

		offset = animationOffsets.get(animName);
	}

	var __danceDirection:String = 'left';
	public function dance(?forced:Bool = false) {
		if ((!specialAnim && holdTime >= (Conductor.stepCrochet * 0.0011 * charData.holdTime)) 
			|| (animation.name ?? 'dance').contains('dance') || (animation.name ?? 'idle') == 'idle' 
			|| forced
		) {
			if (animationList.contains('danceLeft') && __danceDirection == 'right') {
				playAnim('danceLeft', forced);
				__danceDirection = 'left';
			} else if (animationList.contains('danceRight') && __danceDirection == 'left') {
				playAnim('danceRight', forced);
				__danceDirection = 'right';
			} else
			    playAnim('idle', forced);
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		holdTime += elapsed;
	}

	public static function justifyEngine(path:String) {
		if (path.endsWith('.xml'))
			return CODENAME;
		else if (Reflect.hasField(TJSON.parse(FileUtil.getContent(path)), 'image'))
			return PSYCH;
		else
			return EVOLUTION;
	}
}
