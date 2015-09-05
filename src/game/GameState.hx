package game;

import flixel.FlxState;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.tile.FlxTile;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import game.MapGenerator;

class GameState extends FlxState
{
	public static var DIRT:Int = 1;

	private var _playerDefs:Array<Dynamic>;
	private var _backTilemap:FlxTilemap;
	private var _starTilemap:FlxTilemap;
	private var _tilemap:FlxTilemap;
	private var _blockDurability:Array<Array<Float>>;

	private var _players:FlxTypedGroup<Player>;
	private var _rockets:FlxTypedGroup<Rocket>;
	private var _resources:FlxTypedGroup<Resource>;	

	private var _tilesToDestroy:Array<Array<Int>> = [];
	private var _timeTillNextDestroy:Float = 0;
	private var _ending:Bool = false;

	private var _rnd:FlxRandom;

	public function new(playerDefs:Array<Dynamic>)
	{
		super();

		_playerDefs = playerDefs;
	}

	public override function create():Void
	{
		{ // Setup misc
			_rnd = new FlxRandom();
		}

		{ // Setup tilemap
			_tilemap = new FlxTilemap();
			_backTilemap = new FlxTilemap();
			_starTilemap = new FlxTilemap();

			var cols:Int = 80;
			var rows:Int = 45;
			var startMap:Array<Array<Int>> = Map.gen(cols, rows, 2, 9, 7);

			for (i in 0...startMap.length)
				for (j in 0...startMap[i].length)
					if (startMap[i][j] > 5) startMap[i][j] = 5;

			_starTilemap.loadMapFrom2DArray(startMap, "assets/img/tiles.png", 16, 16);
			add(_starTilemap);
			for (i in 0..._starTilemap.totalTiles) _starTilemap.setTileByIndex(i, _rnd.getObject([8, 9, 10, 11], [1, 1, 1, 10]));

			_backTilemap.loadMapFrom2DArray(startMap, "assets/img/tiles.png", 16, 16);
			add(_backTilemap);
			for (i in 0..._backTilemap.totalTiles) _backTilemap.setTileByIndex(i, 7);

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

		{ // Setup rockets
			_rockets = new FlxTypedGroup();
			add(_rockets);

			for (p in _players)
			{
				var r:Rocket = new Rocket(p.type);
				r.x = p.x + p.width / 2 - r.width / 2;
				r.y = p.y + 5 * (p.y / Reg.TILE_SIZE < _tilemap.heightInTiles / 2 ? Reg.TILE_SIZE : -Reg.TILE_SIZE);

				add(r.text);
				_rockets.add(r);
				p.rocketRef = r;
			}
		}
	}

	public override function update(elapsed:Float):Void
	{
		{ // Update destruction
			if (_tilesToDestroy.length >= 1) {
				if (_timeTillNextDestroy <= 0) {
					_timeTillNextDestroy = .01;
					var tileToDest:Array<Int> = _tilesToDestroy.shift();

					if (tileToDest[0] == -1 && tileToDest[1] == -1) _tilesToDestroy = [];

					if (tileToDest[0] >= 0 &&
					    tileToDest[1] >= 0 &&
					    tileToDest[0] < _tilemap.widthInTiles &&
					    tileToDest[1] < _tilemap.heightInTiles) _tilemap.setTile(tileToDest[0], tileToDest[1], 0);

				} else _timeTillNextDestroy -= elapsed;
			}
		}

		{ // Update misc
			for (p in _players.members) p.canHitBlock = true;
		}

		{ // Update winning
			if (_players.countLiving() == 0 && !_ending) {
				_ending = true;
				for (res in _resources.members) FlxTween.tween(res, { alpha: 0 }, .5);
				FlxTween.tween(_tilemap, { y: _tilemap.height, alpha: 25 }, 4, { ease: null });
				FlxTween.tween(_backTilemap, { y: _backTilemap.height, alpha: 25 }, 4, { ease: null });

				var newDefs:Array<Dynamic> = [];
				for (p in _players) if (p.escaped) for (pd in _playerDefs) if (pd.type == p.type) newDefs.push(pd);

				new FlxTimer().start(5, function(t:FlxTimer) { FlxG.switchState(new GameState(newDefs)); } , 1);
			}
		}

		super.update(elapsed);

		{ // Update collision
			FlxG.collide(_players, _tilemap);
			FlxG.collide(_players, _rockets, playerVRocket);
			FlxG.overlap(_players, _resources, playerVResource);
		}
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

		if (player.score >= 100) return;

		var t:DText = new DText(100, "+" + res.type, 12);
		t.alignment = FlxTextAlign.CENTER;
		t.x = player.x + player.width / 2 - t.width / 2 + Math.random() * 40 - 20;
		t.y = player.y + player.height / 2 - t.height / 2;
		add(t);

		FlxTween.tween(t, { y: t.y + 20 + Math.random()*10 }, .5, { ease: FlxEase.circOut });
		FlxTween.tween(t, { alpha: 0 }, .5, { startDelay: 1 });

		player.addPoints(res.type);
		res.kill();

		if (player.score > 100) player.score = 100;
	}

	private function playerVRocket(b1:FlxBasic, b2:FlxBasic):Void
	{
		var player:Player = cast(Std.is(b1, Player) ? b1 : b2, Player);
		var rocket:Rocket = cast(Std.is(b1, Rocket) ? b1 : b2, Rocket);

		if (player.score >= 100 && rocket == player.rocketRef) {
			player.escaped = true;
			player.kill();
			rocket.launch();
			destroyPlanet();
		}
	}

	private function destroyPlanet():Void
	{
		if (_tilesToDestroy.length > 1) return;

		_tilesToDestroy = [];

		var current:Array<Int> = [Std.int(_tilemap.widthInTiles / 2), Std.int(_tilemap.heightInTiles / 2)];
		_tilesToDestroy.push([current[0], current[1]]);
		_tilesToDestroy.push([current[0] + 1, current[1]]);

		var dist:Int = 1;
		for (k in 0...160) {
			if (k % 2 == 1) dist++;

			for (i in 0...dist) {
				if (k % 4 == 0) current[1]--;
				if (k % 4 == 1) current[0]++;
				if (k % 4 == 2) current[1]++;
				if (k % 4 == 3) current[0]--;

				_tilesToDestroy.push([current[0], current[1]]);
			}
		}
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
			r.x = tileX * Reg.TILE_SIZE + Reg.TILE_SIZE / 2 - r.width / 2;
			r.y = tileY * Reg.TILE_SIZE + Reg.TILE_SIZE / 2 - r.height / 2;
			_resources.add(r);
		}

		_tilemap.setTile(tileX, tileY, 0, true);
	}
}