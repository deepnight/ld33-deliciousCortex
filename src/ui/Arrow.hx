package ui;

class Arrow extends dn.Process {
	public static var CURRENT : Arrow;

	var spr 		: mt.deepnight.slb.HSprite;
	var active		: Bool;
	var x			: Float;
	var y			: Float;

	public function new(cx:Float, cy:Float) {
		if( CURRENT!=null )
			CURRENT.hide();
		CURRENT = this;

		super(Game.ME);

		cx = Std.int(cx);
		cy = Std.int(cy);

		active = false;
		Game.ME.scroller.add(root, Const.DP_UI);

		spr = Assets.tiles.get("arrow", root);
		spr.setCenterRatio(0.5,1);
		spr.filters = [ new flash.filters.GlowFilter(0x0,0.8, 2,2,6) ];
		x = (cx+0.5)*Const.GRID;
		y = (cy+0.5)*Const.GRID;
		root.x = x;
		tw.create(root.y, y-500>y, 400).end( function() {
			active = true;
		});
	}

	public static function at(cx,cy) {
		new ui.Arrow(cx,cy);
	}

	public static function clear() {
		if( CURRENT!=null ) {
			CURRENT.hide();
			CURRENT = null;
		}
	}

	public function hide() {
		tw.terminateWithoutCallbacks(root.y);
		tw.create(root.y, root.y-30, 400);
		tw.create(root.alpha, 0, 400).end(destroy);
	}

	override function onDispose() {
		super.onDispose();
		if( CURRENT==this )
			CURRENT = null;

		spr.dispose();
		spr = null;
	}

	public static function on(e:Entity, str:String) {
		new ui.Say(e,str);
	}

	override function update(dt) {
		super.update(dt);
		if( active ) {
			root.y = y-mt.MLib.fabs(Math.cos(time*0.1)*10);
		}
	}
}