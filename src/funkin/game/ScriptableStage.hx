package funkin.game;

#if HSCRIPT_ALLOWED
import funkin.backend.scripting.HScript;
#end
import funkin.game.Stage.StageData;

import tjson.TJSON;

class ScriptableStage extends Stage implements IScriptable
{
	public var scripts:Array<#if HSCRIPT_ALLOWED HScript #else Dynamic #end> = [];

	public function new(stage:String) {
		super(stage);

		#if HSCRIPT_ALLOWED
		//if (Paths.exists(Paths.hscript(stage, 'data/stages'), true))
		if (Paths.hscript(stage, 'data/stages') != null)
		{
			scripts.push(new HScript(Paths.hscript(stage, 'data/stages'), {
				parent: MusicBeatState.getState(),
				ignoreErrors: false
			}));
		}

		if(this.data?.scripts != null) {
			for(scr in this.data.scripts) {
				if(scr.path != null && Paths.hscript(scr.path, "") != null) {
					scripts.push(new HScript(Paths.hscript(scr.path, ""), {
						parent: MusicBeatState.getState(),
						ignoreErrors: false,
						customFlags: this.data.flags ?? []
					}));
				} else if(scr.code != null) {
					var _haxeCode:HScript = new HScript(scr.code, {
						parent: MusicBeatState.getState(),
						ignoreErrors: false,
						isString: true,
						customFlags: this.data.flags ?? []
					});
					scripts.push(_haxeCode);

					_haxeCode.execute(scr.code);
				}
			}
		}
		#end
	}

	public function call(func:String, ?args:Array<Dynamic>) {
		#if HSCRIPT_ALLOWED
		for(hscript in scripts) hscript?.call(func, args ?? []);
		#end
	}

	public function set(field:String, value:Dynamic) {
		#if HSCRIPT_ALLOWED
		for(hscript in scripts) hscript?.set(field, value);
		#end
	}

	override function destroy() {
		#if HSCRIPT_ALLOWED
		for(hscript in scripts) {
			if(hscript != null) {
				hscript.destroy();
				hscript = null;
			}
		}
		#end

		super.destroy();
	}
}
