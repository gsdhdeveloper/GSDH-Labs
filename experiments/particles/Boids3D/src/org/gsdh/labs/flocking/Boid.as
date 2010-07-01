package org.gsdh.labs.flocking
{
	import flash.display.Sprite;
	import flash.geom.Vector3D;
	/**
	 * @author Chris Truter
	 */
	public class Boid extends Sprite
	{
		private var _vel:Vector3D;
		
		public function Boid()
		{
			var dir:Number = Math.random() * Math.PI * 2;
			
			z = Math.random() * 40 + 2
			
			_vel = new Vector3D(
				2 * Math.cos(dir),
				2 * Math.sin(dir),
				-10 + 20 * Math.random()
			);
			
			graphics.beginFill(0xffffff * Math.random());
			//graphics.beginFill(0x0a0 * Math.random() + 0x505050);
			graphics.moveTo( -3, -4.5);
			graphics.lineTo( 3, 0);
			graphics.lineTo( -3, 4.5);
			graphics.lineTo( -3, -4.5);
			graphics.endFill();
			
		}
		
		public function set targeted(value:Boolean):void
		{
			alpha = value ? 1 : .8;
		}
		
		public function get vel():Vector3D { return _vel; }
		
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
				var dz:Number = boid.z - z;
				
				var distSquared:Number = dx * dx + dy * dy + dz * dz;
				
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
					_vel.z = _vel.z * (1 - ff) + c1 * boid.vel.z * ff;
					//
					boid.vel.x = boid.vel.x * (1 - ff) + c2 * _vel.x * ff;
					boid.vel.y = boid.vel.y * (1 - ff) + c2 * _vel.y * ff;
					boid.vel.z = boid.vel.z * (1 - ff) + c2 * _vel.z * ff;
					
					if (dist < 20)
					{
						var strength:Number  = 1 / (Math.pow(dist, 1.1) + .001);
						
						_vel.x -= mult * (boid.x - x) * strength;
						_vel.y -= mult * (boid.y - y) * strength;
						_vel.z -= mult * (boid.z - z) * strength;
						//
						boid.vel.x += mult * (boid.x - x) * .5 * strength;
						boid.vel.y += mult * (boid.y - y) * .5 * strength;
						boid.vel.z += mult * (boid.z - z) * .5 * strength;
					}
				}
			}
			
			dx = shark.x - x;
			dy = shark.y - y;
			dz = shark.z - z;
			distSquared = dx * dx + dy * dy + dz * dz;
			
			//mult = 1 / 1500;
			mult = 1 / 500;
			
			var checkDist:Number = Config.BOID_SHARK_UPPER_DIST;
			var effectiveDist:Number = Config.BOID_SHARK_LOWER_DIST;
			
			if (distSquared < checkDist * checkDist)
			{
				dist = Math.sqrt(distSquared);
				
				var c3:Number = Config.BOID_OR_PIRHANA? -1 : 1;
				
				if (Config.BOID_OR_PIRHANA == 2)
					c3 = 0;
				
				if (dist < 2)
					c3 = 0;
				//
				_vel.x -= c3 * (effectiveDist - dist) * mult * (shark.x - x);
				_vel.y -= c3 * (effectiveDist - dist) * mult * (shark.y - y);
				_vel.z -= c3 * (effectiveDist - dist) * mult * (shark.z - z);
			}
			
			// mouse aversion
			if (Config.MOUSE_DOWN)
			{
				dx = mouseX;
				dy = mouseY;
				distSquared = dx * dx + dy * dy;
				
				mult = 1 / 200;
				if (distSquared < 90 * 90)
				{
					dist = Math.sqrt(distSquared);
					_vel.x += (90 - dist) * mult * (mouseX);
					_vel.y += (90 - dist) * mult * (mouseY);
					_vel.z += (90 - dist) * mult * (-_vel.z);
				}
			}
			
			square = _vel.x * _vel.x + _vel.y * _vel.y + _vel.z * _vel.z;
			
			var phi:Number = Math.acos(_vel.z / Math.sqrt(square)) - 90;
			rotationY = phi * 180 / Math.PI;
			
			var angle:Number = Math.atan2(_vel.y, _vel.x);
			rotationZ = angle / Math.PI * 180;
			
			x += _vel.x * .5;
			y += _vel.y * .5;
			z += _vel.z * .5;
			
			// bounce
			if (y < 2)						{ _vel.y *= -1; y = 2; }
			if (x < 2)						{ _vel.x *= -1;	x = 2; }
			if (y > stage.stageHeight - 2)	{ _vel.y *= -1; y = stage.stageHeight - 2; }
			if (x > stage.stageWidth - 2)	{ _vel.x *= -1; x = stage.stageWidth - 2; }
			
			if (z < 2)						{ _vel.z *= -1; z = 2; }
			if (z > 500 - 2)				{ _vel.z *= -1; z = 500 - 2; }
			
			// slow
			if (y < 80)						_vel.y += .5;
			if (x < 10)							_vel.x += .5;
			if (y > stage.stageHeight - 10)		_vel.y -= .5;
			if (x > stage.stageWidth - 10)		_vel.x -= .5;
			
			//_vel.z = 0;
			
			var square:Number = _vel.x * _vel.x + _vel.y * _vel.y + _vel.z * _vel.z;
			
			var invMag:Number;
			if (square > 225)
			{
				 invMag = 1 / Math.sqrt(square);
				_vel.x *= invMag * 15;
				_vel.y *= invMag * 15;
				_vel.z *= invMag * 15;
			} else if (square < 64)
			{
				invMag = 1 / Math.sqrt(square);
				_vel.x *= invMag * 8;
				_vel.y *= invMag * 8;
				_vel.z *= invMag * 8;
			}
			
			//angle = Math.atan2(_vel.z, _vel.x);
			//rotationY = angle / Math.PI * 180;
		}
	}
}