package game;

import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.input.FlxInput;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.util.FlxTimer;
import flixel.ui.FlxBar;

class Player extends FlxSprite
{
	private static var ENERGY_GAIN_RATE:Float = 0.1;
	private static var BASE_SPEED:Float = 200;

	public static var KEYBOARD_0:String = "keyboard_0";
	public static var KEYBOARD_1:String = "keyboard_1";

	public var controlScheme:String;
	public var bar:FlxBar;
	public var runEmitter:FlxEmitter;
	public var rocketRef:Rocket;

	public var type:Int = 0;
	public var energy:Float = Reg.debug ? 100 : 0;

	public var neededScore:Int;
	public var score:Int = Reg.debug ? 0 : 0;

	public var canHitBlock:Bool = true;
	public var timeRunning:Float = 0;
	public var speedMult:Int = 1;
	public var stunned:Float = 0;
	public var inv:Float = 0;
	public var escaped:Bool = false;


	public function new(type:Int, controlScheme:String)
	{
		super();

		this.type = type;
		this.controlScheme = controlScheme;

		frames = FlxAtlasFrames.fromTexturePackerJson("assets/img/player.png", "assets/img/player.json");
		animation.addByPrefix("idle", "stand", 0, false);
		animation.addByPrefix("moveRight", "walkright", 8, false);
		animation.addByPrefix("moveUp", "walkforward", 8, false);
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
		setFacingFlip(FlxObject.UP, true, false);
		setFacingFlip(FlxObject.DOWN, false, false);

		runEmitter = new FlxEmitter(0, 0);
		runEmitter.makeParticles(2, 2, 0xFFFF0000, 500);

		var barFillColour:Int = 0xFF000000;

		if (type == 0) {
			barFillColour = 0xFF660000;
		}
		if (type == 1) {
			barFillColour = 0xFF006600;
		}
		if (type == 2)  {
			barFillColour = 0xFF000066;
		}
		if (type == 3) {
			barFillColour = 0xFF660066;
		}

		drag.x = maxVelocity.x * 8;
		drag.y = maxVelocity.y * 8;

		bar = new FlxBar(0, 0, FlxBarFillDirection.LEFT_TO_RIGHT, Std.int(width * 2), 6, null, null, 0, 100);
		bar.createFilledBar(0xFF222222, barFillColour, true, 1);
	}

	public override function update(elapsed:Float):Void
	{
		runEmitter.x = x + width / 2;
		runEmitter.y = y + height;

		var up:Bool = false;
		var down:Bool = false;
		var left:Bool = false;
		var right:Bool = false;
		var speed:Bool = false;

		if (stunned <= 0) { // Update input
			if (controlScheme == KEYBOARD_0) {
				if (FlxG.keys.pressed.UP) up = true;
				if (FlxG.keys.pressed.DOWN) down = true;
				if (FlxG.keys.pressed.LEFT) left = true;
				if (FlxG.keys.pressed.RIGHT) right = true;
				if (FlxG.keys.pressed.M || FlxG.keys.pressed.NUMPADONE) speed = true;
			} else if (controlScheme == KEYBOARD_1) {
				if (FlxG.keys.pressed.W) up = true;
				if (FlxG.keys.pressed.S) down = true;
				if (FlxG.keys.pressed.A) left = true;
				if (FlxG.keys.pressed.D) right = true;
				if (FlxG.keys.pressed.F || FlxG.keys.pressed.K) speed = true;
			} else {
				var pad:FlxGamepad = FlxG.gamepads.getByID(Std.parseInt(controlScheme.charAt(controlScheme.length - 1)));

				if (pad != null && pad.connected) {
					if (pad.getXAxis(FlxGamepadInputID.LEFT_ANALOG_STICK) < -.50) left = true; 
					if (pad.getXAxis(FlxGamepadInputID.LEFT_ANALOG_STICK) > .50) right = true; 
					if (pad.getYAxis(FlxGamepadInputID.LEFT_ANALOG_STICK) < -.50) up = true; 
					if (pad.getYAxis(FlxGamepadInputID.LEFT_ANALOG_STICK) > .50) down = true; 
					// if (pad.getXAxis(FlxGamepadInputID.LEFT_ANALOG_STICK) < -.50 || pad.checkStatus(FlxGamepadInputID.DPAD_LEFT, FlxInputState.PRESSED)) left = true; 
					// if (pad.getXAxis(FlxGamepadInputID.LEFT_ANALOG_STICK) > .50 || pad.checkStatus(FlxGamepadInputID.DPAD_RIGHT, FlxInputState.PRESSED)) right = true; 
					// if (pad.getYAxis(FlxGamepadInputID.LEFT_ANALOG_STICK) < -.50 || pad.checkStatus(FlxGamepadInputID.DPAD_UP, FlxInputState.PRESSED)) up = true; 
					// if (pad.getYAxis(FlxGamepadInputID.LEFT_ANALOG_STICK) > .50 || pad.checkStatus(FlxGamepadInputID.DPAD_DOWN, FlxInputState.PRESSED)) down = true; 
					if (pad.pressed.A) speed = true;
				}
			}
		} else {
			stunned -= elapsed;
		}

		{ // Update energy
			if (speed && energy >= 5) {
				energy -= 100/60/4; // total/fps/maxRunTime
				timeRunning += elapsed;
			} else timeRunning = 0;

			if (energy < 100) energy += ENERGY_GAIN_RATE;
			if (energy > 100) energy = 100;

			if (timeRunning == 0) speedMult = 1;
			if (timeRunning > 1) speedMult = 2;
			if (timeRunning > 2) speedMult = 3;
			if (timeRunning > 3) speedMult = 4;

			if (timeRunning > 0 && !runEmitter.emitting) runEmitter.start(false, 1, 999);
			runEmitter.frequency = 1 / (speedMult * 10);
			if (timeRunning == 0 && runEmitter.emitting) runEmitter.emitting = false;
		}

		{ // Update movement
			maxVelocity.set(BASE_SPEED * speedMult, BASE_SPEED * speedMult);

			acceleration.set();
			if (up) acceleration.y += -maxVelocity.y * 10;
			if (down) acceleration.y += maxVelocity.y * 10;
			if (left) acceleration.x += -maxVelocity.x * 10;
			if (right) acceleration.x += maxVelocity.x * 10;
		}

		{ // Update animation
			if (left) facing = FlxObject.LEFT;
			if (right) facing = FlxObject.RIGHT;
			if (up) facing = FlxObject.UP;
			if (down) facing = FlxObject.DOWN;

			if (left || right) animation.play("moveRight")
			else if (up || down) animation.play("moveUp")
			else animation.play("idle");
		}

		super.update(elapsed);

		{ // Update misc (post update)
			bar.x = x + width / 2 - bar.width / 2;
			bar.y = y + height + bar.height / 2;
			bar.value = energy;
		}
	}

	public function addPoints(points:Int):Void
	{
		score += points;
		rocketRef.updatePoints(score, neededScore);
	}

	public override function kill():Void
	{
		bar.kill();
		super.kill();
	}
}