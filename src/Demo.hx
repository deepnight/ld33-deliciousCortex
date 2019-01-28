import mt.deepnight.Buffer;
import mt.deepnight.slb.*;
import mt.MLib;
import mt.flash.Key;
import flash.display.Bitmap;
import mt.deepnight.Tweenie;

class Demo extends mt.deepnight.FProcess {

	public var buffer(get,never)	: Buffer; inline function get_buffer() return Main.ME.buffer;

	var cm				: mt.deepnight.Cinematic;

	public function new() {
		super();

		cm = new mt.deepnight.Cinematic(Const.FPS);
		buffer.addChild(root);

		var s = Assets.tiles.get("humanIdle");
		buffer.addChild(s);
		s.a.setGeneralSpeed(0.75);
		s.setScale(3);
		s.setPos(100,100);
		s.setCenter(0.5,1);

		//s.a.registerStateAnim("humanIdle", 0);
		s.a.registerStateAnim("zombieIdle", 0);
		s.a.applyStateAnims();

		cm.create({
			1000;
			s.a.playAndLoop("zombieWalk");
			2000;
			s.a.stop();
			200;
			tw.create(s.x, s.x+5, TLoop, 300);
			tw.create(s.y, s.y-10, TLoop, 150);
			s.a.play("zombieAttack");
			1000;
			tw.create(s.x, s.x+5, TLoop, 200);
			tw.create(s.y, s.y-5, TLoop, 100);
			s.a.play("zombieAttack");
			700;
			s.a.playAndLoop("zombieWalk");
		});

		//cm.create({
			//1000;
			//s.a.playAndLoop("humanWalk");
			//1000;
			//s.a.stop();
			//200;
			//s.scaleX *= -1;
			//200;
			//s.a.play("humanShoot");
			//1000;
			//s.a.play("humanShoot");
			//700;
			//s.scaleX *= -1;
			//200;
			//s.a.playAndLoop("humanWalk");
		//});
	}

	override function unregister() {
		super.unregister();
	}

	override function update() {
		super.update();
		cm.update();
		Assets.tiles.updateChildren();
	}
}