package
{
	import flash.display.Shape;
	
	/**
	 * A basic coloured element, exposing a velocity attribute.
	 *
	 * @author Chris Truter
	 */
	public class Particle extends Shape
	{
		private const SCALE:Number = .5;
		
		public var vel:Number = 0;
		
		public function Particle(col:uint)
		{
			graphics.beginFill(col);
			if (Math.random() < 1)
			{
				// I'm a square!
				graphics.drawRect(0, 0, 5 * SCALE, 5 * SCALE);
			}
			else
			{
				// I'm a triangle!
				graphics.moveTo(-3  * SCALE, 2  * SCALE);
				graphics.lineTo( 3  * SCALE, 2  * SCALE);
				graphics.lineTo(0, (1 - Math.sqrt(36 - 16)) * SCALE);
				rotation = 360 * Math.random();
			}
			graphics.endFill();
		}
	}
}