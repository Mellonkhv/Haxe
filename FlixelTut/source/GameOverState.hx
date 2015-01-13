package ;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSave;
using flixel.util.FlxSpriteUtil;

/**
 * Класс описывающий конец игры
 * @author Mellonkhv
 */
class GameOverState extends FlxState
{
	private var _score:Int = 0;			//Количество собраных монет
	private var _win:Bool;				//Победа или проигрыщ
	private var _txtTitle:FlxText;		//Титульный текст
	private var _txtMessage:FlxText;	//Финальный текст сообщения с результатом игры
	private var _sprScore:FlxSprite;	//Спрайт c иконкой монетки
	private var _txtScore:FlxText;		//Текст с результатом
	private var _txtHiScore:FlxText;	//Текст показывает лучший результат
	private var _btnMainMenu:FlxButton;	//Кнопка перехода в основное меню
	
	/**
	 * Вызывается из PlayState принимает переменные победа\проигрыш, количество монет 
	 * @param	won	
	 * @param	money
	 */
	public function new(Win:Bool, Score:Int) 
	{
		super();
		_win = Win;
		_score = Score;
	}
	
	override public function create():Void 
	{
		// Создать и добавить каждую из наших деталей
		
		_txtTitle = new FlxText(0, 20, 0, _win ? "You Win!" : "Game Over!", 22); // Текст в зависимости от того побееда или поражение
		_txtTitle.alignment = "center"; // Текст по центру
		_txtTitle.screenCenter(true, false); // Текст по центру экрана
		add(_txtTitle);
		
		_txtMessage = new FlxText(0, (FlxG.height / 2) - 18, 0, "Final Score:", 8);
		_txtMessage.alignment = "center";
		_txtMessage.screenCenter(true, false);
		add(_txtMessage);
		
		_sprScore = new FlxSprite((FlxG.width / 2) - 8, 0, AssetPaths.coin__png);
		_sprScore.screenCenter(false, true);
		add(_sprScore);
		
		_txtScore = new FlxText((FlxG.width / 2), 0, 0, Std.string(_score), 8);
		_txtScore.screenCenter(false, true);
		add(_txtScore);
		
		// Отображение наибольшего результата
		var _hiScore = checkHiScore(_score);
		
		_txtHiScore = new FlxText(0, (FlxG.height / 2) + 10, 0, "Hi-Score: " + Std.string(_hiScore), 8);
		_txtHiScore.alignment = "center";
		_txtHiScore.screenCenter(true, false);
		add(_txtHiScore);
		
		_btnMainMenu = new FlxButton(0, FlxG.height - 32, "Main Menu", goToMainMenu);
		_btnMainMenu.screenCenter(true, false);
		_btnMainMenu.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
		add(_btnMainMenu);
		
		super.create();
	}
	
	/**
	 * Этот метод сравнивает текущий резутьтат с наивысшим
	 * Если текущий больше он заменяет наивыйший
	 * @param	Score
	 * @return the hi-score
	 */
	private function checkHiScore(Score:Int):Int
	{
		var _hi:Int = Score;
		var _save:FlxSave = new FlxSave();
		if (_save.bind("flixel-tutorial"))
		{
			if (_save.data.hiscore != null)
			{
				if (_save.data.hiscore > _hi)
				{
					_hi = _save.data.hiscore;
				}
				else
				{
					_save.data.hiscore = _hi;
				}
			}
		}
		_save.close();
		return _hi;
	}
	
	/**
	 * Когда игрок нажимает кнопку "Main menu" всё исчезает и появляется основное меню
	 */
	private function goToMainMenu():Void
	{
		FlxG.camera.fade(FlxColor.BLACK, .66, false, function() {
			FlxG.switchState(new MenuState());
			
		});
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		
		// удаляем созданные объекты
		_txtTitle = FlxDestroyUtil.destroy(_txtTitle);
		_txtMessage = FlxDestroyUtil.destroy(_txtMessage);
		_sprScore = FlxDestroyUtil.destroy(_sprScore);
		_txtScore = FlxDestroyUtil.destroy(_txtScore);
		_btnMainMenu = FlxDestroyUtil.destroy(_btnMainMenu);
	}
}