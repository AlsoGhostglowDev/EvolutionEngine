package funkin.backend.macros;

#if macro
import haxe.macro.Context;
import haxe.macro.TypeTools;
#end

/*
 * Taken from SScript. Used for HScript wildcard imports
 */
class ClassMacro {
	#if !macro
	static final names:Map<String, Class<Dynamic>> = {
		function returnMap() {
			var r:Array<String> = build().classes;
			var map = new Map<String, Class<Dynamic>>();

			for(i in r) {
				if(i.indexOf('_Impl_') == -1) // Private class
				{
					var c = Type.resolveClass(i);
					if(c != null) map[i] = c;
				}
			}

			return map;
		}
		returnMap();
	}
	#end

	static final thisName:String = 'funkin.backend.macros.ClassMacro';
	macro static function build() {
		Context.onGenerate(function(types) {
			var names = [], self = TypeTools.getClass(Context.getType(thisName));

			for(t in types) {
				switch(t) {
					case TInst(_.get() => c, _):
						var name:Array<String> = c.pack.copy();
						name.push(c.name);
						names.push(Context.makeExpr(name.join("."), c.pos));
					default:
				}
            }

			self.meta.remove('classes');
			self.meta.add('classes', names, self.pos);
		});
		return macro cast haxe.rtti.Meta.getType($p{thisName.split('.')});
	}
}