package funkin.backend.utils;

import lime.app.Application;
import lime.ui.WindowAttributes;
import lime.ui.Window;

#if hl
import hl.UI;
import haxe.EnumFlags;
#end

@:publicFields class WindowUtil 
{
	/*
	 * This is because hashlink has this weird issue with base window.alert that
	 * messes up the text.
	 */
	static inline function alert(title:String, body:String) {
		#if !hl
		FlxG.stage.window.alert(body, title);
		#else
		UI.dialog(title, body, new EnumFlags<DialogFlags>());
		#end
	}

	/*
	 * Window Creation support for HScript
	 */
	static inline function createWindow(x:Int = 0, y:Int = 0, width:Int, height:Int, title:String, extraParams:Dynamic):lime.ui.Window {
		var params:WindowAttributes = {
			x: x, 
			y: y, 
			width: width, 
			height: height, 
			title: title
		};

		for (field in Reflect.fields(extraParams))
			Reflect.setField(params, field, Reflect.field(extraParams, field));

		return Application.current.createWindow(params);		
	}
}