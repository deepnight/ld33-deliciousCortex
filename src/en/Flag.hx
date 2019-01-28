package en;

import mt.deepnight.Lib;
import mt.deepnight.slb.*;
import mt.MLib;

import mt.flash.Key;

class Flag extends Entity {
	public function new() {
		super(4,4);
		weight = 0;
		spr.a.playAndLoop("flag");
		spr.alpha = 0;
	}

	override function unregister() {
		super.unregister();
	}

	override public function render() {
		super.render();
		if( hasOwner() ) {
			spr.x+= 4*hero.dir;
			spr.y-=4  + (hero.isWalking() ? Math.cos(time*0.3)*1 : 0);
		}
		shadow.visible = false;
	}

	public inline function hasOwner() return hero.linking && !hero.destroyed;

	override public function update() {
		super.update();
		if( hasOwner() ) {
			dir = hero.dir;
			cx = hero.cx;
			cy = hero.cy;
			xr = hero.xr;
			yr = hero.yr+0.1;
			cd.set("persist", 20);
		}
		else {
			xr = yr = 0.5;
			dir = 1;
		}
		if( !hasOwner() && !cd.has("persist") )
			spr.alpha = MLib.fclamp(spr.alpha-0.05, 0,1);
		else
			spr.alpha = MLib.fclamp(spr.alpha+0.1, 0,1);
	}
}