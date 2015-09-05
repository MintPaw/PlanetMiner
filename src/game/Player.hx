package game;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.ui.FlxBar;

class Player extends FlxSprite
{
	private static var ENERGY_GAIN_RATE:Float = 0.1;
	private static var BASE_SPEED:Float = 200;

	public static var KEYBOARD_0:String = "keyboard_0";
	public static var KEYBOARD_1:String = "keyboard_1";

	public var type:Int;
	public var energy:Float = 0;
	public var controlScheme:String;
	public var canHitBlock:Bool = true;
	public var score:Int = 0;
	public var bar:FlxBar;
	public var timeRunning:Float = 0;

	public function new(type:Int, controlScheme:String)
	{
		super();

		this.type = type;
		this.controlScheme = controlScheme;

		var colour:Int = 0xFF000000;
		var barFillColour:Int = 0xFF000000;

		if (type == 0) {
			colour = 0xFFFF0000;
			barFillColour = 0xFF660000;
		}
		if (type == 1) {
			colour = 0xFF00FF00;
			barFillColour = 0xFF006600;
		}
		if (type == 2)  {
			colour = 0xFF0000FF;
			barFillColour = 0xFF000066;
		}
		if (type == 3) {
			colour = 0xFFFF00FF;
			barFillColour = 0xFF660066;
		}
		makeGraphic(16, 16, colour);

		drag.x = maxVelocity.x * 8;
		drag.y = maxVelocity.y * 8;

		bar = new FlxBar(0, 0, FlxBarFillDirection.LEFT_TO_RIGHT, Std.int(width * 2), 6, null, null, 0, 100);
		bar.createFilledBar(0xFF222222, barFillColour, true, 1);
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

		if (speed && energy >= 5) {
			energy -= 100/60/4; // total/fps/maxRunTime
			timeRunning += elapsed;
		} else timeRunning = 0;

		maxVelocity.set(BASE_SPEED, BASE_SPEED);

		acceleration.set();
		if (up) acceleration.y = -maxVelocity.y * 10;
		if (down) acceleration.y = maxVelocity.y * 10;
		if (left) acceleration.x = -maxVelocity.x * 10;
		if (right) acceleration.x = maxVelocity.x * 10;

		if (energy < 100) energy += ENERGY_GAIN_RATE;
		if (energy > 100) energy = 100;

		super.update(elapsed);

		bar.x = x + width / 2 - bar.width / 2;
		bar.y = y + height + bar.height / 2;
		bar.value = energy;
	}
}