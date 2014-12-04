package ;

import flash.filters.ColorMatrixFilter;
import flash.geom.Matrix;
import flash.geom.Point;
import flixel.addons.effects.FlxWaveSprite;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
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
	
	private var _results:FlxText; // результат битвы
	
	private var _alpha:Float = 0; // будет использоваться для быхода из боевого интерфейса
	private var _wait:Bool = true; // этот флаг будет установлен в верно, когда не хотим, чтобы игрок делал что-нибудь (между витками)

	private var _sndFled:FlxSound;
	private var _sndHurt:FlxSound;
	private var _sndLose:FlxSound;
	private var _sndMiss:FlxSound;
	private var _sndSelect:FlxSound;
	private var _sndWin:FlxSound;
	private var _sndCombat:FlxSound;
	
	private var _sprScreen:FlxSprite;
	private var _sprWave:FlxWaveSprite;
	
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
		
		// создать тексты повреждениq. Мы заставим их быть белым текстом с красной тенью (так они выделяются).
		_damages = new Array<FlxText>();
		_damages.push(new FlxText(0, 0, 40));
		_damages.push(new FlxText(0, 0, 40));
		for (d in _damages) 
		{
			d.color = FlxColor.WHITE;
			d.setBorderStyle(FlxText.BORDER_SHADOW, FlxColor.RED);
			d.aligment = "center";
			d.visible = false;
			add(d);
		}
		// создаём наш результирующий текст. Мы его расположим но спрячем
		_results = new FlxText(_sprBack.x + 2, _sprBack.y + 9, 116, "", 18);
		_results.alignment = "center";
		_results.color = FlxColor.YELLOW;
		_results.setBorderStyle(FlxText.BORDER_SHADOW, FlxColor.GRAY);
		_results.visible = false;
		add(_results);
		
		// Отключаем прокрутку для всех элементов класса.
		forEach(function(spr:FlxSprite) {
			spr.scrollFactor.set();
			spr.alpha = 0;
		});
		
		// Отметить данный класс как неактивный и невидимый, пока мы не будем готовы показать их.
		active = false;
		visible = false;
		
		_sndFled = FlxG.sound.load(AssetPaths.fled__wav);
		_sndHurt = FlxG.sound.load(AssetPaths.hurt__wav);
		_sndLose = FlxG.sound.load(AssetPaths.lose__wav);
		_sndMiss = FlxG.sound.load(AssetPaths.miss__wav);
		_sndSelect = FlxG.sound.load(AssetPaths.select__wav);
		_sndWin = FlxG.sound.load(AssetPaths.win__wav);
		_sndCombat = FlxG.sound.load(AssetPaths.combat__wav);
	}
	
	/**
	 * Эта функция будет вызываться из PlayState, когда мы хотим начать бой. Это будет установка экрана и убедиться, что все готово.
	 * @param	playerHealth  количество здоровья игрока
	 * @param	enemy враг с которым мы сцепились
	 */
	public function initCombat(PlayerHealth:Int, enemy:Enemy):Void
	{
		#if flash
		_sprScreen.pixels.copyPixels(FlxG.camera.buffer, FlxG.camera.buffer.rect, new Point());
		#else
		_sprScreen.pixels.draw(FlxG.camera.canvas, new Matrix(1, 0, 0, 1, 0, 0));
		#end
		var rc:Float = 1 / 3;
		var gc:Float = 1 / 2;
		var bc:Float = 1 / 6;
		_sprScreen.pixels.applyFilter(_sprScreen.pixels, _sprScreen.pixels.rect, new Point(), new ColorMatrixFilter([rc, gc, bc, 0, 0, rc, gc, bc, 0, 0, rc, gc, bc, 0, 0, 0, 0, 0, 1, 0]);
		_sprScreen.resetFrameBitmapDatas();
		_sprScreen.dirty = true;
		
		_sndCombat.play();
		playerHealth = PlayerHealth;
		e = enemy;
		
		updatePlayerHealth();
		
		// настройки врага
		_enemyMaxHealth = _enemyHealth = (e.etype + 1) * 2;//У каждого врага будет здоровье на основе типов: Тип 0=2 здоровья, тип 1=4 здоровья
		_enemyHealthBar.currentValue = 100; // Прогрессбар здоровья на 100%
		_sprEnemy.changeEnemy(e.etype); // заменить нашего врага в соответствии с его типом
		
		// Убедимся что мы инициализировали всё правильно до того как начнём
		_wait = true;
		_results.text = "";
		_pointer.visible = false;
		_results.visible = false;
		outcome = NONE;
		_selected = 0;
		movePointer();
		
		visible = true; // отобразить наш HUD обращении к нему - обратите внимание, что это не активен, пока!
		
		//сделать анимацию исчезновения нашего combatHUD, когда анимация закончена вызывается finishFadeIn
		FlxTween.num(0, 1, .66, { ease:FlxEase.circOut, complete:finishFadeIn }, updateAlpha);
	}
	
	/**
	 * Функция вызывается для анимации проявления / исчезновения
	 * @param	Value
	 */
	private function updateAlpha(Value:Float):Void
	{
		_alpha = Value;
		forEach(function(spr:FlxSprite) {
			spr.alpha = _alpha;
		});
	}
	
	/**
	 * После того как визуальная часть проявилась активируем combatHUD и показываем указатель
	 */
	private function finishFadeIn(_):Void
	{
		active  = true;
		_wait = false;
		_pointer.visible = true;
	}
	
	/**
	 * После того как визуальная часть исчезла деактивируем combatHUD и всё прячем
	 */
	private function finishFadeOut(_):Void
	{
		active = false;
		visible = false;
	}
	
	/**
	 * Эта функция вызывается для отображения здоровья игрока
	 */
	private function updatePlayerHealth():Void
	{
		_txtPlayerHealth.text = Std.string(playerHealth) + " / 3";
		_txtPlayerHealth.x = _sprPlayer.x + 4 - (_txtPlayerHealth.width / 2);
	}
	
	override public function update():Void 
	{
		if (!_wait)
		{
			
		}
		super.update();
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