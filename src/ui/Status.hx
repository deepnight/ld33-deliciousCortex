package ui;

class Status extends dn.Process {
	public static var CURRENT : Status;
	var bar				: Bitmap;
	public function new() {
		CURRENT = this;
		super(Game.ME);

		Game.ME.buffer.add(root, Const.DP_UI);

		bar = new flash.display.Bitmap( new flash.display.BitmapData(40,3,true,0x0) );
		root.addChild(bar);
		bar.filters = [
			new flash.filters.DropShadowFilter(1,-90, 0x0,0.4, 0,0,1, 1,true),
			new flash.filters.GlowFilter(0x0,1, 2,2,6),
		];
		refresh();
		onResize();
	}

	public function refresh() {
		if( Game.ME.hero==null )
			return;

		var bd = bar.bitmapData;
		bd.fillRect(bd.rect, alpha(0x0));
		bd.fillRect(new flash.geom.Rectangle(0,0,bd.width*(Game.ME.hero.life/Game.ME.hero.maxLife), bd.height), alpha(0xD12001));

		onResize();
	}

	override function onDispose() {
		super.onDispose();
		if( CURRENT==this )
			CURRENT = null;
	}

	override function onResize() {
		super.onResize();
		root.x = Std.int(Game.ME.buffer.width*0.5 - root.width*0.5);
		root.y = Std.int(5);
	}
}