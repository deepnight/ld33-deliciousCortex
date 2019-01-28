package en;

import mt.deepnight.Lib;
import mt.deepnight.slb.*;
import mt.MLib;

import mt.flash.Key;

class Zombie extends Entity {
	public static var ALL : Array<Zombie> = [];
	public var selection	: BSprite;

	public function new(x,y) {
		super(x,y);
		ALL.push(this);

		selection = Assets.tiles.get("selection", 0.5,0.5);
		Game.ME.sdm.add(selection, Const.DP_BG);
		selection.filters = [
			new flash.filters.GlowFilter(0x2E268C,0.9, 8,8,4),
		];
		selection.visible = false;
	}

	override public function canBePushed() {
		return super.canBePushed() && !isStunned();
	}

	public function exhume() {
		cd.set("stun", Const.seconds(0.7));
		var a = shadow.alpha;
		tw.create(shadow.alpha, 0>a, 2000);
		tw.create(selection.alpha, 0>a, 2000);
		tw.create(spr.scaleY, 0>1, rnd(800,1500));
		cd.set("exhumeFx", Const.seconds(0.2));
		cd.onComplete("exhumeFx", fx.exhume.bind(this));
	}

	override function unregister() {
		super.unregister();
		ALL.remove(this);
		selection.dispose();
		selection = null;
	}

	override public function render() {
		super.render();
		selection.setPos(spr.x, spr.y);
	}
}