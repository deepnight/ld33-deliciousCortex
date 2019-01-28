package en;

import mt.deepnight.Lib;
import mt.deepnight.slb.*;
import mt.MLib;

import mt.flash.Key;

class Tomb extends Entity {
	static var IDX = 0;
	var active		: Bool;
	public function new(x,y) {
		super(x,y);
		IDX++;
		weight = 0;
		active = true;
		spr.set("tomb", IDX%Assets.tiles.countFrames("tomb"));
		spr.setCenterRatio(0.5,0.9);
		shadow.visible = false;
		shadow.scaleX = 2;
		shadow.scaleY = 2;
		spr.filters = [];
	}

	override function unregister() {
		super.unregister();
	}

	override public function render() {
		super.render();
		if( cd.has("shake") )
			spr.x += Math.cos(time*10)*1 * cd.get("shake")/cd.getInitialValue("shake");
	}

	override public function update() {
		super.update();
		if( active && distanceCaseSqr(hero)<=2*2 && canSee(hero) ) {
			active = false;
			cd.set("shake", Const.seconds(1.5));
			var d =
				level.hasAnyCollision(cx,cy+1) ? -1 :
				level.hasAnyCollision(cx,cy-1) ? 1 :
				hero.cy>cy ? -1 : 1;
			Game.ME.spawnPack(cx, cy+d, 2, true, true);
			spr.set("tombBroken", spr.frame);
			fx.stoneExplosion(this);
			Assets.SBANK.tomb(rnd(0.6, 0.85));
			Game.ME.delayer.add( function() {
				Assets.SBANK.zombies01(0.15);
			}, rnd(200,400));
		}

		if( active )
			fx.tomb(this);
	}
}