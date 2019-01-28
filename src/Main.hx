import mt.deepnight.Buffer;

class Main extends mt.Process { //}
	public static var ME : Main;

	public var buffer		: Buffer;

	static function main() {
		Assets.init();
		new Main();
		flash.Lib.current.addEventListener( flash.events.Event.ENTER_FRAME, mainLoop );
		haxe.Log.setColor(0xFFFF00);
		flash.Lib.current.stage.color = 0x555555;
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
	}

	public function new() {
		super();

		ME = this;

		buffer = new Buffer(320,240, Const.UPSCALE, false, 0x0);
		flash.Lib.current.addChild(buffer.render);
		buffer.drawQuality = flash.display.StageQuality.LOW;

		#if debug
		new Game();
		//new Demo();
		#else
		new Intro();
		#end

		onResize();

		#if debug
		var e = new mt.flash.Stats();
		flash.Lib.current.addChild(e);
		#end
	}

	override function onResize() {
		super.onResize();
		Const.UPSCALE = Std.int( flash.Lib.current.stage.stageWidth/320 );
		if( Const.FORCED_UPSCALE>0 )
			Const.UPSCALE = Const.FORCED_UPSCALE;
		buffer.setScale( Const.UPSCALE );
		buffer.setTexture( Buffer.makeMosaic2(Const.UPSCALE), 0.5, true );
	}

	override function update(dt) {
		super.update(dt);
		buffer.update();
	}

	static function mainLoop(_) {
		Assets.music.updateBeatCounter();
		mt.flash.Key.update();
		mt.Process.updateAll(1);
	}

}
