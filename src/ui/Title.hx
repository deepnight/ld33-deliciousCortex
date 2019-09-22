package ui;

class Title extends dn.Process {
	var bg			: HSprite;
	public function new(str:String) {
		super(Game.ME);

		Game.ME.buffer.add(root, Const.DP_TOP);

		bg = Assets.tiles.get("place",root);

		var tf = Assets.createField(str, 0xFF9900, 120);
		root.addChild(tf);
		tf.x = bg.width*0.5 - tf.width*0.5 + 4;
		tf.y = bg.height*0.5 - tf.height*0.5 + 3;
		tf.filters = [
			new flash.filters.DropShadowFilter(1,90, 0xFFFF00,1, 0,0,1, 1,true),
			//new flash.filters.GlowFilter(0xBB3D00,1, 2,2,6),
		];

		root.filters = [
			new flash.filters.GlowFilter(0x6A0500,1, 2,2,6),
			//new flash.filters.GlowFilter(0x401A00,1, 16,16,2),
		];

		tw.create(root.alpha, 0>1, 300);

		var x = Game.ME.buffer.width*0.5 - root.width*0.5;
		root.y = Game.ME.buffer.height*0.5 - root.height*0.5;
		Assets.SBANK.wind01().play(0.4, 0.75);
		tw.create(root.x, Game.ME.buffer.width>x, 400).end( function() {
			Assets.SBANK.atk01(0.4);
			delayer.add( Assets.SBANK.newLevel.bind(0.5), 100 );
			var ct = new flash.geom.ColorTransform(1,1,1);
			tw.create(ct.redOffset, 255>0, TEaseIn, 300).update( function() {
				ct.blueOffset = ct.greenOffset = ct.redOffset;
				root.transform.colorTransform = ct;
			});
		});

		delayer.add( hide, 3000);
	}

	function hide() {
		if( !cd.hasSet("hiding",9999) )
			tw.create(root.alpha, 0).end( destroy );
	}
}