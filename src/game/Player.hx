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

		var colour:Int = 0xFF000000;
		if (type == 0) colour = 0xFFFF0000;
		if (type == 1) colour = 0xFF00FF00;
		if (type == 2) colour = 0xFF0000FF;
		if (type == 3) colour = 0xFFFF00FF;
		makeGraphic(16, 16, colour);
	}
}