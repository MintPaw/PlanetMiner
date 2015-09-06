package ;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxTimer;

class TutorialState extends FlxState
{
	private var _tut:FlxSprite;
	private var _tutNum:Int;
	private var _playerDefs:Array<Dynamic>;

	public function new(pd:Array<Dynamic>)
	{
		super();
		_playerDefs = pd;
	}

	public override function create():Void
	{
		_tut = new FlxSprite();
		add(_tut);

		_tutNum = -1;
		next();
	}

	private function next():Void
	{

		_tutNum++;

		if (_tutNum == 2) {
			FlxG.camera.fade(0xFF000000, .5, false, null, true);
			new FlxTimer().start(1, function(t:FlxTimer) { FlxG.switchState(new game.GameState(_playerDefs)); });
			return;
		}

		FlxG.camera.fade(0xFF000000, .5, true, null, true);
		_tut.loadGraphic("assets/img/tut/" + _tutNum + ".png");

		new FlxTimer().start(8, function(t:FlxTimer) { FlxG.camera.fade(0xFF000000, .5, false); });
		new FlxTimer().start(8.5, function(t:FlxTimer) { next(); });
	}

}