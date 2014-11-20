package ;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxAngle;
import flixel.util.FlxColor;

/**
 * ...
 * @author Mellonkhv
 */
class Player extends FlxSprite
{
	/**
	 * Публичные переменные
	 */
	public var speed:Float = 200;
	
	/**
	 * Конструктор класса Player с координатами
	 * @param	X
	 * @param	Y
	 */
	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		// Визуальная честь объекта
		loadGraphic(AssetPaths.player__png, true, 16, 16);
		
		// переворачиваем спрайт при движени в противоположном направлении
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);
		
		// Описане анимации, анимация будет заканчиваться нейтральной позой
		animation.add("lr", [3, 4, 3, 5], 6, false);
		animation.add("u", [6, 7, 6, 8], 6, false);
		animation.add("d", [0, 1, 0, 2], 6, false);
		
		// Drag тормозит объект недаёт ему начать бесконечно двигаться 
		drag.x = drag.y = 1600;
		
		setSize(8, 14);
		offset.set(4, 2);
	}
	/**
	 * Метод наблюдает за тем какие клавиши нажимает игрок и двигает спрайт в заданом направлении
	 */
	private function movement():Void
	{
		// Переменные направления движения
		var _up:Bool = false;
		var _down:Bool = false;
		var _left:Bool = false;
		var _right:Bool = false;
		
		// Слушаем какие клавищи наживает игрок и выбираем соответствующее направлени
		_up = FlxG.keys.anyPressed(["UP", "W"]);
		_down = FlxG.keys.anyPressed(["DOWN", "S"]);
		_left = FlxG.keys.anyPressed(["LEFT", "A"]);
		_right = FlxG.keys.anyPressed(["RIGHT", "D"]);
		
		// Запрещаем движение в противоположных направлениях
		if (_up && _down) _up = _down = false;
		if (_left && _right) _left = _right = false;
		
		// Проверяем куда игрок фактически двигается
		if (_up || _down || _left || _right)
		{
			// Диагональное движение
			//velocity.x = speed;
			//velocity.y = speed;
			
			// Угл движения в зависимости от нажатой клавиши
			var mA:Float = 0; // временная переменная угла
			if (_up) // игрок нажал вверх
			{
				mA = -90; // угол -90 (12 часов)
				if (_left) mA -= 45; // Если еще нажата клавиша влево то отнимает от угла ещё 45 градусов
				else if (_right) mA += 45; // Если вправо то придовляем
				facing = FlxObject.UP; // поворачиваем спрайт вверх
			}
			else if (_down)
			{
				mA = 90;
				if (_left) mA += 45;
				else if (_right) mA -= 45;
				facing = FlxObject.DOWN;
			}
			else if (_left) 
			{
				mA = 180;
				facing = FlxObject.LEFT;
			}
			else if (_right) 
			{
				mA = 0;
				facing = FlxObject.RIGHT;
			}
			
			// Что-то про угловую скорость плохо понят
			FlxAngle.rotatePoint(speed, 0, 0, 0, mA, velocity);
			
			if ((velocity.x != 0 || velocity.y != 0) && touching == FlxObject.NONE)
			{
				switch(facing)
				{
					case FlxObject.LEFT, FlxObject.RIGHT:
						animation.play("lr");
					case FlxObject.UP:
						animation.play("u");
					case FlxObject.DOWN:
						animation.play("d");
				}
			}
		}
	}
	/**
	 * Медод обновления вызывающий метод movment
	 */
	override public function update():Void 
	{
		movement();
		super.update();
	}
	
}