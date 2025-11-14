// for built-in states and substates
import flixel.FlxState;
import flixel.FlxSubState;

// commonly used classes
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.tweens.*;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSignal;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.sound.FlxSound;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

// using Std.method is too long, lol
import Std.*; //This guy.... 🥀 -TBar

// utils
using StringTools;
using flixel.util.FlxStringUtil;

// imports all the classes from the backend folder
import funkin.backend.*;
import funkin.backend.system.Paths;
import funkin.backend.system.Conductor;

// utils
import funkin.backend.utils.FunkinUtil.*;
import funkin.backend.utils.FileUtil;