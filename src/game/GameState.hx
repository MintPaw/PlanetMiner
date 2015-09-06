package game;

import flixel.FlxState;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.math.FlxRect;
import flixel.math.FlxMath;
import flixel.math.FlxAngle;
import flixel.math.FlxVelocity;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.tile.FlxTile;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.effects.FlxFlicker;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import game.MapGenerator;

class GameState extends FlxState
{
	public static var DIRT:Int = 1;
	public static var KILL:Int = 33;

	private var _dirts:Array<Int> = [1, 12, 13, 14];
	private var _gem1:Array<Int> = [2, 15, 16, 17];
	private var _gem2:Array<Int> = [3, 18, 19, 20];
	private var _gem3:Array<Int> = [4, 21, 22, 23];
	private var _gem4:Array<Int> = [5, 24, 25, 26];
	private var _gem5:Array<Int> = [6, 27, 28, 29];
	private var _darkDirts:Array<Int> = [7, 30, 31, 32];

	private var _playerDefs:Array<Dynamic>;
	private var _backTilemap:FlxTilemap;
	private var _starTilemap:FlxTilemap;
	private var _tilemap:FlxTilemap;
	private var _blockDurability:Array<Array<Float>>;

	private var _players:FlxTypedGroup<Player>;
	private var _rockets:FlxTypedGroup<Rocket>;
	private var _resources:FlxTypedGroup<Resource>;
	private var _emmiters:FlxTypedGroup<FlxEmitter>;

	private var _tilesToDestroy:Array<Array<Int>> = [];
	private var _timeTillNextDestroy:Float = 0;
	private var _ending:Float = -1;
	private var _totalResources:Int = 0;

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
			FlxG.camera.fade(0xFF000000, 2, true);

			_emmiters = new FlxTypedGroup();
		}

		var cols:Int = 80;
		var rows:Int = 45;
		var spawnSize:Int = 5;
		var startPoints:Array<FlxPoint> = [new FlxPoint(spawnSize, spawnSize),
			                                   new FlxPoint(cols - spawnSize, spawnSize),
			                                   new FlxPoint(spawnSize, rows - spawnSize),
			                                   new FlxPoint(cols - spawnSize, rows - spawnSize)];

		{ // Setup tilemap
			_tilemap = new FlxTilemap();
			_backTilemap = new FlxTilemap();
			_starTilemap = new FlxTilemap();
			var startMap:Array<Array<Int>> = [];

			var bmp:openfl.display.Bitmap = new openfl.display.Bitmap(new openfl.display.BitmapData(cols, rows));
			bmp.bitmapData.perlinNoise(500, 500, 100, Math.round(Math.random() * 10000), true, true);

			var maxValue:Int = 0;
			var minValue:Int = 9999999;
			for (i in 0...Std.int(bmp.height)) {
				startMap[i] = [];
				for (j in 0...Std.int(bmp.width)) {
					startMap[i][j] = bmp.bitmapData.getPixel(j, i);
					if (bmp.bitmapData.getPixel(j, i) > maxValue) maxValue = startMap[i][j];
					if (bmp.bitmapData.getPixel(j, i) < minValue) minValue = startMap[i][j];
				}
			}

			maxValue -= minValue;


			for (i in 0...startMap.length) {
				for (j in 0...startMap[i].length) {
					startMap[i][j] -= minValue;
					startMap[i][j] = Math.round(FlxMath.lerp(-5, 5, startMap[i][j] / maxValue));
					if (startMap[i][j] > 5) startMap[i][j] = 5;
					if (startMap[i][j] < 1) startMap[i][j] = 1;
				}
			}

			for (s in startPoints) {
				for(xi in -spawnSize...spawnSize) {
					for(yi in -spawnSize...spawnSize) {
						startMap[Std.int(s.y + yi)][Std.int(s.x + xi)] = 0;
					}
				}
			}

			for (i in 0...startMap.length) for (j in 0...startMap[i].length) _totalResources += startMap[i][j];
			// var startMap:Array<Array<Int>> = Map.gen(cols, rows, 2, 9, 7);
			// for (i in 0...startMap.length)
				// for (j in 0...startMap[i].length)
					// if (startMap[i][j] > 5) startMap[i][j] = 5;

			_starTilemap.loadMapFrom2DArray(startMap, "assets/img/tiles.png", 16, 16);
			for (i in 0..._starTilemap.totalTiles) _starTilemap.setTileByIndex(i, _rnd.getObject([8, 9, 10, 11], [1, 1, 1, 10]));
			add(_starTilemap);

			_backTilemap.loadMapFrom2DArray(startMap, "assets/img/tiles.png", 16, 16);
			for (i in 0..._backTilemap.totalTiles) _backTilemap.setTileByIndex(i, _rnd.getObject(_darkDirts));
			add(_backTilemap);

			_tilemap.loadMapFrom2DArray(startMap, "assets/img/tiles.png", 16, 16);
			_tilemap.setTileProperties(1, FlxObject.ANY, playerVTile, null, 33);
			add(_tilemap);

			_blockDurability = [];
			for (i in 0...startMap.length) {
				_blockDurability[i] = [];
				for (j in 0...startMap[i].length)
					_blockDurability[i][j] = startMap[i][j] * 10;
			}

			for (i in 0..._tilemap.totalTiles) {
				if (_dirts.indexOf(_tilemap.getTileByIndex(i)) != -1) _tilemap.setTileByIndex(i, _rnd.getObject(_dirts));
				if (_gem1.indexOf(_tilemap.getTileByIndex(i)) != -1) _tilemap.setTileByIndex(i, _rnd.getObject(_gem1));
				if (_gem2.indexOf(_tilemap.getTileByIndex(i)) != -1) _tilemap.setTileByIndex(i, _rnd.getObject(_gem2));
				if (_gem3.indexOf(_tilemap.getTileByIndex(i)) != -1) _tilemap.setTileByIndex(i, _rnd.getObject(_gem3));
				if (_gem4.indexOf(_tilemap.getTileByIndex(i)) != -1) _tilemap.setTileByIndex(i, _rnd.getObject(_gem4));
				if (_gem5.indexOf(_tilemap.getTileByIndex(i)) != -1) _tilemap.setTileByIndex(i, _rnd.getObject(_gem5));
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
				p.neededScore = Math.ceil(_totalResources / _playerDefs.length * (4 / (Reg.currentRound / 2)));

				p.x = startPoints[i].x * Reg.TILE_SIZE;
				p.y = startPoints[i].y * Reg.TILE_SIZE;

				if (i == 0 || i == 1) p.y -= 3 * Reg.TILE_SIZE;
				else p.y += 3 * Reg.TILE_SIZE;
				
				_players.add(p);
				add(p.bar);
				add(p.trail);
				_emmiters.add(p.runEmitter);
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
				p.addPoints(0);
			}
		}

		add(_emmiters);
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
					    tileToDest[1] < _tilemap.heightInTiles) {
						for (p in _players) {
							if (p.getMidpoint().inFlxRect(new FlxRect(tileToDest[0] * Reg.TILE_SIZE, tileToDest[1] * Reg.TILE_SIZE, Reg.TILE_SIZE, Reg.TILE_SIZE))) {
								p.kill();
							}
						}
						_backTilemap.setTile(tileToDest[0], tileToDest[1], 0);
						_tilemap.setTile(tileToDest[0], tileToDest[1], 33);
					}

				} else _timeTillNextDestroy -= elapsed;
			}
		}

		{ // Update misc
			for (p in _players.members) p.canHitBlock = true;
		}

		{ // Update winning
			if (_ending > 0) _ending -= elapsed;
			if (_players.countLiving() == 0 && _ending == -1) _ending = 3;
			if (_ending <= 0 && _ending != -1)
			{
				_ending = -1;
				FlxG.camera.fade(0xFF000000, 5);
				for (res in _resources.members) FlxTween.tween(res, { alpha: 0 }, .5);
				FlxTween.tween(_tilemap, { y: _tilemap.height }, 4, { ease: null });
				FlxTween.tween(_backTilemap, { y: _backTilemap.height, alpha: 25 }, 4, { ease: null });

				var newDefs:Array<Dynamic> = [];
				for (p in _players) if (p.escaped) for (pd in _playerDefs) if (pd.type == p.type) newDefs.push(pd);

				Reg.currentRound++;

				new FlxTimer().start(5, function(t:FlxTimer) {
						if (newDefs.length > 1) FlxG.switchState(new GameState(newDefs))
						else if (newDefs.length == 1) FlxG.switchState(new EndState(newDefs[0].type))
						else if (newDefs.length == 0) FlxG.switchState(new EndState(-1));
					} , 1);
			}
		}

		super.update(elapsed);

		{ // Update collision
			FlxG.collide(_players, _tilemap);
			FlxG.collide(_players, _rockets, playerVRocket);
			FlxG.overlap(_players, _resources, playerVResource);
			FlxG.overlap(_players, _players, playerVPlayer);
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

		if (player.score >= player.neededScore) return;

		var t:DText = new DText(100, "+" + res.type, 12);
		t.alignment = FlxTextAlign.CENTER;
		t.x = player.x + player.width / 2 - t.width / 2 + Math.random() * 40 - 20;
		t.y = player.y + player.height / 2 - t.height / 2;
		add(t);

		FlxTween.tween(t, { y: t.y + 20 + Math.random()*10 }, .5, { ease: FlxEase.circOut });
		FlxTween.tween(t, { alpha: 0 }, .5, { startDelay: 1 });

		player.addPoints(res.type);
		res.kill();

		if (player.score > player.neededScore) player.score = player.neededScore;
	}

	private function playerVRocket(b1:FlxBasic, b2:FlxBasic):Void
	{
		var player:Player = cast(Std.is(b1, Player) ? b1 : b2, Player);
		var rocket:Rocket = cast(Std.is(b1, Rocket) ? b1 : b2, Rocket);

		if (player.score >= player.neededScore && rocket == player.rocketRef) {
			player.escaped = true;
			player.kill();
			rocket.launch();
			destroyPlanet();
		}
	}

	private function playerVPlayer(b1:FlxBasic, b2:FlxBasic):Void
	{
		var p1:Player = cast(b1, Player);
		var p2:Player = cast(b2, Player);

		if (p1.speedMult == 1 && p2.speedMult == 1) return;
		if (p1.inv > 0 || p2.inv > 0) return;

		var loser:Player = p1.speedMult > p2.speedMult ? p2 : p1;
		var winner:Player = p1.speedMult > p2.speedMult ? p1 : p2;

		if (p1.speedMult == p2.speedMult) loser = winner = null;

		var p1v:FlxPoint = FlxVelocity.velocityFromAngle(FlxAngle.angleBetween(p1, p2), 1);
		var p2v:FlxPoint = FlxVelocity.velocityFromAngle(FlxAngle.angleBetween(p2, p1), 1);

		if (loser == null) {
			if (p1.stunned > 0 || p2.stunned > 0) return;
			p1.stunned = 1;
			p2.stunned = 1;
			p1.inv = 6;
			p2.inv = 6;
			FlxFlicker.flicker(p1, 6, .01, true);
			FlxFlicker.flicker(p2, 6, .01, true);
		} else {
			loser.stunned = 1;
			loser.inv = 6;
			FlxFlicker.flicker(loser, 6, .01, true);
			var points:Int = Math.round(loser.score * .2);
			loser.addPoints(-points);
			winner.addPoints(points);

			var t:DText = new DText(100, "-" + points, 12);
			t.color = 0xFFFF0000;
			t.alignment = FlxTextAlign.CENTER;
			t.x = loser.x + loser.width / 2 - t.width / 2 + Math.random() * 40 - 20;
			t.y = loser.y + loser.height / 2 - t.height / 2;
			add(t);

			FlxTween.tween(t, { y: t.y + 20 + Math.random()*10 }, .5, { ease: FlxEase.bounceOut });
			FlxTween.tween(t, { alpha: 0 }, .5, { startDelay: 1 });
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

		if (_tilemap.getTile(tileX, tileY) == KILL) {
			player.kill();
			return;
		}

		_blockDurability[tileY][tileX] -= player.speedMult * 3;
		if (_blockDurability[tileY][tileX] <= 0) breakBlock(player, tileX, tileY, true);
	}

	public function breakBlock(player:Player, xpos:Float, ypos:Float, isTile:Bool=true):Void
	{
		var tileX:Int = Std.int(isTile ? xpos : xpos / Reg.TILE_SIZE);
		var tileY:Int = Std.int(isTile ? ypos : ypos / Reg.TILE_SIZE);
		var block:Int = _tilemap.getTile(tileX, tileY);

		var resType:Int = 0;

		if (_gem1.indexOf(_tilemap.getTile(Std.int(xpos), Std.int(ypos))) != -1) resType = 1;
		if (_gem2.indexOf(_tilemap.getTile(Std.int(xpos), Std.int(ypos))) != -1) resType = 2;
		if (_gem3.indexOf(_tilemap.getTile(Std.int(xpos), Std.int(ypos))) != -1) resType = 3;
		if (_gem4.indexOf(_tilemap.getTile(Std.int(xpos), Std.int(ypos))) != -1) resType = 4;
		if (_gem5.indexOf(_tilemap.getTile(Std.int(xpos), Std.int(ypos))) != -1) resType = 5;

		if (resType >= 1) {
			var r:Resource = new Resource(resType);
			r.x = tileX * Reg.TILE_SIZE + Reg.TILE_SIZE / 2 - r.width / 2;
			r.y = tileY * Reg.TILE_SIZE + Reg.TILE_SIZE / 2 - r.height / 2;
			_resources.add(r);
		}

		_tilemap.setTile(tileX, tileY, 0, true);
	}
}