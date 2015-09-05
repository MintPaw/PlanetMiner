package game;

import flixel.FlxSprite;

class Player extends FlxSprite
{
	public static var KEYBOARD_0:String = "keyboard_0";

	public var type:Int;
	public var controlScheme:String;

	public function new()
	{
		super();
	}
}