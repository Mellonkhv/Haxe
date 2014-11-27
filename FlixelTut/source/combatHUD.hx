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
	
	private var _txtPlayerHealth:FlxText // Показывает текущее количество жизни у игрока
	
	// Этот массив будет содержать 2 объекта FlxText, которые будут появляться, чтобы показать наносённый уронмили промахи
	private var _damages:Array<FlxText>;
	
	private var _pointer:FlxSprite; // Это будет указатель, чтобы показать, какой вариант (бороться или бежать) выбрал пользователь
	private var _selected:Int = 0; // Отслеживает какой вариант выбран	
	private var _choices:Array<FlxText>; //Этот массив будет содержать FlxTexts для наших 2-х вариантов: Борьба и Бегство
	
	private var _result:FlxText; // результат битвы
	
	private var _alpha:Float = 0; // будет использоваться для быхода из боевого интерфейса
	private var _wait:Bool = true; // этот флаг будет установлен в верно, когда не хотим, чтобы игрок делал что-нибудь (между витками)

	
	
	public function new() 
	{
		super();
		
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