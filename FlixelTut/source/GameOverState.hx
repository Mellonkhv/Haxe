package ;

import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;

/**
 * Класс описывающий конец игры
 * @author Mellonkhv
 */
class GameOverState extends FlxState
{
	private var _score:Int = 0;			//Количество собраных монет
	private var _win:Bool;				//Победа или проигрыщ
	private var _txtTile:FlxText;		//Титульный текст
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
		
		super.create();
	}
	
}