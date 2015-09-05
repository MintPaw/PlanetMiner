package game;

import flixel.FlxState;
import flixel.FlxG;
import flixel.tile.FlxTilemap;

class GameState extends FlxState
{
	private var _tilemap:FlxTilemap;

	public function new()
	{
		super();
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
	} 
}