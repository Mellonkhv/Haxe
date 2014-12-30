package;

import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.group.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxButton;
import flixel.util.FlxAngle;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
using flixel.util.FlxSpriteUtil;

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
	private var _inCombat:Bool = false;
	private var _combatHUD:CombatHUD;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		// Дабавляем карту
		_map = new FlxOgmoLoader(AssetPaths.room_001__oel);
		_mWalls = _map.loadTilemap(AssetPaths.tiles__png, 16, 16, "walls");
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
		
		_combatHUD = new CombatHUD();
		add(_combatHUD);
		
		super.create();
	}
	
	private function placeEntities(entityName:String, entityData:Xml):Void 
	{
		var x:Int = Std.parseInt(entityData.get("x"));
		var y:Int = Std.parseInt(entityData.get("y"));
		
		if (entityName == "player")
		{
			_player.x = x;
			_player.y = y;
		}
		else if (entityName == "coin")
		{
			// расставляем монетки по карте
			_grpCoins.add(new Coin(x + 4, y + 4));
		}
		else if (entityName == "enemy")
		{
			// Раставление врагов по карте
			_grpEnemies.add(new Enemy(x + 4, y, Std.parseInt(entityData.get("etype"))));
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
		if (!_inCombat)
		{
			FlxG.collide(_player, _mWalls); // Упираемся в стены
			FlxG.overlap(_player, _grpCoins, playerTouchCoin); // Собираем монетки
			
			FlxG.collide(_grpEnemies, _mWalls); // Враги упираются в стены
			checkEnemyVision(); // Проврка видимости врагами
			FlxG.overlap(_player, _grpEnemies, playerTouchEnemy);
		}
		else
		{
			if (!_combatHUD.visible)
			{
				_health = _combatHUD.playerHealth;
				_hud.updateHUD(_health, _money);
				if (_combatHUD.outcome == VICTORY)
				{
					_combatHUD.e.kill();
				}
				else
				{
					_combatHUD.e.flicker();
				}
				_inCombat = false;
				_player.active = true;
				_grpEnemies.active = true;
			}
		}
	}
	
	/**
	 * Игрок столкнулся с врагом
	 * @param	player
	 * @param	enemy
	 */
	private function playerTouchEnemy(P:Player, E:Enemy):Void
	{
		// Если игрок жив и враг жив и не мерцает
		if (P.alive && P.exists && E.alive && E.exists && !E.isFlickering())
		{
			startCombat(E); // Начинаем бойню
		}
	}
	
	/**
	 * Старт боя с текущим врагом
	 * @param	enemy
	 */
	private function startCombat(E:Enemy):Void 
	{
		// Делаем игрока и всех врагов неактивными
		_inCombat = true;
		_player.active = false;
		_grpEnemies.active = false;
		_combatHUD.initCombat(_health, E);
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