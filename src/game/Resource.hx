package game;

import flixel.FlxSprite;

class Resource extends FlxSprite
{
	public var type:Int;

	public function new(type:Int)
	{
		super();

		this.type = type;

		var colour:Int = 0xFF000000;
		if (type == 1) colour = 0xFFFF0000;
		if (type == 2) colour = 0xFF00FF00;
		if (type == 3) colour = 0xFF0000FF;
		if (type == 4) colour = 0xFFFF00FF;
		if (type == 5) colour = 0xFF00FFFF;

		makeGraphic(8, 8, colour);
	}
}