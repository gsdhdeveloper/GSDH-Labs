package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.filters.BitmapFilter;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	/**
	 * @date 27/04/2010
	 * @author Chris Truter
	 */
	public class Main extends Sprite
	{
		[Embed(source='pic.jpg')]
		public var Source:Class;
		
		// abstract variables
		private var _blackArr:ByteArray; // byte data for a black bitmap, used to clear.
		private var _stageRect:Rectangle;
		private var _threshold:Number;
		private var _tlPoint:Point;
		
		// filters
		private var _blurLargeFilter:BitmapFilter;
		private var _blurSmallFilter:BitmapFilter;
		private var _fadeFilter:BitmapFilter;
		private var _vivifyFilter:BitmapFilter;
				
		// display elements
		private var _bitmap:BitmapData;		
		private var _particles:Vector.<Particle>;
		private var _source:Bitmap;		
		private var _swivelPlate1:Sprite;
		private var _swivelPlate2:Sprite;		
		private var _swivelSlider1:Sprite;		
		private var _swivelSlider2:Sprite;	
		
		public function Main():void
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		/**
		 * Actual Constructor. Here for JIT optimization + stage safety.
		 * 
		 * @param	e
		 */
		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			//stage.fullScreenSourceRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			//stage.displayState = StageDisplayState.FULL_SCREEN;
			
			initScene();
			
			addEventListener(Event.ENTER_FRAME, handleEnterFrame);
		}
		
		/**
		 * Create bitmap filters to be used on each enter frame. Also creates the rect and point used to apply the filters.
		 */
		private function createFilters():void
		{
			_stageRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			_tlPoint = new Point;			
			
			_fadeFilter = new ColorMatrixFilter(
				[ .85,   0,   0, 0, 0,
				    0, .83,   0, 0, 0,
				    0,   0, .80, 0, 0,
				    0,   0,   0, 1, 0 ]);
			
			_vivifyFilter = new ColorMatrixFilter(
				[ 1.15,    0, 0.032, 0, 0,
				     0, 1.15,  0.03, 0, 0,
				     0,    0,  1.08, 0, 0,
				     0,    0,  0,    1, 0 ]);
					 
			_blurLargeFilter = new BlurFilter(8, 4, 1);
			
			_blurSmallFilter = new BlurFilter(2, 2, 1);
		}
		
		/**
		 * Create the centre-pivoting plates used to spin the particles. 
		 */
		private function createSwivelPlates():void
		{
			_swivelPlate1 = new Sprite;
			_swivelSlider1 = new Sprite;
			_swivelPlate1.addChild(_swivelSlider1);
			
			_swivelPlate2 = new Sprite;
			_swivelSlider2 = new Sprite;
			_swivelPlate2.addChild(_swivelSlider2);
			
			_swivelPlate1.x = stage.stageWidth * .5;
			_swivelPlate1.y = stage.stageHeight * .5;
			_swivelSlider1.x = -_swivelPlate1.x;
			_swivelSlider1.y = -_swivelPlate1.y;
			
			_swivelPlate2.x = stage.stageWidth * .5;
			_swivelPlate2.y = stage.stageHeight * .5;
			_swivelSlider2.x = -_swivelPlate2.x;
			_swivelSlider2.y = -_swivelPlate2.y;
		}
		
		/**
		 * Our main update.
		 * 
		 * @param	e
		 */
		private function handleEnterFrame(e:Event):void
		{
			updateParticles();
			updateSwivel();
			updateBitmap();			
			stretchPlates();
			trackMouse();
			
			// If all pixels "liberated", don't scan image			
			if (_threshold > 0xffffff + 0x5000)
				return;
			
			liberatePixels();			
		}
		
		/**
		 * Initialize all the display objects, filters, parameters, etc.
		 */
		private function initScene():void
		{
			_threshold = 0;
			
			createFilters();			
			_particles = new Vector.<Particle>;			
			initBitmapAndSource();			
			createSwivelPlates();
			
			addChild(_swivelPlate1);
			addChild(_swivelPlate2);
			addChild(new Bitmap(_bitmap));
		}
		
		/**
		 * Initialize the source bitmap, and the live-render bitmap.
		 */
		private function initBitmapAndSource():void
		{
			_source = new Source;
			_source.scaleX = _source.scaleY = .15;			
			addChild(_source);
			var bmpData:BitmapData = new BitmapData(_source.width, _source.height, false, 0x0);
			bmpData.draw(this);
			_source.scaleX = _source.scaleY = 2;			
			_source.bitmapData = bmpData;			
			_source.x = (stage.stageWidth - _source.width) * .5;
			_source.y = 10;
			_source.visible = false;
			_bitmap = new BitmapData(stage.stageWidth, stage.stageHeight, true, 0x0);
		}
		
		/**
		 * Scan image for bright pixels, below a threshold. Darken pixels and liberate a particle instead
		 */
		private function liberatePixels():void
		{
			for (var i:int = 0; i < _source.width - 3; i+=3)
			{
				for (var j:int = 0; j < _source.height - 3; j+=3)
				{
					var pix:uint = _source.bitmapData.getPixel(i, j);
					if (pix < _threshold && pix > 0)
					{
						var part:Particle = new Particle(pix);
						_particles.push(part);
						
						if (Math.random() > .5)
							_swivelSlider2.addChild(part);
						else
							_swivelSlider1.addChild(part);
						
						part.x = i * 3 + _source.x;
						part.y = j * 3;
						
						_source.bitmapData.fillRect(new Rectangle(i, j, 3, 3), 0x0);
					}
				}
			}
			_threshold += 0x50000;
		}
		
		/**
		 * Sinusoidally stretch the swivel plates, orthogonally.
		 */
		private function stretchPlates():void
		{
			_swivelPlate1.scaleX = 1 - .6 * Math.sin(getTimer() * .001);
			_swivelPlate2.scaleY = 1 - .6 * Math.sin(getTimer() * .0011 + .5);
			_swivelPlate2.scaleX = .9 - .2 * Math.sin(getTimer() * .004 + .7);
		}
		
		/**
		 * Plates both track the mouse, but each following only on one axis.
		 */
		private function trackMouse():void
		{
			_swivelPlate1.x += (mouseX - _swivelPlate1.x) * .01;
			_swivelPlate2.y += (mouseY - _swivelPlate2.y) * .01;
		}
		
		/**
		 * Update snapshot, and apply some "snazzy" filters.
		 */
		private function updateBitmap():void
		{
			_bitmap.applyFilter(_bitmap, _stageRect, _tlPoint, _fadeFilter);
			_bitmap.applyFilter(_bitmap, _stageRect, _tlPoint, _blurLargeFilter);	
		
			_bitmap.draw(root);
			
			_bitmap.applyFilter(_bitmap, _stageRect, _tlPoint, _blurSmallFilter);
			_bitmap.applyFilter(_bitmap, _stageRect, _tlPoint, _vivifyFilter);
		}
		
		/**
		 * Update particle positions.
		 * 
		 * Really simple: 1D euler integrator modeling gravity + perfectly elastic bounce.
		 */
		private function updateParticles():void
		{
			for (var i:int = 0; i < _particles.length; i++)
			{
				_particles[i].y += _particles[i].vel;
				
				if (_particles[i].y > stage.stageHeight)
				{
					_particles[i].vel *= -1;
					_particles[i].y = stage.stageHeight * 2 - _particles[i].y;
				}
					
				_particles[i].vel += 1;
			}	
		}
		
		/**
		 * Rotate the swivel plates.
		 */
		private function updateSwivel():void
		{
			_swivelPlate1.rotation += 1;
			_swivelPlate2.rotation -= 2.6;
		}
	}
}