package funkin.backend.system;

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
}

// ts so ahh 🥀

@:access(funkin.game.objects.Character)
@:access(funkin.game.objects.Stage)
@:access(funkin.states.debug.ChartEditor)
@:publicFields class Parser
{
	static function parseCharacter(content:String, ?from:EngineType = EVOLUTION, ?to:EngineType = EVOLUTION):Dynamic
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
						// trace('UNDFSUFSFNSFSNFSNFJ');
						// trace(animations[0].animName);

						var returnData:CharacterData = {
							name: '',
							icon: data.healthicon,
							antialiasing: !data.no_antialiasing,
							source: cast(data.image, String).replace('characters/', ''),
							healthColors: fromRGBArray(data.healthbar_colors),
							cameraOffsets: data.camera_position,
							holdTime: data.sing_duration,
							scale: data.scale,
							flipped: data.flip_x,
							animations: animations
						};

						return returnData;
				}
			case CODENAME:
				// wip
				return {};
			case PSYCH:
				// wip
				return {};
		}
	}

	static function saveJson(path:String, content:Dynamic):Bool
	{
		#if sys
		try {
			if (Paths.exists(path)) {
				File.saveContent(path, TJSON.encode(content, FancyStyle));
				return false;
			} else
				throw 'saveJson: Path "$path" doesn\'t exist!';
		} catch(e) {
			trace('error: ${Std.string(e)}');
		}
		#end
		return false;
	}

	static function buildXML(data:Dynamic) {}
}
