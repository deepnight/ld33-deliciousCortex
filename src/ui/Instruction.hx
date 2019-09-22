package ui;

class Instruction extends dn.Process {
	public static var CURRENT : Instruction;
	public function new(str:String) {
		if( CURRENT!=null )
			CURRENT.hide();
		CURRENT = this;

		super(Game.ME);

		var col = 0x1A1830;

		Game.ME.buffer.add(root, Const.DP_UI);

		var bg = new flash.display.Sprite();
		root.addChild(bg);

		var tf = Assets.createField(str, 0xFFFFFF, 250);
		root.addChild(tf);
		tf.x = 5;
		tf.y = 3;
		tf.filters = [
			new flash.filters.DropShadowFilter(1,90, 0x0,0.5, 0,0),
		];

		bg.graphics.beginFill(col);
		var w = tf.width+tf.x*2;
		var h = Std.int(tf.height+tf.y*2+2);
		bg.graphics.drawRoundRect(0,0, w, h, 4 );
		bg.filters = [
			new flash.filters.DropShadowFilter(1,-90, mt.deepnight.Color.brightnessInt(col,-0.2), 0.8, 0,0,1, 1,true),
			new flash.filters.GlowFilter(0xffffff, 1, 2,2,5),
		];

		root.x = Game.ME.buffer.width*0.5 - root.width*0.5;
		var y = Game.ME.buffer.height - root.height - 10;

		tw.create(root.alpha, 0>1, 300);
		tw.create(root.y, -50>y, TEaseOut, 500);

		delayer.add( function() {
			var ct = new flash.geom.ColorTransform(1,1,1);
			tw.create(ct.redOffset, 255>0, 300).update( function() {
				ct.blueOffset = ct.greenOffset = ct.redOffset;
				root.transform.colorTransform = ct;
			});
		}, 200);
	}

	public static function show(str:String) {
		new ui.Instruction(str);
	}

	public static function clear() {
		if( CURRENT!=null ) {
			CURRENT.hide();
			CURRENT = null;
		}
	}

	public function hide() {
		tw.terminateWithoutCallbacks(root.y);
		tw.create(root.y, Game.ME.buffer.height, 400).end(destroy);
	}

	override function onDispose() {
		super.onDispose();
		if( CURRENT==this )
			CURRENT = null;
	}
}