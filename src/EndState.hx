package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import game.GameState;
import game.Player;

class EndState extends FlxState
{
	private var _winner:Int;
	private var _text:FlxText;

	public function new(winner:Int)
	{
		super();
		_winner = winner + 1;
	}

	public override function create():Void
	{
		FlxG.camera.fade(0xFF000000, 1, true, null, true);

		_text = new FlxText(0, 0, FlxG.width, "", 40);
		_text.alignment = "center";
		_text.y = FlxG.height / 2 + _text.height / 2;
		add(_text);

		if (_winner != -1) _text.text = "Player " + _winner + " wins!"
		else _text.text = "Tie game!";

		new FlxTimer().start(5, function(t:FlxTimer) { 
			FlxG.camera.fade(0xFF000000,1, false, function() { FlxG.switchState(new MenuState()); });
		}, 1);
	} 
}