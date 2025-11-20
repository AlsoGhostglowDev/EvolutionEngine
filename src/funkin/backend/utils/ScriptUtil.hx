package funkin.backend.utils;

#if HSCRIPT_ALLOWED
import funkin.backend.scripting.HScript;
import hscript.Tools as HScriptTools;
import funkin.backend.macros.ClassMacro;
#end

@:publicFields class ScriptUtil {

	/* 
     * HScript stuff
     */
	@:noUsing static inline function resolveAbstract(abs:String):Null<Dynamic> {
		return Type.resolveClass('${abs}_HSC');
	}

	// Not normally used, but a fun tool to have
	@:noUsing static inline function resolveExtendClass(ext:String):Null<Dynamic> {
		return Type.resolveClass('${ext}_HSX');
	}

	static function getClassName(clsStr:String):String {
		if (StringTools.endsWith(clsStr, "_HSX") || StringTools.endsWith(clsStr, "_HSC"))
			clsStr = clsStr.substring(0, clsStr.length - 4);

		var retVal:Array<String> = clsStr.split(".");
		return retVal[retVal.length - 1];
	}

	static function importResolve(clsName:String, ?checkForAbstract:Null<Bool> = false):Null<Dynamic> {
		var cls = Type.resolveClass(clsName);
		var enm = Type.resolveEnum(clsName);
		if(checkForAbstract && cls == null) cls = Type.resolveClass('${clsName}_HSC');

		return (cls != null ? cls : enm);
	}

    /*
     * Does a wildcard import from a map of all the created classes in the build.
     * (For HScript use)
     * This may be a bit performance expensive, so please refrain from using this if it's not needed.
     */
	static inline function wildcardImport(packageName:String):Array<String> {
		var retVal:Array<String> = [];
        #if HSCRIPT_ALLOWED
		@:privateAccess
        var clsFilesys:Map<String, Class<Dynamic>> = ClassMacro.names;
		var packagePath = packageName.substr(0, packageName.indexOf(".*")) + ".";

		for (item in clsFilesys.keys())
		{
			// Checks whether the class is in the same folder and is not in a subfolder
			if (StringTools.startsWith(item, packagePath) && HScriptTools.isUppercase(StringTools.replace(item, packagePath, ""))) {
				retVal.push(item);
			}
		}
        #end

		return retVal;
	}
}