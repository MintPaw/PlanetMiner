package game;

import flixel.FlxSprite;
import flixel.FlxG;

class Player extends FlxSprite
{
	public static var KEYBOARD_0:String = "keyboard_0";
	public static var KEYBOARD_1:String = "keyboard_1";

	public var type:Int;
	public var controlScheme:String;

	public function new(type:Int, controlScheme:String)
	{
		super();

		this.type = type;
		this.controlScheme = controlScheme;

		var colour:Int = 0xFF000000;
		if (type == 0) colour = 0xFFFF0000;
		if (type == 1) colour = 0xFF00FF00;
		if (type == 2) colour = 0xFF0000FF;
		if (type == 3) colour = 0xFFFF00FF;
		makeGraphic(16, 16, colour);

		maxVelocity.x = 200;
		maxVelocity.y = 200;

		drag.x = maxVelocity.x * 8;
		drag.y = maxVelocity.y * 8;
	}

	public override function update(elapsed:Float):Void
	{
		var up:Bool = false;
		var down:Bool = false;
		var left:Bool = false;
		var right:Bool = false;
		var shoot:Bool = false;
		var speed:Bool = false;

		if (controlScheme == KEYBOARD_0) {
			if (FlxG.keys.pressed.UP) up = true;
			if (FlxG.keys.pressed.DOWN) down = true;
			if (FlxG.keys.pressed.LEFT) left = true;
			if (FlxG.keys.pressed.RIGHT) right = true;
			if (FlxG.keys.pressed.COMMA || FlxG.keys.pressed.NUMPADONE) shoot = true;
			if (FlxG.keys.pressed.PERIOD || FlxG.keys.pressed.NUMPADTWO) speed = true;
		} else if (controlScheme == KEYBOARD_1) {
			if (FlxG.keys.pressed.W) up = true;
			if (FlxG.keys.pressed.S) down = true;
			if (FlxG.keys.pressed.A) left = true;
			if (FlxG.keys.pressed.D) right = true;
			if (FlxG.keys.pressed.F || FlxG.keys.pressed.K) shoot = true;
			if (FlxG.keys.pressed.G || FlxG.keys.pressed.L) speed = true;
		}

		acceleration.set();
		if (up) acceleration.y = -maxVelocity.y * 10;
		if (down) acceleration.y = maxVelocity.y * 10;
		if (left) acceleration.x = -maxVelocity.x * 10;
		if (right) acceleration.x = maxVelocity.x * 10;

		super.update(elapsed);
	}
}