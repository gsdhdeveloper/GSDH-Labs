package
{
	import com.bit101.components.ComboBox;
	import com.bit101.components.HBox;
	import com.bit101.components.List;
	import com.bit101.components.Meter;
	import com.bit101.components.Panel;
	import com.bit101.components.RadioButton;
	import com.bit101.components.RangeSlider;
	import com.bit101.components.RotarySelector;
	import com.bit101.components.Slider;
	import com.bit101.components.VBox;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilter;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	import org.gsdh.labs.flocking.Boid;
	import org.gsdh.labs.flocking.Config;
	import org.gsdh.labs.flocking.Controls;
	import org.gsdh.labs.flocking.Shark;
	
	/**
	 * @author Chris Truter
	 */
	public class Main extends Sprite
	{
		private var _shark:Shark;
		private var _boids:Vector.<Boid>;
		private var _bmp:BitmapData;
		private var _filter1:BitmapFilter;
		private var _filter2:BitmapFilter;
		private var _filter3:BitmapFilter;
		private var _filterRect:Rectangle;
		private var _filterPt:Point;
		private var _perlin:BitmapData;
		
		private var _darken:Shape;
		
		public function Main():void
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.addChild(new Controls);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			mouseChildren = false;
			
			//graphics.lineStyle(1, 0x0, .5);
			//graphics.drawRect(.5, .5, stage.stageWidth - 1.5, stage.stageHeight - 1.5);
			
			//stage.addChild(new Stats);
			
			_bmp = new BitmapData(stage.stageWidth, stage.stageHeight, true, 0xffffffff);
			addChild(new Bitmap(_bmp));
			
			_shark = new Shark;
			_shark.x = stage.stageWidth * .5;
			_shark.y = stage.stageHeight * .5;
			addChild(_shark);
			
			_filter1 = new ColorMatrixFilter([.8, .2, 0, 0, 0, .2, .8, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, .7, 0]);
			_filter2 = new ColorMatrixFilter([1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, .6, 0]);
			_filter3 = new BlurFilter(2,2);
			
			_filterRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			_filterPt = new Point;
			
			_boids = new Vector.<Boid>;
			for (var i:int = 0; i < 100; i++)
			{
				var boid:Boid = new Boid;
				boid.x = stage.stageWidth * Math.random();
				boid.y = stage.stageHeight * Math.random();
				_boids[i] = boid;
				addChild(boid);
			}
			
			drawDisabledOverlay();
			
			stage.addChild(_darken);
			_darken.visible = false;
			
			stage.addEventListener(Event.MOUSE_LEAVE, handleOut);
			stage.addEventListener(MouseEvent.ROLL_OUT, handleOut);
			stage.addEventListener(MouseEvent.MOUSE_OVER, handleOver);
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			
			//if (hitTestPoint(mouseX, mouseY))
				//addEventListener(Event.ENTER_FRAME, handleEnterFrame);
			//else
			for (i = 0; i < 50; i++)
				handleEnterFrame(null);
			
			handleOut(null);
		}
		
		private function handleMouseDown(e:MouseEvent):void
		{
			Config.MOUSE_DOWN = true;
		}
		
		private function handleMouseUp(e:MouseEvent):void
		{
			Config.MOUSE_DOWN = false;
		}
		
		private function drawDisabledOverlay():void
		{
			_darken = new Shape;
			_darken.graphics.beginFill(0x222222, .8);
			_darken.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			_darken.graphics.endFill();
			
			//_darken.graphics.beginFill(0x333333, .6);
			var offX:Number = stage.stageWidth * .5 + .5;
			var offY:Number = stage.stageHeight * .5;
			_darken.graphics.lineStyle(15, 0x0, .3, true, "normal", CapsStyle.ROUND, JointStyle.BEVEL);
			_darken.graphics.moveTo( -34 + offX, -51 + offY);
			_darken.graphics.lineTo( 51 + offX, 0 + offY);
			_darken.graphics.lineTo( -34 + offX, 51 + offY);
			_darken.graphics.lineTo( -34 + offX, -51 + offY);
			
			//_darken.graphics.beginFill(0xffffff, .8);
			_darken.graphics.lineStyle(8, 0xffffff, .3, true, "normal", CapsStyle.ROUND, JointStyle.MITER);
			offX = stage.stageWidth * .5;
			offY = stage.stageHeight * .5;
			//_darken.graphics.drawRect(stage.stageWidth * .5 - 20, 80, 20, stage.stageHeight - 160);
			//_darken.graphics.drawRect(stage.stageWidth * .5 + 20, 80, 20, stage.stageHeight - 160);
			_darken.graphics.moveTo( -30 + offX, -45 + offY);
			_darken.graphics.lineTo( 45 + offX, 0 + offY);
			_darken.graphics.lineTo( -30 + offX, 45 + offY);
			_darken.graphics.lineTo( -30 + offX, -45 + offY);
			_darken.graphics.endFill();
			
			_darken.filters = [ new BlurFilter(2,2) ];
		}
		
		private function handleOut(e:Event):void
		{
			Config.MOUSE_DOWN = false;
			stage.frameRate = 1;
			_darken.visible = true;
			while (hasEventListener(Event.ENTER_FRAME))
				removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
		}
		
		private function handleOver(e:MouseEvent):void
		{
			stage.frameRate = 60;
			_darken.visible = false;
			if (!hasEventListener(Event.ENTER_FRAME))
				addEventListener(Event.ENTER_FRAME, handleEnterFrame);
		}
		
		private function handleEnterFrame(e:Event):void
		{
			_shark.update(_boids);
			for (var i:int = 0 ; i < _boids.length; i++)
				_boids[i].update(_boids.slice(i + 1), _shark);
			
			var _vec:Array = [];
			for (i = 0; i < _boids.length; i++)
				_vec[i] = _boids[i];
			
			_vec.push(_shark);
			_vec = _vec.sortOn("z", Array.NUMERIC | Array.DESCENDING );
			for (i = 0; i < _vec.length; i++)
				setChildIndex(_vec[i], numChildren - 1);
				
				
			//z += ( -(mouseY / stage.stageHeight * 2) * 100 - z) * .1;
			
			//rotationZ += (Math.sin(getTimer() * .00001) * 360 - rotationZ) * .1;
			
			_bmp.applyFilter(_bmp, _filterRect, _filterPt, _filter1);
			_bmp.draw(this);
			_bmp.applyFilter(_bmp, _filterRect, _filterPt, _filter2);
			_bmp.applyFilter(_bmp, _filterRect, _filterPt, _filter3);
		}
		
		private function zSort():void
		{
			
		}
	}
}