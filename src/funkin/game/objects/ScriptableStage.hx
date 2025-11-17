package funkin.game.objects;

#if HSCRIPT_ALLOWED
import funkin.backend.scripting.HScript;
#end

class ScriptableStage extends Stage implements IScriptable {
    #if HSCRIPT_ALLOWED
    public var hscript:HScript;
    #else
    public var hscript:Dynamic;
    #end

    public function new(path:String) {
        #if HSCRIPT_ALLOWED
        hscript = new HScript(path);
        #end
    }

    public function call(func:String, ?args:Array<Dynamic>) {
        #if HSCRIPT_ALLOWED
        hscript.call(func, args ?? []);
        #end
    }

    public function set(field:String, value:Dynamic) {
        #if HSCRIPT_ALLOWED
        hscript.set(field, value);
        #end
    }
}