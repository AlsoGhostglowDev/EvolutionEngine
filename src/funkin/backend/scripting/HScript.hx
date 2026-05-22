package funkin.backend.scripting;

import funkin.backend.utils.ScriptUtil;
import funkin.backend.macros.Compiler;
import funkin.backend.Flags.Flag;
#if HSCRIPT_ALLOWED
import hscript.Expr.Error as HScriptError;
import hscript.Parser as HScriptParser; // To not confuse with the funkin parser
import hscript.Interp;
import hscript.Expr;
import hscript.Printer;
#end

class HScript extends Script {
	#if HSCRIPT_ALLOWED

	/**
	 * All static variables made by any script.
	 *
	 * If you are making a mod, make sure to clear this
	 * map once the mod is closed to prevent another mod
	 * using your variables!
	 */
	public static var staticVariables:Map<String, Dynamic> = [];

	/**
	 * All of the script's default imports.
	 * You can add custom ones here too!
	 */
	public static var defaultClasses:Map<String, Dynamic> = [
		//Basic types
		"Int" => Int, "Float" => Float,
		"String" => String, "Bool" => Bool,
		"StringMap" => haxe.ds.StringMap, "IntMap" => haxe.ds.IntMap,
		"Map" => ScriptUtil.resolveAbstract("haxe.ds.Map"),

		//Base level haxe classes
		"Math" => Math, "Std" => Std,
		"StringTools" => StringTools,
		"Reflect" => Reflect, 'Type' => Type,
		'Date' => Date, 'DateTools' => DateTools,
		#if sys
		'Sys' => Sys,
		"File" => sys.io.File,
		"FileSystem" => sys.FileSystem,
		#end

		//Evolution Engine classes
		"MusicBeatState" => funkin.backend.MusicBeatState,
		"FunkinUtil" => funkin.backend.utils.FunkinUtil,
		"Conductor" => funkin.backend.system.Conductor,
		"Controls" => funkin.backend.input.Controls,
		"Paths" => funkin.backend.system.Paths,
		"Flags" => funkin.backend.Flags,

		//Flixel classes
		"FlxG" => flixel.FlxG,
		"FlxSprite" => flixel.FlxSprite,
		"FlxBasic" => flixel.FlxBasic,
		"FlxText" => flixel.text.FlxText,
		"FlxTween" => flixel.tweens.FlxTween,
		"FlxEase" => flixel.tweens.FlxEase,
		"FlxMath" => flixel.math.FlxMath,
		"FlxSound" => flixel.sound.FlxSound,
		"FlxGroup" => flixel.group.FlxGroup,
		"FlxTypedGroup" => flixel.group.FlxGroup.FlxTypedGroup,
		"FlxSpriteGroup" => flixel.group.FlxSpriteGroup,

		"FlxAxes" => ScriptUtil.resolveAbstract("flixel.util.FlxAxes"),
		"FlxColor" => ScriptUtil.resolveAbstract("flixel.util.FlxColor")
	];

	public var parser:HScriptParser;
	public var interp:Interp;
	public var expr:Expr;

	/**
	 * The script's path.
	 */
	public var path:String;

	/**
	 * The script's options, like if it
	 * should ignore errors, custom flags, etc.
	 */
	public var options:HScriptOptions;

	/**
	 * A shortcut to the script's parent object.
	 */
	public var parent(get, set):Dynamic;
	public inline function get_parent():Dynamic { return interp.scriptObject; }
	public inline function set_parent(val:Dynamic):Dynamic {
		if(interp == null) return null;

		interp.scriptObject = val;
		if(val.variables != null) interp.publicVariables = val.variables;

		return interp.scriptObject;
	}

	override public function new(path:String, ?options:HScriptOptions) {
		super();

		this.options = options;
		this.path = path;
		this.options ??= {ignoreErrors: false, isString: false, customFlags: []};
		this.options.isString ??= false; // Just making sure

		if(parser == null) initParser(this.options.customFlags);
		if(interp == null) initInterp();

		try
		{
			if(this.options.parent != null) this.parent = this.options.parent;

			interp.variables.set("this", this);
			for (tag => value in defaultClasses) {
				interp.variables.set(tag, value);
			}

			if(!this.options.isString) {
				parser.line = 1;
				expr = parser.parseString(FileUtil.getContent(path), "HScript String");

				interp.execute(expr);
				call("new");
			}
		} catch(e) {
			if (this.options.ignoreErrors != null && !this.options.ignoreErrors) {
				alert('HScript Error!', e.toString());
				trace('Error on haxe script "${this.path}":\n${e.toString()}');
			}
		}
	}

	public inline function initParser(?additionalConditionals:Array<Flag>) {
		parser = new HScriptParser();
		parser.allowJSON = parser.allowMetadata = parser.allowTypes = parser.allowRegex = true;

		parser.preprocessorValues = Compiler.defines;
		for(name => value in Compiler.custom_defines)
			parser.preprocessorValues.set(name, value);

		if(additionalConditionals != null) {
			for(flag in additionalConditionals)
				parser.preprocessorValues.set(flag.name, flag.value);
		}
	}

	public inline function initInterp() {
		interp = new Interp();
		interp.allowStaticVariables = interp.allowPublicVariables = true;
		interp.staticVariables = HScript.staticVariables;

		interp.errorHandler = onError;
		interp.warnHandler = onWarn;
		interp.importFailedCallback = onImportFailed;
	}

	public var allowWildcardImports:Bool = true;
	public function onImportFailed(clsPath:Array<String>, aliasAs:String):Bool {
		if(allowWildcardImports && clsPath[clsPath.length-1] == "*") {

			// Wildcard class imports, like `import funkin.backend.utils.FunkinUtil.*`
			var __clsCopy:Array<String> = clsPath.copy();
			__clsCopy.pop();
			var clsInst = ScriptUtil.importResolve(__clsCopy.join("."));
			if(clsInst != null) {
				for (field in Type.getClassFields(clsInst)) {
					this.interp.variables.set(field, Reflect.field(clsInst, field));
				}
				return true;
			}

			// If all else fails, does a regular wildcard import
			var varsToImport:Array<String> = ScriptUtil.wildcardImport(clsPath.join("."));
			if(varsToImport != null && varsToImport.length > 0) {
				for (item in varsToImport) {
					this.interp.variables.set(ScriptUtil.getClassName(item), ScriptUtil.importResolve(item));
				}
				return true;
			}
		}
		return false;
	}

	public function onError(e:HScriptError) {
		trace("[ERROR] " + Printer.errorToString(e));
	}

	public function onWarn(e:HScriptError) {
		trace("[WARNING] " + Printer.errorToString(e));
	}

	public function execute(codeToRun:String):Dynamic {
		if (options.isString ?? false && parser != null) {
			parser.line = 1;
			return interp.execute(parser.parseString(codeToRun, path));
		}
		return null;
	}

	public function destroy() {
		expr = null;
		interp = null;
		parser = null;
	}

	override public inline function get(name:String):Dynamic {
		return (this.interp != null ? this.interp.variables.get(name) : null);
	}

	override public inline function set(variable:String, data:Dynamic) {
		if(this.interp != null) this.interp.variables.set(variable, data);
	}

	override public function call(func:String, ?args:Array<Dynamic>):Dynamic {
		if (interp == null) return null;

		var functionVar = interp.variables.get(func);
		if (functionVar == null || !Reflect.isFunction(functionVar)) return null;
		return (args != null && args.length > 0) ? Reflect.callMethod(null, functionVar, args) : functionVar();
	}
	#end
}

typedef HScriptOptions = {
	/**
	 * Whether the first argument is hscript code.
	 * If false, then a script path is expected in it's place.
	 * @default `false`
	 */
	@:default(false) var ?isString:Bool;

	/**
	 * The script's parent. Simple enough.
	 */
	var ?parent:Dynamic;

	/**
	 * Whether the script should show a message popup if
	 * a fatal error happens.
	 * @default `false`
	 */
	@:default(false) var ?ignoreErrors:Bool;

	/**
	 * Optional flags to add to the script. Can be accessed
	 * using `#if #end` conditionals in the script.
	 */
	var ?customFlags:Array<Flag>;
}
