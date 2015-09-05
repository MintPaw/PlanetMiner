package game;

import flixel.text.FlxText;

class DText extends FlxText
{

	public function new(fieldWidth:Float, text:String, size:Int)
	{
		super(0, 0, fieldWidth, text, size);
	}

	public override function update(elapsed:Float):Void
	{
		if (alpha == 0) kill();
		super.update(elapsed);
	}
}