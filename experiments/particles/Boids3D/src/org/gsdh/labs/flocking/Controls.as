package org.gsdh.labs.flocking
{
	import com.bit101.components.HBox;
	import com.bit101.components.HRangeSlider;
	import com.bit101.components.Label;
	import com.bit101.components.RadioButton;
	import com.bit101.components.VBox;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	/**
	 * @author Chris Truter
	 */
	public class Controls extends Sprite
	{
		private var _boidsButtons:Vector.<RadioButton>;
		private var _socialButtons:Vector.<RadioButton>;
		private var _sharkButtons:Vector.<RadioButton>;
		private var _slider:HRangeSlider;
		
		public function Controls()
		{
			var vBox:VBox = new VBox(this);
			vBox.spacing = 25;
			addChild(vBox);
			
			var hBox:HBox = new HBox(vBox);
			hBox.spacing = 15;
			
			hBox.x = 10;
			
			var box3:VBox = new VBox(hBox, 0, 0);
			var btnShark1:RadioButton = new RadioButton(box3, 0,0, "Shark is hungry", true, handleSharkControls);
			var btnShark2:RadioButton = new RadioButton(box3, 0, 0, "Shark is tasty", false, handleSharkControls);
			var btnShark3:RadioButton = new RadioButton(box3, 0, 0, "Shark is aloof", false, handleSharkControls);
			btnShark1.groupName = "shark";
			btnShark2.groupName = "shark";
			btnShark3.groupName = "shark";
			_sharkButtons = Vector.<RadioButton>([ btnShark1, btnShark2, btnShark3 ]);
			
			var box2:VBox = new VBox(hBox, 0, 0);
			var btnSocial1:RadioButton = new RadioButton(box2, 0,0, "Boids are communist", true, handleSocialControls);
			var btnSocial2:RadioButton = new RadioButton(box2, 0, 0, "Boids are monarchist", false, handleSocialControls);
			var btnSocial3:RadioButton = new RadioButton(box2, 0, 0, "Boids are anrachist", false, handleSocialControls);
			btnSocial1.groupName = "social";
			btnSocial2.groupName = "social";
			btnSocial3.groupName = "social";
			_socialButtons = Vector.<RadioButton>([ btnSocial1, btnSocial2, btnSocial3]);
			
			//var box:VBox = new VBox(hBox, 0, 0);
			//var btnBoid1:RadioButton = new RadioButton(box, 0,0, "Boids are skittish", true, handleBoidControls);
			//var btnBoid2:RadioButton = new RadioButton(box, 0, 0, "Boids are pirhanas", false, handleBoidControls);
			//var btnBoid3:RadioButton = new RadioButton(box, 0,0, "Boids are too cool", false, handleBoidControls);
			//btnBoid1.groupName = "boid";
			//btnBoid2.groupName = "boid";
			//btnBoid3.groupName = "boid";
			//_boidsButtons = Vector.<RadioButton>([ btnBoid1, btnBoid2, btnBoid3 ]);
			
			var box4:HBox = new HBox(vBox);
			
			var label:Label = new Label(box4, 0, 0, "Range finder");
			label.y -= 6;
			
			_slider = new HRangeSlider(box4, 0, 0, handleRangeControl);
			_slider.maximum = 250;
			_slider.width = 150;
			
			_slider.highValue = 180;
			_slider.lowValue = 140;
			
			visible = false;
			addEventListener(Event.ENTER_FRAME, handleEnterFrame);
		}
		
		private function handleRangeControl(e:Event):void
		{
			Config.BOID_SHARK_LOWER_DIST = _slider.lowValue;
			Config.BOID_SHARK_UPPER_DIST = _slider.highValue
		}
		
		private function handleEnterFrame(e:Event):void
		{
			if (width < 200)
				return;
				
			visible = true;
			
			x = int((stage.stageWidth - width) * .5) + 3;
			y = int(stage.stageHeight - height - 45);
			
			removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
		}
		
		//private function handleBoidControls(e:MouseEvent):void
		//{
			//Config.BOID_OR_PIRHANA = _boidsButtons.indexOf(e.target);
		//}
		
		private function handleSocialControls(e:MouseEvent):void
		{
			Config.BOID_SOCIABILITY = _socialButtons.indexOf(e.target);
		}
		
		private function handleSharkControls(e:MouseEvent):void
		{
			Config.SHARK_OR_PLANKTON = _sharkButtons.indexOf(e.target);
		}
	}
}