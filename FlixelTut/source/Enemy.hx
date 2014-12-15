package ;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxAngle;
import flixel.util.FlxColor;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import flixel.util.FlxVelocity;
using flixel.util.FlxSpriteUtil;

/**
 * Класс врагов
 * @author Mellonkhv
 */
class Enemy extends FlxSprite
{
	/**
	 * Публичные переменные
	 */
	public var speed:Float = 140;
	public var etype(default, null):Int;
	public var seesPlayer:Bool = false;
	public var playerPos(default, null):FlxPoint;
	
	/**
	 * Приватные переменные
	 */
	private var _brain:FSM;
	private var _idleTmr:Float;
	private var _moveDir:Float;
	
	/**
	 * Конструктор класса Player с координатами
	 * @param	X
	 * @param	Y
	 */
	public function new(X:Float = 0, Y:Float = 0, EType:Int) 
	{
		super(X, Y);
		
		// Тип врага
		etype = EType;
		
		// Визуальная честь объекта
		loadGraphic("assets/images/enemy-" + Std.string(etype)+ ".png", true, 16, 16);
		
		// переворачиваем спрайт при движени в противоположном направлении
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);
		
		// Описане анимации, анимация будет заканчиваться нейтральной позой
		animation.add("lr", [3, 4, 3, 5], 6, false);
		animation.add("u", [6, 7, 6, 8], 6, false);
		animation.add("d", [0, 1, 0, 2], 6, false);
		
		_brain = new FSM(idle);
		_idleTmr = 0;
		playerPos = FlxPoint.get();
		
		// Drag тормозит объект недаёт ему начать бесконечно двигаться 
		drag.x = drag.y = 10;
		
		width = 8;
		height = 14;
		offset.x = 4;
		offset.y = 2;
	}
	
	private function idle():Void
	{
		if (seesPlayer)
		{
			_brain.activeState = chase;
		}
		else if (_idleTmr <= 0)
		{
			if (FlxRandom.chanceRoll(1))
			{
				_moveDir = -1;
				velocity.x = velocity.y = 0;
			}
			else
			{
				_moveDir = FlxRandom.intRanged(0, 8) * 45;
				FlxAngle.rotatePoint(speed * .5, 0, 0, 0, _moveDir, velocity);
			}
			_idleTmr = FlxRandom.intRanged(1, 4);
		}
		else
			_idleTmr -= FlxG.elapsed;
	}
	
	public function chase():Void
	{
		if (!seesPlayer)
		{
			_brain.activeState = idle;
		}
		else
		{
			FlxVelocity.moveTowardsPoint(this, playerPos, Std.int(speed));
		}
	}
	
	/**
	 * Рисование анимации по нажатию клавишь
	 */
	override public function draw():Void 
	{
		if ((velocity.x != 0 || velocity.y != 0) && touching == FlxObject.NONE)
			{
				if (Math.abs(velocity.x) > Math.abs(velocity.y))
				{
					if (velocity.x < 0)
						facing = FlxObject.LEFT;
					else
						facing = FlxObject.RIGHT;
				}
				else
				{
					if (velocity.y < 0)
						facing = FlxObject.UP;
					else
						facing = FlxObject.DOWN;
				}
				
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
		
		super.draw();
	}
	
	public function changeEnemy(enemyType:Int):Void
	{
		if (etype != enemyType)
		{
			etype = enemyType;
			loadGraphic("assets/images/enemy-" + Std.string(etype) + ".png", true, 16, 16);
		}
	}
	
	/**
	 * Медод обновления вызывающий метод movment
	 */
	override public function update():Void 
	{
		if (isFlickering()) return;
		_brain.update();
		super.update();
	}
}