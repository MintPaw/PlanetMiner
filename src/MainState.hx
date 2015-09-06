package;

import flixel.FlxState;
import flixel.FlxG;
import game.GameState;
import game.Player;

class MainState extends FlxState
{

	public function new()
	{
		super();
	}

	public override function create():Void
	{
		FlxG.camera.antialiasing = true;

		FlxG.switchState(new MenuState());
	} 
}