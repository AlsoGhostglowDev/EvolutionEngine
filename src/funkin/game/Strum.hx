package funkin.game;

import funkin.game.Character;
import funkin.game.Note.PixelNoteAnimation;

class Strum extends FunkinSprite
{
	public static var directionList:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
	public static var FALLBACK_TEXTURE:String = 'NOTE_assets';

	public var cpu:Bool = false; // for playstate
	public var noteData:Int = 0;

	public var character(default, null):Character;
	public var characterID(default, null):Int;

	public var isPixel(default, set):Bool = false;
	public var pixelMeta(default, set):PixelNoteAnimation;
	public var texture(default, set):String = FALLBACK_TEXTURE;

	public var finishCallback:String->Void;

	function set_texture(path:String)
	{
		if (path.startsWith('noteskins/'))
			path.replace('noteskins/', '');

		texture = null;
		if (Paths.exists('images/noteskins/$path.png', false))
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

	public function new(x:Float = 0, y:Float = 0, noteData:Int = 0, ?characterID:Int, ?cpu:Bool = false, ?texture:String, ?isPixel:Bool = false)
	{
		super(x, y);

		this.noteData = noteData;
		this.characterID = int(Math.abs(characterID));
		this.cpu = cpu;

		if (MusicBeatState.getState() is PlayState && characterID != null)
		{
			final game = cast(MusicBeatState.getState(), PlayState);
			if (game?.characters[characterID] != null)
				character = character = game.characterFromID(characterID);
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

		animation.finishCallback = function(name:String)
		{
			if (!(name.contains('static')))
				playAnim('static');

			if (finishCallback != null)
				finishCallback(name);
		}

		reloadNote();
	}

	public function reloadNote()
	{
		setGraphicSize(Note.NOTE_SIZE);
		updateHitbox();

		loadAnimations();
	}

	public function loadAnimations(?noteData:Int, ?loadAll:Bool = false)
	{
		noteData ??= this.noteData;

		final direction = directionList[noteData];
		if (isPixel) {}
		else
		{
			final lDirection = direction.toLowerCase();
			animation.addByPrefix('static$direction', 'arrow$direction', 24, true);
			animation.addByPrefix('press$direction', '$lDirection press', 24, false);
			animation.addByPrefix('confirm$direction', '$lDirection confirm', 24, false);
		}
		playAnim('static${directionList[noteData]}', true);

		if (loadAll)
		{
			for (i => dir in directionList)
			{
				if (i == noteData)
					continue;
				loadAnimations(i);
			}
		}
	}

	public var allowStatic:Bool = true;
	public function playAnim(anim:String = 'static', ?forced:Bool = true) {
		final _anim = anim;
		if (anim == 'static' || anim == 'confirm' || anim == 'press')
			anim += directionList[noteData];

		if ((allowStatic && _anim == 'static') || _anim != 'static')
			animation.play(anim, forced);

		centerOrigin();
		centerOffsets();
	}

	public function playStatic() {
		allowStatic = true;
		playAnim('static');
	}
}
