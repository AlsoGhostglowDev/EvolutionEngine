package funkin.backend.macros;

#if macro
import haxe.macro.Compiler as MacroCompiler;
import haxe.macro.Context;
import haxe.macro.Expr;
#end

// InitMacrolization
class InitMacro {
    #if macro
	@:unreflective public static function initializeMacros() {
		if (Context.defined("hscript_improved_dev"))
			MacroCompiler.define("hscript-improved", "1");

		for (cls in includeClasses) {
			MacroCompiler.include(cls);
        }
    }
    #end

	public static final includeClasses:Array<String> = [];
}