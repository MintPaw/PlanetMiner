package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.input.gamepad.FlxGamepad;
import game.GameState;
import game.Player;

class MenuState extends FlxState
{
	private var _title:FlxText;
	private var _subtitle:FlxText;
	private var _joinTiles:Array<FlxSprite> = [];
	private var _infoTexts:Array<FlxText> = [];

	private var _playerDefs:Array<Dynamic> = [];

	public function new()
	{
		super();
	}

	public override function create():Void
	{
		_joinTiles = [];
		_infoTexts = [];

		_title = new FlxText(0, 0, FlxG.width, "GAME", 8 * 4);
		_title.alignment = "center";
		_title.y = FlxG.height / 3;
		add(_title);

		_subtitle = new FlxText(0, 0, FlxG.width, "Subtitle", 8 * 2);
		_subtitle.alignment = "center";
		_subtitle.y = _title.y + _title.height + 20;
		add(_subtitle);

		for (i in 0...4) {
			// var j:FlxSprite
		}

		// var playerDefs:Array<Dynamic> = [];
		// playerDefs[0] = { type: 0, controlScheme: Player.KEYBOARD_0 };
		// playerDefs[1] = { type: 1, controlScheme: Player.KEYBOARD_1 };
		// playerDefs[2] = { type: 2, controlScheme: Player.CONTROLLER_0 };
		// playerDefs[3] = { type: 3, controlScheme: Player.CONTROLLER_1 };

		// FlxG.switchState(new GameState(playerDefs));
	}

	public override function update(elapsed:Float):Void
	{
		{ // Input
			if (FlxG.keys.justPressed.UP) addPlayer(game.Player.KEYBOARD_0);
			if (FlxG.keys.justPressed.W) addPlayer(game.Player.KEYBOARD_1);

			for (padNumber in 0...99)
			{
				var pad:FlxGamepad = FlxG.gamepads.getByID(padNumber);
				if (pad == null) continue;

				// if (pad.justPressed(XboxButtonID.A)) addPlayer("controller_" + padNumber);
			}
		}
	}

	public function addPlayer(controlScheme:String):Void
	{
		_playerDefs.push( { type: _playerDefs.length } );
	}
}