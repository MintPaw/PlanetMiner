package game;

import flixel.FlxSprite;

class Resource extends FlxSprite
{
	public var type:Int;

	public function new(type:Int)
	{
		super();

		this.type = type;

		if (type == 1) loadGraphic("assets/img/res/1greencrystal.png");
		if (type == 2) loadGraphic("assets/img/res/2bluecrystal.png");
		if (type == 3) loadGraphic("assets/img/res/3pinkcrystal.png");
		if (type == 4) loadGraphic("assets/img/res/4redcrystal.png");
		if (type == 5) loadGraphic("assets/img/res/5yellowcrystal.png");
	}
}