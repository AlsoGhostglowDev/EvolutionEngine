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
		#if(haxe < "4.3.0")
		#error "This engine is built for Haxe versions 4.3.0 and higher! Recommended version is Haxe 4.3.7.";
		#end

		if (Context.defined("hscript_improved_dev"))
			MacroCompiler.define("hscript-improved", "1");

		for (cls in includeClasses) {
			MacroCompiler.include(cls);
        }

		#if desktop
		MacroCompiler.include("openal.ALSoftConfig"); //Just so it gets compiled by DCE
		#end
    }
    #end

	public static final includeClasses:Array<String> = [];
}