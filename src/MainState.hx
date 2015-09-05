package;

import flixel.FlxState;
import flixel.FlxG;
import game.GameState;

class MainState extends FlxState
{

	public function new()
	{
		super();
	}

	public override function create():Void
	{
		FlxG.switchState(new GameState());
	} 
}