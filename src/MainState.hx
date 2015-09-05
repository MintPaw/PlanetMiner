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
		var playerDefs:Array<Dynamic> = [];
		playerDefs[0] = { type: 0, controlScheme: Player.KEYBOARD_0 };
		playerDefs[1] = { type: 1, controlScheme: Player.KEYBOARD_1 };
		playerDefs[2] = { type: 2, controlScheme: Player.CONTROLLER_0 };
		playerDefs[3] = { type: 3, controlScheme: Player.CONTROLLER_1 };

		FlxG.switchState(new GameState(playerDefs));
	} 
}