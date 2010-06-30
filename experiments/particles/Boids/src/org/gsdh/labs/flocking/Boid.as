package org.gsdh.labs.flocking
{
	import flash.display.Sprite;
	import flash.geom.Point;
	/**
	 * @author Chris Truter
	 */
	public class Boid extends Sprite
	{
		private var _vel:Point;
		
		public function Boid()
		{
			var dir:Number = Math.random() * Math.PI * 2;
			_vel = new Point(2 * Math.cos(dir), 2 * Math.sin(dir));
			
			graphics.beginFill(0xffffff * Math.random());
			//graphics.beginFill(0x0a0 * Math.random() + 0x505050);
			graphics.moveTo( -2, -3);
			graphics.lineTo( 2, 0);
			graphics.lineTo( -2, 3);
			graphics.lineTo( -2, -3);
			graphics.endFill();
		}
		
		public function set targeted(value:Boolean):void
		{
			alpha = value ? 1 : .8;
		}
		
		public function get vel():Point { return _vel; }
		
		public function update(boids:Vector.<Boid>, shark:Shark):void
		{
			var mult:Number = 1;
			
			for (var i:int = 0; i < boids.length; i++)
			{
				var boid:Boid = boids[i];
				if (boid == this)
					continue;
					
				var dx:Number = boid.x - x;
				var dy:Number = boid.y - y;
				
				var distSquared:Number = dx * dx + dy * dy;
				
				if (distSquared < 64 * 64)
				{
					var dist:Number = Math.sqrt(distSquared);
					var ff:Number = 1 / dist;
					if (ff > 1)
						ff = 1;
						
					var c1:Number = Config.BOID_SOCIABILITY == 0 ? 1 : -1;
					var c2:Number = Config.BOID_SOCIABILITY == 2 ? -1 : 1;
					
					_vel.x = _vel.x * (1 - ff) + c1 * boid.vel.x * ff;
					_vel.y = _vel.y * (1 - ff) + c1 * boid.vel.y * ff;
					
					boid.vel.x = boid.vel.x * (1 - ff) + c2 * _vel.x * ff;
					boid.vel.y = boid.vel.y * (1 - ff) + c2 * _vel.y * ff;
					
					if (dist < 20)
					{
						var strength:Number  = 1 / (Math.pow(dist, 1.1) + .001);
						
						_vel.x -= mult * (boid.x - x) * strength;
						_vel.y -= mult * (boid.y - y) * strength;
						
						boid.vel.x += mult * (boid.x - x) * .5 * strength;
						boid.vel.y += mult * (boid.y - y) * .5 * strength;
					}
				}
			}
			
			dx = shark.x - x;
			dy = shark.y - y;
			distSquared = dx * dx + dy * dy;
			
			//mult = 1 / 1500;
			mult = 1 / 5000;
			if (distSquared < 140 * 140)
			{
				dist = Math.sqrt(distSquared);
				
				var c3:Number = Config.BOID_OR_PIRHANA? -1 : 1;
				
				if (Config.BOID_OR_PIRHANA == 2)
					c3 = 0;
				
				if (dist < 9)
					c3 = 1;
				
				_vel.x -= c3 * (140 - dist) * mult * (shark.x - x);
				_vel.y -= c3 * (140 - dist) * mult * (shark.y - y);
			}
			
			// mouse aversion
			if (Config.MOUSE_DOWN)
			{
				dx = mouseX;
				dy = mouseY;
				distSquared = dx * dx + dy * dy;
				
				mult = 1 / 200;
				if (distSquared < 50 * 50)
				{
					dist = Math.sqrt(distSquared);
					_vel.x += (80 - dist) * mult * (mouseX);
					_vel.y += (80 - dist) * mult * (mouseY);
				}
			}
			
			x += _vel.x * .5;
			y += _vel.y * .5;
			
			// bounce
			if (y < 2)						{ _vel.y *= -1; y = 2; }
			if (x < 2)						{ _vel.x *= -1;	x = 2; }
			if (y > stage.stageHeight - 2)	{ _vel.y *= -1; y = stage.stageHeight - 2; }
			if (x > stage.stageWidth - 2)	{ _vel.x *= -1; x = stage.stageWidth - 2; }
			
			// slow
			if (y < 80)						_vel.y += .5;
			if (x < 10)							_vel.x += .5;
			if (y > stage.stageHeight - 10)		_vel.y -= .5;
			if (x > stage.stageWidth - 10)		_vel.x -= .5;
			
			var square:Number = _vel.x * _vel.x + _vel.y * _vel.y;
			
			var invMag:Number;
			if (square > 16)
			{
				 invMag = 1 / Math.sqrt(square);
				_vel.x *= invMag * 4;
				_vel.y *= invMag * 4;
			} else if (square < 9)
			{
				invMag = 1 / Math.sqrt(square);
				_vel.x *= invMag * 3;
				_vel.y *= invMag * 3;
			}
			
			var angle:Number = Math.atan2(_vel.y, _vel.x);
			rotation = angle / Math.PI * 180;
		}
	}
}