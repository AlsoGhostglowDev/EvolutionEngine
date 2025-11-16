package funkin.backend.interfaces;

interface IScriptable {
    public function call(f:String, ?args:Array<Dynamic>):Void;
    public function set(p:String, v:Dynamic):Void;
}