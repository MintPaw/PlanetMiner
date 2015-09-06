package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import game.GameState;
import game.Player;

class EndState extends FlxState
{
	private var _winner:Player;
	private var _text:FlxText;

	public function new(winner:Player)
	{
		_winner = winner;
		super();
	}

	public override function create():Void
	{
		FlxG.camera.fade(0xFF000000, 1, true, null, true);

		_text = new FlxText(0, 0, FlxG.width, "Player " + Std.string(winner.type + 1) + " wins!", 40);
		_text.y = FlxG.height / 2 + _text.height / 2;
		add(_text);

		new FlxTimer().start(5, function(){ FlxG.switchState(new MenuState()); }, 1);
	} 
}