package game;

import flixel.FlxState;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.tile.FlxTile;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import game.MapGenerator;

class GameState extends FlxState
{
	public static var DIRT:Int = 1;

	private var _players:FlxTypedGroup<Player>;
	private var _resources:FlxTypedGroup<Resource>;
	private var _playerDefs:Array<Dynamic>;
	private var _tilemap:FlxTilemap;
	private var _blockDurability:Array<Array<Float>>;

	public function new(playerDefs:Array<Dynamic>)
	{
		super();

		_playerDefs = playerDefs;
	}

	public override function create():Void
	{
		{ // Setup tilemap
			_tilemap = new FlxTilemap();

			var cols:Int = 80;
			var rows:Int = 45;
			var startMap:Array<Array<Int>> = Map.gen(cols, rows, 2, 9, 7);

			for (i in 0...startMap.length)
				for (j in 0...startMap[i].length)
					if (startMap[i][j] > 5) startMap[i][j] = 5;

			_tilemap.loadMapFrom2DArray(startMap, "assets/img/tiles.png", 16, 16);
			_tilemap.setTileProperties(1, FlxObject.ANY, playerVTile, null, 5);
			add(_tilemap);

			_blockDurability = [];
			for (i in 0...startMap.length) {
				_blockDurability[i] = [];
				for (j in 0...startMap[i].length)
					_blockDurability[i][j] = startMap[i][j] * 10;
			}
		}

		{ // Setup resources
			_resources = new FlxTypedGroup();
			add(_resources);
		}

		{ // Setup players
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

				breakBlock(p, p.x, p.y, false);

				_players.add(p);
				add(p.bar);
			}
		}
	}

	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		for (p in _players.members) p.canHitBlock = true;

		FlxG.collide(_players, _tilemap);
		FlxG.overlap(_players, _resources, playerVResource);
	}

	private function playerVTile(b1:FlxBasic, b2:FlxBasic):Void
	{
		var player:Player = cast(Std.is(b1, Player) ? b1 : b2, Player);
		var tile:FlxTile = cast(Std.is(b1, FlxTile) ? b1 : b2, FlxTile);

		if (!player.canHitBlock) return;
		player.canHitBlock = false;

		hitBlock(player, tile.x, tile.y, false);
	}

	private function playerVResource(b1:FlxBasic, b2:FlxBasic):Void
	{
		var player:Player = cast(Std.is(b1, Player) ? b1 : b2, Player);
		var res:Resource = cast(Std.is(b1, Resource) ? b1 : b2, Resource);

		var t:DText = new DText(100, "+" + res.type, 12);
		t.alignment = FlxTextAlign.CENTER;
		t.x = player.x + player.width / 2 - t.width / 2 + Math.random() * 40 - 20;
		t.y = player.y + player.height / 2 - t.height / 2;
		add(t);

		FlxTween.tween(t, { y: t.y + 20 + Math.random()*10 }, .5, { ease: FlxEase.circOut });
		FlxTween.tween(t, { alpha: 0 }, .5, { startDelay: 1 });

		player.score += res.type;
		res.kill();
	}

	private function hitBlock(player:Player, xpos:Float, ypos:Float, isTile:Bool=true):Void
	{
		var tileX:Int = Std.int(isTile ? xpos : xpos / Reg.TILE_SIZE);
		var tileY:Int = Std.int(isTile ? ypos : ypos / Reg.TILE_SIZE);

		_blockDurability[tileY][tileX] -= player.speedMult;
		if (_blockDurability[tileY][tileX] <= 0) breakBlock(player, tileX, tileY, true);
	}

	public function breakBlock(player:Player, xpos:Float, ypos:Float, isTile:Bool=true):Void
	{
		var tileX:Int = Std.int(isTile ? xpos : xpos / Reg.TILE_SIZE);
		var tileY:Int = Std.int(isTile ? ypos : ypos / Reg.TILE_SIZE);
		var block:Int = _tilemap.getTile(tileX, tileY);

		if (block > DIRT) {
			var r:Resource = new Resource(block - DIRT);
			r.x = tileX * Reg.TILE_SIZE + r.width / 2;
			r.y = tileY * Reg.TILE_SIZE + r.height / 2;
			_resources.add(r);
		}


		_tilemap.setTile(tileX, tileY, 0, true);
	}
}