package funkin.game.objects;

import funkin.game.objects.Character;

import sys.io.File;

// its a class because i needed the setter okay
class PixelNoteAnimation {
	public var frameWidth(default, set):Int = 0;
	public var frameHeight(default, set):Int = 0;

	public dynamic function set_frameWidth(value:Int):Int;
	public dynamic function set_frameHeight(value:Int):Int; 

	public function new(width:Int = 0, height:Int = 0)
		setFrameSize(width, height);

	public function setFrameSize(width:Int, height:Int) {
		frameWidth = width;
		frameHeight = height;
	}
}

@:access(funkin.game.PlayState)
class Note extends FlxSprite {
	// used for animations
	public static var colorArray:Array<String> = ['purple', 'blue', 'green', 'red'];
	public static var FALLBACK_TEXTURE:String = 'NOTE_assets';

	public var strumTime:Float = 0;
	public var noteData:Int = 0;
	public var characterID:Int = 0;
	public var character:Character;
	public var noteType:String = '';
	public var isSustainNote:Bool = false;

	public var isPixel(default, set):Bool = false;
	public var pixelMeta:PixelNoteAnimation;

	public var parent:Note;
	public var spawned:Bool = false;
	public var hit:Bool = false;

	public var strum:Strum;
	public var followPosition:Bool;
	public var followAngle:Bool;
	public var followAlpha:Bool;
	public var cpu(get, never):Bool;

	public var texture(default, set):String = FALLBACK_TEXTURE;

	function get_cpu()
		return strum?.cpu ?? false;

	function set_texture(path:String) {
		if (path.startsWith('noteskins/'))
			path.replace('noteskins/', '');

		texture = null;
		try {
			if (Paths.exists('images/noteskins/$path.png'))
				texture = path;
			else
				throw 'set_texture: Texture with path "images/noteskins/$path" not found!';
		} catch(e:Dynamic)
			trace('error: ${e.toString()}');

		texture ??= Paths.image(FALLBACK_TEXTURE);
		if (isPixel)
			loadGraphic('noteskins/$texture', true, pixelMeta.frameWidth, pixelMeta.frameHeight);
		else
			tryLoadFrames(this, 'noteskins/$texture');

		return texture;
	}

	function set_isPixel(value:Bool) {
		isPixel = value;
		texture = texture; // reload texture

		return value;
	}

	public function new(noteData:Int, isSustainNote:Bool = false, ?characterID:Int, ?texture:String = 'NOTE_assets', ?isPixel:Bool = false) {
		super();

		this.noteData = noteData;
		this.characterID = Math.abs(characterID);
		this.isSustainNote = isSustainNote;

		if (MusicBeatState.getState() is PlayState && characterID != null) {
			final game = cast(MusicBeatState.getState(), PlayState);
			if (game?.characters[characterID] != null)
				character = game.characters[characterID];
		}

		this.isPixel = isPixel;
		this.texture = texture;
		
		loadAnimations();
	}

	function loadAnimations(?colorID:Int, ?loadAll:Bool = false) {
		colorID ??= noteData;

		if (isPixel) {

		} else {
			if (isSustainNote) {
				if (colorID == 0) { // purple typo
					var hasTypo = attemptAddAnimationByPrefix(this, 'purpleholdend', 'pruple hold end', 24, true);
					if (hasTypo) {
						final xmlPath = Paths.sparrow('noteskins/$texture');
						FileUtil.saveContent(xmlPath, FileUtil.getContent(xmlPath).replace('pruple', 'purple'));
					}
				}

				animation.addByPrefix('${colorArray[colorID]}holdend', '${colorArray[colorID]} hold end', 24, true);
				animation.addByPrefix('${colorArray[colorID]}hold', '${colorArray[colorID]} hold piece', 24, true);
			}
			animation.addByPrefix(colorArray[colorID], colorArray[colorID], 24, true);
		}

		if (loadAll)
			for (i => col in colorArray) {
				if (i == colorID) continue;
				loadAnimations(i);
			}
	}
}