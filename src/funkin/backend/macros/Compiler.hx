package funkin.backend.macros;

#if macro
import haxe.macro.Context;
#end

class Compiler
{
	public static var extra_defines:Map<String, Dynamic> = [];

	public static var custom_defines(get, default):Map<String, Dynamic>;
	private static function get_custom_defines():Map<String, Dynamic> {
		#if !macro
		var _customdef:Map<String, Dynamic> = [];
		_customdef.set("EVOLUTION_ENGINE", true);
		_customdef.set("EVOLUTION_ENGINE_VER", openfl.Lib.application.meta["version"]);
		for (name => value in extra_defines) {
			_customdef.set(name, value);
		}

		return _customdef;
		#else
		return [];
		#end
	}

	public static var defines(get, null):Map<String, Dynamic>;

	private static inline function get_defines()
		return __getDefines();

	private static macro function __getDefines()
	{
		#if display
		return macro $v{[]};
		#else
		return macro $v{Context.getDefines()};
		#end
	}
}
