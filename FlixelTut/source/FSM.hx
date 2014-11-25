package ;

/**
 * Finite-state Machine (Конечный автомат — абстрактный автомат, число возможных состояний которого конечно. Результат работы автомата определяется по его конечному состоянию.)
 * Враг может быть только в одном из 2х возможных состояний "ожидание" или "охота"
 * @author Mellonkhv
 */
class FSM
{
	
	/**
	 * Публичные переменные
	 */
	public var activeState:Void->Void;
	
	public function new(?InitState:Void->Void):Void
	{
		activeState = InitState;
	}
	
	public function update():Void
	{
		if (activeState != null)
			activeState();
	}
	
}