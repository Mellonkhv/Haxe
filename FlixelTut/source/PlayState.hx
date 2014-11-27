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
	private var _hud:HUD;
	private var _money:Int = 0;
	private var _health:Int = 3;
	
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
		
		// Добавляем монетки в игру
		_grpCoins = new FlxTypedGroup<Coin>();
		add(_grpCoins);
		
		// Добавляем врагов
		_grpEnemies = new FlxTypedGroup<Enemy>();
		add(_grpEnemies);
		
		// Добавляем игрока
		_player = new Player();
		_map.loadEntities(placeEntities, "entities");
		add(_player);
		
		/**
		 * Заставляем камеру приследовать игрока, но прадварительно изменяем в классе Main значения 
		 * gameWidth = 320, gameHeight = 240 и zoom = 2
		 */
		FlxG.camera.follow(_player, FlxCamera.STYLE_TOPDOWN, null, 1); 
		
		// Добавляем интерфейс
		_hud = new HUD();
		add(_hud);
		
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
			// расставляем монетки по карте
			_grpCoins.add(new Coin(Std.parseInt(entityData.get("x")) + 4, Std.parseInt(entityData.get("y")) + 4));
		}
		else if (entityName == "enemy")
		{
			// Раставление врагов по карте
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
		
		FlxG.collide(_player, _mWalls); // Упираемся в стены
		FlxG.overlap(_player, _grpCoins, playerTouchCoin); // Собираем монетки
		
		FlxG.collide(_grpEnemies, _mWalls); // Враги упираются в стены
		checkEnemyVision(); // Проврка видимости врагами
	}	
	
	/**
	 * Зрение врагов
	 */
	private function checkEnemyVision():Void
	{
		// Пеебираем врагов
		for (e in _grpEnemies.members)
		{
			// Враги смотрят на игрока если взгляд не сталкивается со стеной возвращается "true"
			if (_mWalls.ray(e.getMidpoint(), _player.getMidpoint()))
			{
				e.seesPlayer = true;
				e.playerPos.copyFrom(_player.getMidpoint());
			}
			else
				e.seesPlayer = false;
		}
	}
	
	/**
	 * Игрок коснулся монетки
	 */
	private function playerTouchCoin(P:Player, C:Coin):Void 
	{
		if ( P.alive && P.exists && C.alive && C.exists) // Если игрок и монетка соприкоснулись
		{
			_money ++; // считаем собраную монетку
			_hud.updateHUD(_health, _money); // обновляем цифры
			C.kill(); // монетка исчезает
		}
	}
}