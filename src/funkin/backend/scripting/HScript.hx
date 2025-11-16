package funkin.backend.scripting;

import funkin.backend.macros.Compiler;
#if HSCRIPT_ALLOWED
import hscript.Expr.Error as HScriptError;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser as HScriptParser; // To not confuse with the funkin parser
#end

class HScript extends Script {
	#if HSCRIPT_ALLOWED
	public static var staticVariables:Map<String, Dynamic> = [];

	// Add pre-imported classes here
	public static var defaultClasses:Map<String, Dynamic> = [
		//Basic types
		"Int" => Int, "Float" => Float,
		"String" => String, "Bool" => Bool,
		"StringMap" => haxe.ds.StringMap, "IntMap" => haxe.ds.IntMap,
		"Map" => resolveAbstract("haxe.ds.Map"),

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

		"FlxAxes" => resolveAbstract("flixel.util.FlxAxes"),
		"FlxColor" => resolveAbstract("flixel.util.FlxColor")
	];

	public var parser:HScriptParser;
	public var interp:Interp;
	public var expr:Expr;

	public var path:String;

	public var options:HScriptOptions;

	override public function new(path:String, ?options:HScriptOptions) {
		super();

		this.options = options;
		this.path = path;
		if(parser == null) initParser();
		if(interp == null) initInterp();

		try
		{
			parser.line = 1; // Reset the parser position.
			expr = parser.parseString(FileUtil.getContent(path), path);

			interp.variables.set("this", this);
			for (tag => value in defaultClasses) {
				interp.variables.set(tag, value);
			}

			if (options.parent != null) this.setParent(options.parent);

			interp.execute(expr);
			call("new");
		} catch(e) {
			if (options.ignoreErrors != null && !options.ignoreErrors)
				FlxG.stage.window.alert('Error on haxe script "${this.path}".\n${e.toString()}', 'HScript Error!');
		}
	}

	public inline function initParser() {
		parser = new HScriptParser();
		parser.allowJSON = parser.allowMetadata = parser.allowTypes = parser.allowRegex = true;

		parser.preprocessorValues = Compiler.defines;
		for(name => value in Compiler.custom_defines) {
			parser.preprocessorValues.set(name, value);
		}
	}

	public inline function initInterp() {
		interp = new Interp();
		interp.allowStaticVariables = interp.allowPublicVariables = true;
		interp.staticVariables = HScript.staticVariables;

		interp.errorHandler = onError;
		interp.warnHandler = onWarn;
	}

	public function onError(e:HScriptError) {
		trace(errorToString(e), 0xFFFF0000);
	}

	public function onWarn(e:HScriptError) {
		trace("[WARNING] " + errorToString(e), 0xFFC9C900);
	}

	public inline function setParent(newParent:Dynamic):Null<Dynamic> {
		if(interp == null) return null;

		interp.scriptObject = newParent;
		if (newParent.variables != null) interp.publicVariables = newParent.variables;
		return this;
	}

	public function destroy() {
		expr = null;
		interp = null;
		parser = null;
	}

	override public function get(name:String):Dynamic {
		return (interp != null ? interp.variables.get(name) : null);
	}

	override public function set(variable:String, data:Dynamic) {
		if (interp != null) interp.variables.set(variable, data);
	}

	override public function call(func:String, ?args:Array<Dynamic>):Dynamic {
		if (interp == null) return null;

		var functionVar = interp.variables.get(func);
		if (functionVar == null || !Reflect.isFunction(functionVar)) return null;
		return (args != null && args.length > 0) ? Reflect.callMethod(null, functionVar, args) : functionVar();
	}

	public static function errorToString(e:HScriptError):String {
		var message = switch (#if hscriptPos e.e #else e #end) {
			case EInvalidChar(c): "Invalid character: '"
				+ (StringTools.isEof(c) ? "EOF (End Of File)" : String.fromCharCode(c))
				+ "' (" + c + ")";
			case EUnexpected(s): "Unexpected token: \"" + s + "\"";
			case EUnterminatedString: "Unterminated string";
			case EUnterminatedComment: "Unterminated comment";
			case EInvalidPreprocessor(str): "Invalid preprocessor (" + str + ")";
			case EUnknownVariable(v): "Unknown variable: " + v;
			case EInvalidIterator(v): "Invalid iterator: " + v;
			case EInvalidOp(op): "Invalid operator: " + op;
			case EInvalidAccess(f): "Invalid access to field " + f;
			case ECustom(msg): msg;
			case EInvalidClass(cla): "Invalid class: " + cla + " was not found.";
			case EAlreadyExistingClass(cla): 'Custom Class named $cla already exists.';
			default: Std.string(#if hscriptPos e.e #else e #end);
		};
		#if hscriptPos
		return e.origin + ":" + e.line + ": " + message;
		#else
		return message;
		#end
	}
	#end
}

typedef HScriptOptions =
{
	@:optional var isString:Bool;
	@:optional var parent:Dynamic;
	@:optional var ignoreErrors:Bool;
}
