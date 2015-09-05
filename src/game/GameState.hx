package game;

import flixel.FlxState;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tile.FlxTilemap;

class GameState extends FlxState
{
	private var _players:FlxTypedGroup<Player>;
	private var _playerDefs:Array<Dynamic>;
	private var _tilemap:FlxTilemap;

	public function new(playerDefs:Array<Dynamic>)
	{
		super();

		_playerDefs = playerDefs;
	}

	public override function create():Void
	{
		{ // Add players
			_players = new FlxTypedGroup();
			add(_players);

			for (playerDef in _playerDefs) {
				var p:Player = new Player();
				p.type = playerDef.type;
				p.controlScheme = playerDef.type;
				_players.add(p);
			}
		}

		{ // Setup tilemap
			_tilemap = new FlxTilemap();

			var startMap:String = "";
			var cols:Int = 80;
			var rows:Int = 45;

			for (row in 0...rows) {
				for (col in 0...cols) {
					startMap += "1";
					if (col != cols-1) startMap += ",";
				}
				if (row != rows-1) startMap += "\n";
			}

			_tilemap.loadMapFromCSV(startMap, "assets/img/tiles.png", 16, 16);
			add(_tilemap);
		}
	} 
}