package en;

import mt.deepnight.Lib;
import mt.deepnight.slb.*;
import mt.MLib;

import mt.flash.Key;

class Exit extends Entity {
	public function new(x,y) {
		super(x,y);
		weight = 0;
		spr.set("exit");
		spr.setCenterRatio(0.5,0.5);
		xr = yr = 0.5;
		shadow.visible = false;
		spr.filters = [];
		zpriority = -9999;
	}

	override function unregister() {
		super.unregister();
	}

	override public function render() {
		super.render();
	}

	override public function update() {
		super.update();

		if( distanceCaseSqr(hero)<=1 ) {
			if( en.Human.ALL.length>0 ) {
				if( !cd.hasSet("explain", Const.seconds(6)) )
					new ui.Ambiant(hero, "I shall slain ALL human intruders first.");
			}
			else if( !cd.hasSet("once", 99999) )
				Game.ME.nextLevel();
		}
	}
}