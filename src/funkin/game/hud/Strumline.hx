package funkin.game.hud;

import funkin.game.Strum;

@:access(funkin.game.Strum)
class Strumline extends FlxTypedSpriteGroup<Strum> {
	public var character(default, null):Character;
	public var characterID(default, null):Int;
	public var cpu(default, set):Bool;
	public var isPixel(default, set):Bool;
	public var texture(default, set):String;

	public var notes:Array<Note> = [];

	function set_cpu(value:Bool) {
		forEach(s -> s.cpu = value);
		return cpu = value;
	}

	function set_isPixel(value:Bool) {
		forEach(s -> s.isPixel = value);
		return isPixel = value;
	}

	function set_texture(path:String) {
		forEach(s -> s.texture = path);
		return texture = members[0]?.texture ?? path;
	}

	public function new(x:Float = 0, y:Float = 0, ?keys:Int = 4, ?characterID:Int, ?cpu:Bool = false, ?texture:String, ?isPixel:Bool = false) {
		super(x, y);

		@:bypassAccessor {
			this.characterID = int(Math.abs(characterID));
			this.cpu = cpu;
			this.isPixel = isPixel;
			this.texture = texture ?? Strum.FALLBACK_TEXTURE;
		}

		if (MusicBeatState.getState() is PlayState && characterID != null) {
			final game = cast(MusicBeatState.getState(), PlayState);
			if (game?.characters[characterID] != null)
				character = game.characters[characterID];
		}

		for (i in 0...keys) {
			var strum = new Strum(i * 112, 0, i, characterID, cpu, texture, isPixel);
			add(strum);
		}
	}
	
	public function playStatic()
		forEach(s -> s.playStatic());
}
