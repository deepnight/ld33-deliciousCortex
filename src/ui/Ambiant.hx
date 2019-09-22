package ui;

import en.*;

class Ambiant extends dn.Process {
	public static var ALL : Array<Ambiant> = [];
	public function new(e:Entity, str:String) {
		ALL.push(this);

		super(Game.ME);

		var col =
			e.is(en.Human) ? 0x5C85CF :
			e.is(en.Minion) ? 0x63A642 :
			0xEC2025;

		Game.ME.scroller.add(root, Const.DP_UI);

		var tf = Assets.createField(str, col, 120);
		root.addChild(tf);
		tf.x = 5;
		tf.y = 3;
		tf.filters = [
			new flash.filters.GlowFilter(0x0,0.8, 2,2,6),
		];

		tw.create(root.alpha, 0>1, 300);
		tw.create(root.scaleY, 0.1>1, 200);

		cd.set("alive", Const.seconds(1.5));

		var dx = rnd(0,5,true);
		var dy = rnd(0,5,true);
		createChildProcess( function(_) {
			if( !cd.has("alive") )
				hide();

			root.x = Std.int(e.xx - root.width*0.5 + dx);
			root.y = Std.int(e.yy - root.height - 25 + dy);
		}, true);
	}

	function hide() {
		if( !cd.hasSet("hiding",9999) )
			tw.create(root.alpha, 0).end( destroy );
	}

	override function onDispose() {
		super.onDispose();
		ALL.remove(this);
	}

	public static function on(e:Entity, ?str:String, ?a:Array<String>) {
		if( str!=null )
			new ui.Ambiant(e, str);
		else
			new ui.Ambiant(e, a[Std.random(a.length)]);
	}
}