package org.gsdh.labs.flocking
{
	import flash.display.Sprite;
	import flash.geom.Point;
	/**
	 * @author Chris Truter
	 */
	public class Shark extends Sprite
	{
		private var _vel:Point;
		
		public function Shark()
		{
			var dir:Number = Math.random() * Math.PI * 2;
			_vel = new Point(2 * Math.cos(dir), 2 * Math.sin(dir));
			
			draw();
		}
		
		private function draw():void
		{
			graphics.beginFill(0xff0000);
			//graphics.beginFill(0xffffff);
			graphics.moveTo( -4, -6);
			graphics.lineTo( 10, 0);
			graphics.lineTo( -4, 6);
			graphics.lineTo( -4, -6);
			graphics.endFill();
		}
		
		public function update(boids:Vector.<Boid>):void
		{
			var target:Point = new Point;
			var hitCount:Number = 0;
			
			var maxDistSquared:Number = Config.SHARK_OR_PLANKTON == 0 ? 240 * 240 : 50 * 50;
			
			for (var i:int = 0; i < boids.length; i++)
			{
				var boid:Boid = boids[i];
				var dx:Number = boid.x - x;
				var dy:Number = boid.y - y;
				
				boid.targeted = false;
				
				if (Config.SHARK_OR_PLANKTON == 0)
				{
					if (dx < -240 || dx > 240 || dy < -240 || dy > 240)
						continue;
				}
				if (Config.SHARK_OR_PLANKTON == 1)
				{
					if (dx < -50 || dx > 50 || dy < -50 || dy > 50)
						continue;
				}
					
				var dist:Number = dx * dx + dy * dy;
				if  (dist > maxDistSquared)
					continue;
				
				boid.targeted = true;
					
				target.x += boid.x;
				target.y += boid.y;
				
				hitCount++;
				
				// TODO: show that he is interested
			}
			
			// average out target position
			if (hitCount > 0)
			{
				var mult:Number = 1 / hitCount;
				target.x *= mult;
				target.y *= mult;
			}
			else
			{
				target.x = x;
				target.y = y;
			}
			
			var acc:Point = new Point(target.x - x, target.y - y);
			var invMag:Number = 1 / Math.sqrt(acc.x * acc.x + acc.y * acc.y);
			if (!isNaN(invMag))
			{
				acc.x *= .2 * invMag;
				acc.y *= .2 * invMag;
			}
			
			//var angle:Number = Math.atan2(acc.y, acc.x);
			//rotation = angle / Math.PI * 180;
			
			var angle:Number = Math.atan2(_vel.y, _vel.x);
			rotation = angle / Math.PI * 180;
			
			if (isNaN(acc.x))
				acc.x = 0;
			if (isNaN(acc.y))
				acc.y = 0;
			
			if (Config.SHARK_OR_PLANKTON == 2)
				acc.x = acc.y = 0;
				
			_vel.x += acc.x * (Config.SHARK_OR_PLANKTON ? -4 : 1);
			_vel.y += acc.y * (Config.SHARK_OR_PLANKTON ? -4 : 1);
			
			// bounce
			if (y < 0)					{ _vel.y *= -1; y = 0; }
			if (x < 0)					{ _vel.x *= -1;	x = 0; }
			if (y > stage.stageHeight)	{ _vel.y *= -1; y = stage.stageHeight; }
			if (x > stage.stageWidth)	{ _vel.x *= -1; x = stage.stageWidth; }
			
			// slow
			if (y < 50)							_vel.y += .2;
			if (x < 50)							_vel.x += .2;
			if (y > stage.stageHeight - 50)		_vel.y -= .2;
			if (x > stage.stageWidth - 50)		_vel.x -= .2;
			
			var square:Number = _vel.x * _vel.x + _vel.y * _vel.y;
			
			var max_speed:Number = Config.SHARK_OR_PLANKTON ? 6 : 4;
			
			if (square > max_speed * max_speed)
			{
				invMag = 1 / Math.sqrt(square);
				_vel.x *= invMag * max_speed;
				_vel.y *= invMag * max_speed;
			}
			
			x += _vel.x * .5;
			y += _vel.y * .5;
		}
	}
}