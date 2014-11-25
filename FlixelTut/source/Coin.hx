package ;

import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

/**
 * Класс монеток
 * @author Mellonkhv
 */
class Coin extends FlxSprite
{

	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		loadGraphic("assets/images/coin.png", false, 8, 8);
	}
	
	override public function kill():Void 
	{
		// Поменяем статус на "не живая" :)
		alive = false;
		// Когда монетка подобрана она подпрыгивает и растворяется
		FlxTween.tween(this, { alpha:0, y:y - 16 }, .66, { type:FlxTween.ONESHOT, ease:FlxEase.circOut, complete:finishKill } ); 
	}
	
	private function finishKill(T:FlxTween):Void
	{
		// Монетка больше не существует
		exists = false;
	}
}