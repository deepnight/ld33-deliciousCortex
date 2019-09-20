class Main extends dn.Process { //}
	public static var ME : Main;

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
		createRoot(Boot.ME.s2d);

		#if debug
		new Game();
		//new Demo();
		#else
		new Intro();
		#end

		onResize();
	}

	override function onResize() {
		super.onResize();
		Const.UPSCALE = Std.int( flash.Lib.current.stage.stageWidth/320 );
		if( Const.FORCED_UPSCALE>0 )
			Const.UPSCALE = Const.FORCED_UPSCALE;
		root.setScale( Const.UPSCALE );
		// buffer.setTexture( Buffer.makeMosaic2(Const.UPSCALE), 0.5, true );
	}

	override function update() {
		super.update();
	}

	static function mainLoop(_) {
		// Assets.music.updateBeatCounter();
		// mt.flash.Key.update();
		// dn.Process.updateAll(1);
	}

}
