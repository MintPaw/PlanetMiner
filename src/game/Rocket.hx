package game;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.effects.FlxFlicker;

class Rocket extends FlxSprite
{
	public var launching:Bool = false;
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
		if (!launching) {
			text.x = x + width / 2 - text.width / 2;
			text.y = y - text.height / 2 - 20;
		}

		super.update(elapsed);
	}

	public function updatePoints(score:Int, needed:Int):Void
	{
		if (needed - score == 0) {
			text.color = 0xFFFF0000;
			text.text = "DONE!";
		} else {
			text.color = 0xFFFFFFFF;
			text.text = Std.string(needed - score) + " left";
		}
	}

	public function launch():Void
	{
		launching = true;

		FlxTween.tween(text, { alpha: 0 }, 1);
		FlxFlicker.flicker(this, 2, .1, true);
		FlxTween.tween(this, { x: x + 3 }, .01, { type: FlxTween.PINGPONG } );
		FlxTween.tween(this, { y: y - 900 }, 5, { ease: FlxEase.quadIn, startDelay: 2 } );
	}
}