package game;

import flixel.FlxSprite;

class Rocket extends FlxSprite
{
	public var type:Int;

	public function new(type:Int)
	{
		super();

		this.type = type;
		loadGraphic("assets/img/Rocket.png");
	}
}