package ;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
using flixel.util.FlxSpriteUtil;

/**
 * Класс HUD игровые индикаторы
 * @author Mellonkhv
 */
class HUD extends FlxTypedGroup<FlxSprite>
{
	/**
	 * Приватные переменные
	 */
	private var _sprBack:FlxSprite;
	private var _sprHealth:FlxSprite;
	private var _sprMoney:FlxSprite;
	private var _txtHealth:FlxText;
	private var _txtMoney:FlxText;

	public function new() 
	{
		super();
		_sprBack = new FlxSprite().makeGraphic(FlxG.width, 20, FlxColor.BLACK);
		_sprBack.drawRect(0, 19, FlxG.width, 1, FlxColor.WHITE);
		_sprHealth = new FlxSprite(4, _txtHealth.y +(_txtHealth.height / 2) - 4, AssetPaths.health__png);
		_sprMoney = new FlxSprite(FlxG.width -12, _txtMoney.y +(_txtMoney.height / 2) - 4, AssetPaths.coin__png);
		
		_txtHealth = new FlxText(16, 2, 0, "3/3", 8);
		_txtHealth.setBorderStyle(FlxText.BORDER_SHADOW, FlxColor.GRAY, 1, 1);
		_txtMoney = new FlxText(0, 2, 0, "0", 8);
		_txtMoney.setBorderStyle(FlxText.BORDER_SHADOW, FlxColor.GRAY, 1, 1);
		_txtMoney.alignment = "right";
		_txtMoney.x = _sprMoney.x - _sprMoney.width - 4;
		
		add(_sprBack);
		add(_sprHealth);
		add(_sprMoney);
		add(_txtHealth);
		add(_txtMoney);
	}
	
}