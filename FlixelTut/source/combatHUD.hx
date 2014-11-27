package ;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxRandom;
using flixel.util.FlxSpriteUtil;

/**
 * ...
 * @author Mellonkhv
 */
class combatHUD extends FlxTypedGroup<FlxSprite>
{
	
	/**
	 * Публичные переменные
	 */
	// Данные переменные раскажут что случилось
	public var e:Enemy; // Враг с которым произошло столкновение
	public var playerHealth(default, null):Int; // здоровье игрока
	public var outcome(default, null):Outcome; // результат боя
	
	/**
	 * Приватные переменные
	 */
	// Визуализация боевого интерфейса
	private var _sprBack:FlxSprite; // Спрайт Фона
	private var _sprPlayer:Player; // Спрайт Игрока
	private var _sprEnemy:Enemy; // Спрайт Врага
	
	// Здоровье врага
	private var _enemyHealth:Int;
	private var _enemyMaxHealth:Int;
	private var _enemyHealthBar:FlxBar; // FlxBar покажет текущее / максимальное здоровье врага

	public function new(MaxSize:Int=0) 
	{
		super(MaxSize);
		
	}
	
}

/**
 * Данное перечисление используется для установки допустимых значений для нашей переменной исхода. 
 * Результат может быть только когда один из этих 4 ценностей, и мы можем проверить для этих значений легко, как только боевой вывод.
*/
enum Outcome
{
	NONE;
	ESCAPE;
	VICTORY;
	DEFEAT;
}