package ui;
import mt.MLib;
import en.*;

class Say extends FlashProcess {
	public static var CURRENT : Say;
	public function new(e:Entity, str:String) {
		if( CURRENT!=null )
			CURRENT.destroy();
		CURRENT = this;

		super(Game.ME);

		var col =
			e.is(en.Human) ? 0x4B3685 :
			e.is(en.Minion) ? 0x508635 :
			0x9B2023;

		if( e.is(Hero) ) Assets.SBANK.say01(1);
		if( e.is(Human) ) Assets.SBANK.say02(1);

		Game.ME.sdm.add(root, Const.DP_UI);

		var bg = new flash.display.Sprite();
		root.addChild(bg);

		var tf = Assets.createField(str, 0xFFFFFF, 120);
		root.addChild(tf);
		tf.x = 5;
		tf.y = 3;
		tf.filters = [
			new flash.filters.DropShadowFilter(1,90, 0x0,0.5, 0,0),
		];

		var xa = e.xx+Game.ME.scroller.x <= Game.ME.buffer.width*0.5 ? 0.25 : 0.75;
		var dy = rnd(0,10,true);

		bg.graphics.beginFill(col);
		var w = tf.width+tf.x*2;
		var h = Std.int(tf.height+tf.y*2+2);
		bg.graphics.drawRoundRect(0,0, w, h, 4 );
		bg.graphics.moveTo(w*xa, h);
		bg.graphics.lineTo(w*xa,h+4);
		bg.graphics.lineTo(w*xa+4,h);
		bg.filters = [
			new flash.filters.DropShadowFilter(1,-90, mt.deepnight.Color.brightnessInt(col,-0.2), 0.8, 0,0,1, 1,true),
			new flash.filters.GlowFilter(0x0, 0.9, 2,2,5),
		];

		createChildProcess( function(_) {
			if( e.destroyed )
				destroy();
			else {
				root.x = MLib.fclamp(Std.int(e.xx - root.width*xa), 0, Game.ME.level.wid*Const.GRID-root.width);
				root.y = Std.int(e.yy - root.height - 30 + dy);
			}
		}, true);

		tw.create(root.alpha, 0>1, 300);
		tw.create(root.scaleY, 0>1, 200);
	}

	override function onDispose() {
		super.onDispose();
		if( CURRENT==this )
			CURRENT = null;
	}

	public static function clear() {
		if( CURRENT!=null ) {
			CURRENT.destroy();
			CURRENT = null;
		}
	}
	public static function on(e:Entity, str:String) {
		new ui.Say(e,str);
	}
}