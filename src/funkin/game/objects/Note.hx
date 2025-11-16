package funkin.game.objects;

import funkin.game.objects.Character;

import sys.io.File;

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
        tryLoadFrames(this, 'noteskins/$texture');

        return texture;
    }

    public function new(noteData:Int, characterID:Int, ?isSustain:Bool = false, ?texture:String = 'NOTE_assets') {
        super();

        this.noteData = noteData;
        this.characterID = characterID;
        isSustainNote = isSustain;

        if (MusicBeatState.getState() is PlayState) {
            final game = cast(MusicBeatState.getState(), PlayState);
            if (game?.characters[characterID] != null)
                character = game.characters[characterID];
        }

        tryLoadFrames(this, 'noteskins/$texture');
        loadAnimations();
    }

    function loadAnimations(?colorID:Int, ?loadAll:Bool = false) {
        colorID ??= noteData;

        if (isSustainNote) {
            if (colorID == 0) { // purple typo
                var hasTypo = attemptAddAnimationByPrefix(this, 'purpleholdend', 'pruple hold end', 24, true);
                if (hasTypo) {
					final xmlPath = Paths.sparrow('noteskins/$texture');
                    File.saveContent(xmlPath, FileUtil.getContent(xmlPath).replace('pruple', 'purple'));
                }
            }

		    animation.addByPrefix('${colorArray[colorID]}holdend', '${colorArray[colorID]} hold end', 24, true);
		    animation.addByPrefix('${colorArray[colorID]}hold', '${colorArray[colorID]} hold piece', 24, true);
        }
		animation.addByPrefix(colorArray[colorID], colorArray[colorID], 24, true);

        if (loadAll)
            for (i => col in colorArray) {
                if (i == colorID) continue;
                loadAnimations(i);
            }
    }
}