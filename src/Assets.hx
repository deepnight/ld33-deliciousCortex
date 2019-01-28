import mt.deepnight.slb.*;
import mt.deepnight.slb.assets.TexturePacker;
import mt.flash.Sfx;
import mt.MLib;
import mt.flash.Sfx;

class Assets {
	public static var tiles		: BLib;
	public static var SBANK		= Sfx.importDirectory("assets/sounds");

		public static var music : Sfx;

	public static function init() {
		tiles = TexturePacker.importXml("assets/tiles.xml");
		//tiles.defineAnim("zombieWalk", "0-5(3)");
		//tiles.defineAnim("zombieWalk", "0-5(4)");
		//tiles.defineAnim("zombieIdle", "0(35), 1(45)");
		tiles.defineAnim("standerShoot",	"0(4), 1(3), 2(6)");
		tiles.defineAnim("humanShoot",	"0(4), 1(3), 2(6)");
		tiles.defineAnim("humanWalk",	"0(2), 1(3), 0(1), 2(2), 3(3), 2(1)");
		tiles.defineAnim("kingIdle",	"0(20), 1(28), 0(25), 1(31), 0(20), 1(28), 2(35)");
		tiles.defineAnim("kingWalk",	"0(4), 1(2), 2(2), 3(1), 4(4), 5(2), 6(2)");
		tiles.defineAnim("zombieWalk",	"0(4), 1(2), 2(2), 3(1), 4(4), 5(2), 6(2)");
		tiles.defineAnim("zombieRun",	"0(3), 1(1), 2(2), 3(3), 4(1), 5(2)");
		tiles.defineAnim("zombieAttack", "0(2), 1(1), 2(3), 3(5)");
		tiles.defineAnim("flag", "0-3(5)");
		tiles.defineAnim("torch", "0-3(2)");

		Sfx.setChannelVolume(1,0.5);
		music = SBANK.music();
		music.setChannel(1);
	}

	public static function startMusic() {
		music.playLoop();
		music.initBeatTimer(60/120);
	}

	public static function createField(str:String, ?col=0xFFFFFF, ?maxWid=0.) {
		var f = new flash.text.TextFormat("assets.alterebro-pixel-font.ttf", 16, col);
		f.leading = -2;
		var tf = new flash.text.TextField();
		tf.sharpness = 800;
		tf.setTextFormat(f);
		tf.embedFonts = true;
		tf.defaultTextFormat = f;
		tf.mouseEnabled = tf.selectable = false;
		var ml = maxWid>0;
		tf.wordWrap = tf.multiline = ml;
		tf.text = Std.string(str);
		if( ml ) {
			tf.width = maxWid;
			tf.height = 300;
		}
		tf.width = tf.textWidth+5;
		tf.height = tf.textHeight+5;
		tf.backgroundColor = 0x0080FF;
		return tf;
	}
}
