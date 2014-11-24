package;

import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	
	/**
	 * Приватные переменные
	 */
	private var _player:Player; // Игрок
	private var _map:FlxOgmoLoader; // Карта
	private var _mWalls:FlxTilemap; // Стены
	private var _grpCoins:FlxTypedGroup<Coin>;// монетки
	private var _grpEnemies:FlxTypedGroup<Enemy>;// враги
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		// Дабавляем карту
		_map = new FlxOgmoLoader("assets/data/room-001.oel");
		_mWalls = _map.loadTilemap("assets/images/tiles.png", 16, 16, "walls");
		_mWalls.setTileProperties(1, FlxObject.NONE);
		_mWalls.setTileProperties(2, FlxObject.ANY);
		add(_mWalls);
		
		// Добавляем монетку
		_grpCoins = new FlxTypedGroup<Coin>();
		add(_grpCoins);
		
		// Добавляем врагов
		_grpEnemies = new FlxTypedGroup<Enemy>();
		add(_grpEnemies);
		
		// Добавляем игрока
		_player = new Player();
		_map.loadEntities(placeEntities, "entities");
		add(_player);
		
		
		FlxG.camera.follow(_player, FlxCamera.STYLE_TOPDOWN, null, 1);
		
		super.create();
	}
	
	private function placeEntities(entityName:String, entityData:Xml):Void 
	{
		if (entityName == "player")
		{
			_player.x = Std.parseInt(entityData.get("x"));
			_player.y = Std.parseInt(entityData.get("y"));
		}
		else if (entityName == "coin")
		{
			_grpCoins.add(new Coin(Std.parseInt(entityData.get("x")) + 4, Std.parseInt(entityData.get("y")) + 4));
		}
		else if (entityName == "enemy")
		{
			_grpEnemies.add(new Enemy(Std.parseInt(entityData.get("x")) + 4, Std.parseInt(entityData.get("y")), Std.parseInt(entityData.get("etype"))));
		}
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();
		
		FlxG.collide(_player, _mWalls);
		FlxG.overlap(_player, _grpCoins, playerTouchCoin);
	}	
	
	private function playerTouchCoin(P:Player, C:Coin):Void 
	{
		if ( P.alive && P.exists && C.alive && C.exists)
		{
			C.kill();
		}
	}
}