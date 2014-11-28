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
		
		// Рисуем чёрный фон с белым кантом
		_sprBack = new FlxSprite().makeGraphic(120, 120, FlxColor.WHITE);
		_sprBack.drawRect(1, 1, 118, 44, FlxColor.BLACK);
		_sprBack.drawRect(1, 46, 118, 73, FlxColor.BLACK);
		_sprBack.screenCenter(true, true);
		add(_sprBack);
		
		// Добавим "пустышку" игрока который не может двигаться
		_sprPlayer = new Player(_sprBack.x +36, _sprPlayer.y + 16);
		_sprPlayer.animation.frameIndex = 3;
		_sprPlayer.active = false;
		_sprPlayer.facing = FlxObject.RIGHT;
		add(_sprPlayer);
		
		// Пустышка врага
		_sprEnemy = new Enemy(_sprBack.x + 76, _sprBack.y + 16, 0);
		_sprEnemy.animation.frameIndex = 3;
		_sprEnemy.active = false;
		_sprEnemy.facing = FlxObject.LEFT;
		add(_sprEnemy);
		
		// Настройка отображения здоровья игрока
		_txtPlayerHealth = new FlxText(0, _sprPlayer.y + _sprPlayer.height + 2, 0, "3 / 3", 8);
		_txtPlayerHealth.alignment = "center";
		_txtPlayerHealth.x = _sprPlayer.x + 4 - (_txtPlayerHealth.width / 2);
		add(_txtPlayerHealth);
		
		// Создание и добавление FlxBar для отображения здоровья противника. Мы будем делать это красным и желтым.
		_enemyHealthBar = new FlxBar(_sprEnemy.x - 6, _txtPlayerHealth.y, FlxBar.FILL_LEFT_TO_RIGHT, 20, 20);
		_enemyHealthBar.createFilledBar(FlxColor.CRIMSON, FlxColor.YELLOW, true, FlxColor.YELLOW);
		add(_enemyHealthBar);
		
		// создаём выбор нашего действия
		_choices = new Array<FlxText>();
		_choices.push(new FlxText(_sprBack.x + 30, _sprBack.y + 48, 85, "FIGHT", 22));
		_choices.push(new FlxText(_sprBack.x + 30, _choices[0].y + _choices[0].height + 8, 85, "FIGHT", 22));
		add(_choices[0]);
		add(_choices[1]);
		
		_pointer = new FlxSprite(_sprBack.x + 10, _choices[0].y + (_choices[0].height / 2) - 8, AssetPaths.pointer__png);
		_pointer.visible = false;
		add(_pointer);
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