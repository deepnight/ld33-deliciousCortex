class Intro extends dn.Process {

	public var buffer(get,never)	: Buffer; inline function get_buffer() return Main.ME.buffer;
	var logo		: BSprite;
	var mask		: Bitmap;
	var teint		: Bitmap;
	var ready		: Bool;

	public function new() {
		super();
		ready = false;

		buffer.addChild(root);

		Assets.startMusic();

		logo = Assets.tiles.get("logo");
		root.addChild(logo);

		var w = new flash.display.Sprite();
		root.addChild(w);
		w.alpha = 0;

		var tf = Assets.createField("A 48h game by Sebastien Benard");
		w.addChild(tf);
		tf.textColor = 0x9F5FA5;
		tf.x = buffer.width*0.5 - tf.width*0.5;
		tf.y = 180;
		var tf = Assets.createField("Twitter: @deepnightFR");
		w.addChild(tf);
		tf.textColor = 0x603863;
		tf.x = buffer.width*0.5 - tf.width*0.5;
		tf.y = 200;
		var tf = Assets.createField("www.deepnight.net");
		w.addChild(tf);
		tf.textColor = 0x603863;
		tf.x = buffer.width*0.5 - tf.width*0.5;
		tf.y = 210;

		mask = new flash.display.Bitmap( buffer.createSimilarBitmap(false) );
		root.addChild(mask);
		mask.bitmapData.fillRect(mask.bitmapData.rect, alpha(0x0));
		tw.create(mask.alpha, 1>0, 1500);

		var tf = Assets.createField("Click to start");
		root.addChild(tf);
		tf.textColor = 0xFFFFFF;
		tf.x = buffer.width*0.5 - tf.width*0.5;
		tf.y = 150;
		tf.alpha = 0;
		delayer.add( function() {
			var t = 0;
			createChildProcess( function(_) {
				if( cd.has("end") )
					tf.alpha*=0.9;
				else {
					tf.alpha = MLib.fabs( Math.cos(t*0.1) );
					t++;
				}
			});
		}, 3500);

		teint = new flash.display.Bitmap( buffer.createSimilarBitmap(false) );
		root.addChild(teint);
		teint.bitmapData.fillRect(teint.bitmapData.rect, alpha(0x056135));
		teint.blendMode = OVERLAY;
		delayer.add( function() {
			tw.create(teint.alpha, 1>0, 2000);
		}, 1000);
		Assets.SBANK.zombies01(0.15);

		delayer.add( function() {
			ready = true;
			tw.create(w.alpha, 0>1, 1500);
		}, 2500);

		flash.Lib.current.stage.addEventListener( flash.events.MouseEvent.CLICK, onClick );

		var dy = 0.;
		var b = false;
		createChildProcess(function(_) {
			if( Assets.music.isBeatFrame() ) {
				dy = b ? -0.8 : -1.6;
				b = !b;
			}
			logo.y+=dy;
			dy+=0.6;
			if( logo.y>=0 ) {
				logo.y = 0;
				dy = 0;
			}
		});
	}

	function onClick(_) {
		if( ready && !cd.hasSet("end",9999) ) {
			Assets.SBANK.start(1);
			tw.completeAll();
			tw.create(teint.alpha, 0>1, 600);
			tw.create(mask.alpha, 0>1, 2500);
			delayer.add( function() {
				new Game();
				destroy();
			}, 2500);
		}
	}

	override function onDispose() {
		flash.Lib.current.stage.removeEventListener( flash.events.MouseEvent.CLICK, onClick );

		super.onDispose();

		logo.dispose();
		logo = null;

		mask.bitmapData.dispose();
		mask.bitmapData = null;
		teint.bitmapData.dispose();
		teint.bitmapData = null;
	}
}