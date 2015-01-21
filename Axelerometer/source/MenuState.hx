package;

import flash.events.Event;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flash.sensors.Accelerometer;
import flash.events.AccelerometerEvent;
import flixel.util.FlxPoint;
import flixel.util.FlxVelocity;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxState
{
	
	var _accelData:Accelerometer;
	var _player:FlxSprite;
	var _point:FlxPoint;
	var _text:FlxText;
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		super.create();
		
		_accelData = new Accelerometer();
		
		_player = new FlxSprite();
		_player.makeGraphic(32, 32, 0xffffffff);
		_player.x = FlxG.width / 2;
		_player.y = FlxG.height / 2;
		add(_player);
		_point = new FlxPoint(0, 0);
		
		_text = new FlxText(0, 0, FlxG.width, "", 16);
		add(_text);
		
		if (Accelerometer.isSupported)
		{
			_accelData.addEventListener(AccelerometerEvent.UPDATE, updateAccel);
		}
	}
	
	public function updateAccel(e:AccelerometerEvent):Void 
	{
		_point.x = (FlxG.width / 2) + (e.accelerationX * FlxG.width);
		_point.y = (FlxG.height / 2) + (e.accelerationY * FlxG.height);
		FlxVelocity.moveTowardsPoint(_player, _point, 10, 100);
		_text.text = "X: " + Std.string(e.accelerationX) + ", Y: " + Std.string(e.accelerationY);
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();
	}	
}