package funkin.backend.system;

import funkin.game.SongData.ChartNote;
import funkin.game.SongData.Player;
import funkin.game.SongData.PsychSection;
import funkin.game.SongData.PsychSong;
import funkin.game.SongData.Song;
import funkin.game.SongData;
import funkin.game.objects.Character.AnimationData;
import funkin.game.objects.Character.CharacterData;
import funkin.game.objects.Character.CodenameAnimationData;
import funkin.game.objects.Character.CodenameCharacter;
import funkin.game.objects.Character.PsychAnimationData;
import funkin.game.objects.Character.PsychCharacter;
import tjson.TJSON;
#if sys
import sys.io.File;
#end

enum EngineType
{
	EVOLUTION;
	CODENAME;
	PSYCH;
	UNKNOWN;
}

enum ChartEngineType
{
	EVOLUTION;
	CODENAME;
	PSYCH;
	PSYCH_LEGACY;
	VSLICE;
	UNKNOWN;
}

// ts so ahh 🥀
@:access(funkin.game.objects.Character)
@:access(funkin.states.debug.ChartEditor)
@:access(funkin.game.SongData)
@:access(funkin.game.Stage)
@:publicFields class Parser
{
	static function chart(content:String, ?from:ChartEngineType = EVOLUTION, ?to:ChartEngineType = EVOLUTION):Dynamic
	{
		switch (to)
		{
			case EVOLUTION:
				switch (from)
				{
					case EVOLUTION:
						var data:Song = TJSON.parse(content);
						return data;
					case CODENAME:
						// wip
						return {};
					case PSYCH:
						var unsafeJson = TJSON.parse(content);
						var chartJson:PsychSong = unsafeJson;
						if (Reflect.hasField(unsafeJson, 'song') && !(unsafeJson.song is String)) // check for legacy
							chartJson = chart(content, PSYCH_LEGACY);

						var data:PsychSong = chartJson;
						var characters:Array<Player> = [
							{name: data.player2, isPlayer: false, isBopper: false}, // dad
							{name: data.player1, isPlayer: true, isBopper: false},  // bf
							{name: data.gfVersion, isPlayer: false, isBopper: true} // gf
						];

						var notes:Array<ChartNote> = [];
						for (section in data.notes)
						{
							final gfSec = section.gfSection;
							final mustHit = section.mustHitSection;
							for (secNote in section.sectionNotes)
							{
								final strumTime = secNote[0];
								final noteData = secNote[1];
								final susLen = secNote[2];
								var characterID:Int = (gfSec && mustHit && noteData <= 3) ? 2 : -1;
								if (characterID < 0)
									characterID = noteData <= 3 ? 0 : 1;
								var note:ChartNote = {
									strumTime: strumTime,
									noteData: noteData % 4,
									sustainLength: susLen,
									character: characterID
								}

								if (secNote.length > 3) // has noteType
									note.noteType = secNote[3];

								notes.push(note);
							}
						}

						var returnData:Song = {
							characters: characters,
							song: data.song,
							hasVoices: data.needsVoices,
							stage: data.stage,
							bpm: data.bpm,
							scrollSpeed: data.speed,
							notes: notes,
							keys: 4,
							postfix: '',
							evoChart: true
						};
						return returnData;
					case PSYCH_LEGACY:
						var data:PsychSong = TJSON.parse(content).song;
						if (Reflect.hasField(data, 'notes')) {
							for (section in data.notes)
							{
								if (section.sectionNotes != null && section.sectionNotes?.length ?? 0 > 0 && section.mustHitSection)
								{
									for (note in section.sectionNotes)
									{
										if (note[1] > 3) // noteData
											note[1] = note[1] % 4;
										else
											note[1] += 4;
									}
								}
							}
						}

						return chart(haxe.Json.stringify(data), PSYCH);
					case VSLICE:
						// wip
						return {};
					case UNKNOWN: return {};
				}
			case CODENAME:
				// wip
				return {};
			case PSYCH:
				// wip
				return {};
			case PSYCH_LEGACY:
				return chart(content, from, PSYCH);
			case VSLICE:
				// wip
				return {};
			case UNKNOWN:
				return {};
		}
	}

	static function character(content:String, ?from:EngineType = EVOLUTION, ?to:EngineType = EVOLUTION):Dynamic
	{
		switch (to)
		{
			case EVOLUTION:
				switch (from)
				{
					case EVOLUTION:
						var data = TJSON.parse(content);
						return data;
					case CODENAME:
						// wip
						return {};
					case PSYCH:
						var data:PsychCharacter = TJSON.parse(content);
						var animations:Array<AnimationData> = [];
						for (animData in data.animations)
						{
							var animation:AnimationData = {
								animName: animData.anim,
								prefix: animData.name,
								offset: animData.offsets,
								frameRate: animData.fps,
								indices: animData.indices,
								looped: animData.loop
							};
							animations.push(animation);
						}

						var returnData:CharacterData = {
							name: '',
							icon: data.healthicon,
							antialiasing: !data.no_antialiasing,
							source: data.image.replace('characters/', ''),
							healthColors: fromRGBArray(data.healthbar_colors),
							cameraOffsets: data.camera_position,
							holdTime: data.sing_duration,
							scale: data.scale,
							flipped: data.flip_x,
							animations: animations
						};

						return returnData;
					case UNKNOWN: return {};
				}
			case CODENAME:
				// wip
				return {};
			case PSYCH:
				// wip
				return {};
			case UNKNOWN:
				return {};
		}
	}

	static function saveJson(path:String, content:Dynamic, ?absolute:Bool = false):String
	{
		final jsonContent = haxe.Json.stringify(content, '\t');
		try
		{
			if (Paths.exists('$path.json', absolute))
				FileUtil.saveContent(Paths.getPath('$path.json'), jsonContent);
			else
				throw 'saveJson: Path "$path.json" doesn\'t exist!';
		}
		catch (e)
			trace('error: ${Std.string(e)}');
		return jsonContent;
	}

	static function buildXML(data:Dynamic) {}
}
