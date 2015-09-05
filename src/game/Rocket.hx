package game;

import flixel.FlxSprite;
import flixel.text.FlxText;

class Rocket extends FlxSprite
{
	public var type:Int;
	public var text:FlxText;

	public function new(type:Int)
	{
		super();

		immovable = true;

		this.type = type;
		loadGraphic("assets/img/Rocket.png");

		text = new FlxText(0, 0, 200, "000", 30);
		text.alignment = FlxTextAlign.CENTER;
	}

	public override function update(elapsed:Float):Void
	{
		text.x = x + width / 2 - text.width / 2;
		text.y = y - text.height / 2 - 20;

		super.update(elapsed);
	}

	public function updatePoints(score:Int):Void
	{
		var s:String = "";
		if (Std.string(score).length == 1) s = "00" + score;
		if (Std.string(score).length == 2) s = "0" + score;
		if (Std.string(score).length == 3) s = Std.string(score);

		if (score == 100) {
			text.color = 0xFFFF0000;
			s += "!!";
		}

		text.text = s;
	}
}