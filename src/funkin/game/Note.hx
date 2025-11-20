package funkin.game;

import funkin.game.Character;
import sys.io.File;

// its a class because i needed the setter okay
class PixelNoteAnimation
{
	public var frameWidth(default, set):Int = 0;
	public var frameHeight(default, set):Int = 0;

	public dynamic function set_frameWidth(value:Int)
		return frameWidth = value;

	public dynamic function set_frameHeight(value:Int)
		return frameHeight = value;

	public function new(width:Int = 0, height:Int = 0)
		setFrameSize(width, height);

	public function setFrameSize(width:Int, height:Int)
	{
		frameWidth = width;
		frameHeight = height;
	}
}

@:access(funkin.game.PlayState)
class Note extends FunkinSprite
{
	// used for animations
	public static var colorArray:Array<String> = ['purple', 'blue', 'green', 'red'];
	public static var NOTE_SIZE:Int = 112;
	public static var FALLBACK_TEXTURE:String = 'NOTE_assets';

	public var strumTime:Float = 0;
	public var noteData:Int = 0;
	public var characterID:Int = 0;
	public var character:Character;
	public var noteType:String = '';
	public var animSuffix:String = '';
	public var isSustainNote:Bool = false;

	public var isPixel(default, set):Bool = false;
	public var pixelMeta(default, set):PixelNoteAnimation;

	public var parent:Note; // for sustains
	public var spawned:Bool = false;
	public var canBeHit(get, never):Bool;
	public var ignoreNote:Bool = false;
	public var hit:Bool = false;

	public var strum:Strum;
	public var followPosition:Bool = true;
	public var followAngle:Bool = true;
	public var followAlpha:Bool = true;
	public var cpu(get, never):Bool;

	public var texture(default, set):String = FALLBACK_TEXTURE;

	function get_cpu()
		return strum?.cpu ?? false;

	public dynamic function get_canBeHit():Bool 
		return false;

	function set_texture(path:String)
	{
		if (path.startsWith('noteskins/'))
			path.replace('noteskins/', '');

		texture = null;
		if (Paths.exists('images/noteskins/$path.png'))
			texture = path;
		else
			trace('set_texture: Texture with path "images/noteskins/$path" not found!');

		texture ??= FALLBACK_TEXTURE;
		if (isPixel)
			loadGraphic(Paths.image('noteskins/$texture', false), true, pixelMeta.frameWidth, pixelMeta.frameHeight);
		else
			tryLoadFrames(this, 'noteskins/$texture', false);

		return texture;
	}

	function set_isPixel(value:Bool)
	{
		isPixel = value;
		texture = texture; // reload texture

		return value;
	}

	function set_pixelMeta(meta:PixelNoteAnimation)
	{
		pixelMeta = meta;
		if (isPixel)
			texture = texture; // reload texture

		return meta;
	}

	public function new(noteData:Int, isSustainNote:Bool = false, ?characterID:Int, ?texture:String, ?isPixel:Bool = false)
	{
		super();

		this.noteData = noteData;
		this.characterID = int(Math.abs(characterID));
		this.isSustainNote = isSustainNote;

		if (MusicBeatState.getState() is PlayState && characterID != null)
		{
			final game = cast(MusicBeatState.getState(), PlayState);
			if (game?.characters[characterID] != null)
				character = game.characterFromID(characterID);
		}

		@:bypassAccessor
		pixelMeta = new PixelNoteAnimation(17, 17);
		pixelMeta.set_frameWidth = function(value:Int)
		{
			pixelMeta.frameWidth = value;
			if (isPixel)
			{
				this.texture = this.texture; // reload tex
				loadAnimations(noteData);
			}

			return value;
		}

		pixelMeta.set_frameHeight = function(value:Int)
		{
			pixelMeta.frameHeight = value;
			if (isPixel)
			{
				this.texture = this.texture; // reload tex
				loadAnimations(noteData);
			}

			return value;
		}

		@:bypassAccessor
		this.isPixel = isPixel;
		this.texture = texture ?? FALLBACK_TEXTURE;

		reloadNote();
	}

	function reloadNote() {
		setGraphicSize(NOTE_SIZE);
		updateHitbox();
		
		loadAnimations();
	}

	function loadAnimations(?colorID:Int, ?loadAll:Bool = false)
	{
		colorID ??= noteData;

		if (isPixel) {}
		else
		{
			if (isSustainNote)
			{
				if (colorID == 0)
				{ // purple typo
					var hasTypo = attemptAddAnimationByPrefix(this, 'purpleholdend', 'pruple hold end', 24, true);
					if (hasTypo)
					{
						final xmlPath = Paths.sparrow('noteskins/$texture', false);
						FileUtil.saveContent(xmlPath, FileUtil.getContent(xmlPath).replace('pruple', 'purple'));
					}
				}

				animation.addByPrefix('${colorArray[colorID]}holdend', '${colorArray[colorID]} hold end', 24, true);
				animation.addByPrefix('${colorArray[colorID]}hold', '${colorArray[colorID]} hold piece', 24, true);
			}
			animation.addByPrefix(colorArray[colorID], '${colorArray[colorID]}0', 24, true);
		}
		animation.play(colorArray[noteData]);

		if (loadAll)
			for (i => col in colorArray)
			{
				if (i == colorID)
					continue;
				loadAnimations(i);
			}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (followAlpha) alpha = strum.alpha;
		if (followAngle) angle = strum.angle;
		if (followPosition) x = strum.x;
	}
}
