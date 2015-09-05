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

		{ // Add players
			_players = new FlxTypedGroup();
			add(_players);

			var playerPush:Int = 2;
			for (i in 0..._playerDefs.length) {
				var playerDef:Dynamic = _playerDefs[i];

				var p:Player = new Player(playerDef.type, playerDef.controlScheme);

				if (i == 0) {
					p.x = Reg.TILE_SIZE * playerPush;
					p.y = Reg.TILE_SIZE * playerPush;
				} else if (i == 1) {
					p.x = Reg.TILE_SIZE * (_tilemap.widthInTiles - 1) - Reg.TILE_SIZE * playerPush;
					p.y = Reg.TILE_SIZE * playerPush;
				} else if (i == 2) {
					p.x = Reg.TILE_SIZE * (_tilemap.widthInTiles - 1) - Reg.TILE_SIZE * playerPush;
					p.y = Reg.TILE_SIZE * (_tilemap.heightInTiles - 1) - Reg.TILE_SIZE * playerPush;
				} else if (i == 3) {
					p.x = Reg.TILE_SIZE * playerPush;
					p.y = Reg.TILE_SIZE * (_tilemap.heightInTiles - 1) - Reg.TILE_SIZE * playerPush;
				}

				_players.add(p);
			}
		}
	} 
}