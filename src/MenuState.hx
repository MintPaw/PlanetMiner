package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import game.GameState;
import game.Player;

class MenuState extends FlxState
{
	private var _title:FlxText;
	private var _subtitle:FlxText;
	private var _joinTiles:Array<FlxSprite> = [];
	private var _infoTexts:Array<FlxText> = [];
	private var _timerText:FlxText;

	private var _playerDefs:Array<Dynamic> = [];

	private var _timeLeft:Float = -1;

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
		_title.y = 100;
		add(_title);

		_subtitle = new FlxText(0, 0, FlxG.width, "Subtitle", 8 * 2);
		_subtitle.alignment = "center";
		_subtitle.y = _title.y + _title.height + 20;
		add(_subtitle);

		_timerText = new FlxText(0, 0, FlxG.width, "", 20);
		_timerText.y = FlxG.height / 2 + _timerText.height / 2;
		_timerText.alignment = "center";
		add(_timerText);

		for (i in 0...4) {
			var j:FlxSprite = new FlxSprite();
			j.loadGraphic("assets/img/menu/menu.png");
			add(j);
			_joinTiles.push(j);
		}

		var padding:Int = 200;
		
		_joinTiles[0].x = 0;
		_joinTiles[0].y = 0;
		
		_joinTiles[1].x = _joinTiles[0].x + _joinTiles[0].width + padding;
		_joinTiles[1].y = 0;

		_joinTiles[2].x = 0;
		_joinTiles[2].y = _joinTiles[0].y + _joinTiles[0].height + padding;

		_joinTiles[3].x = _joinTiles[0].x + _joinTiles[0].width + padding;
		_joinTiles[3].y = _joinTiles[0].y + _joinTiles[0].height + padding;

		var totalWidth:Float = _joinTiles[1].x + _joinTiles[1].width - _joinTiles[0].x;
		var totalHeight:Float = _joinTiles[1].y + _joinTiles[1].height - _joinTiles[0].y;

		for (tile in _joinTiles) {
			tile.x += (FlxG.width - totalWidth) / 2;
			tile.y += (FlxG.height - totalHeight) / 2 - 100;

			var info:FlxText = new FlxText(0, 0, tile.width * 1.5, "Test", 20);
			info.alignment = "center";
			info.x = tile.x - (info.width - tile.width) / 2;
			info.y = tile.y;
			info.alpha = 0;
			add(info);
			_infoTexts.push(info);
		}
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

				if (pad.justPressed.A) addPlayer("controller_" + padNumber);
			}
		}

		if (_timeLeft > -1) {
			_timerText.text = "Time left: " + Math.round(_timeLeft * 10) / 10;
			if (_timeLeft > 0) _timeLeft -= elapsed;
			if (_timeLeft <= 0) {
				FlxG.camera.fade(0xFF000000, Reg.debug ? .5 : 3, false, function():Void { FlxG.switchState(new game.GameState(_playerDefs)); });
				_timeLeft = 0;
			}
		}
		_timerText.visible = _timeLeft != -1;
	}

	public function addPlayer(controlScheme:String):Void
	{
		if (_playerDefs.length >= 4 || (_timeLeft <= 0 && _timeLeft > -1)) return;
		for (def in _playerDefs) if (controlScheme == def.controlScheme) return;

		FlxTween.tween(_joinTiles[_playerDefs.length], { alpha: 0 }, 1);
		FlxTween.tween(_infoTexts[_playerDefs.length], { alpha: 1 }, 1, { startDelay: 0.5 } );

		if (controlScheme == game.Player.KEYBOARD_0) {
			_infoTexts[_playerDefs.length].text = "Player " + Std.string(_playerDefs.length + 1) + "\n-Controls-\nMovement: Arrows\nSpeed boost: M or 1(numpad)";
		} else if (controlScheme == game.Player.KEYBOARD_1) {
			_infoTexts[_playerDefs.length].text = "Player " + Std.string(_playerDefs.length + 1) + "\n-Controls-\nMovement: WSAD\nSpeed boost: F or K";
		} else {
			_infoTexts[_playerDefs.length].text = "Player " + Std.string(_playerDefs.length + 1) + "\n-Controls-\nMovement: Left stick\nSpeed boost: A or LeftTrigger";
		}

		_playerDefs.push( { type: _playerDefs.length, controlScheme: controlScheme } );

		if (_playerDefs.length >= 2) _timeLeft = Reg.debug ? 1 : 10;
	}
}