package en;

import mt.deepnight.Lib;
import mt.deepnight.slb.*;
import mt.MLib;

class Walker extends Human {
	var fleeAng			: Null<Float>;
	var baseCx			: Int;
	var baseCy			: Int;

	public function new(x,y) {
		super(x,y);
		baseCx = cx;
		baseCy = cy;

		initLife(35);
		speed*=1.7;
		fleeAng = null;

		spr.a.registerStateAnim("humanWalk", 1, function() return isWalking());
		spr.a.registerStateAnim("humanIdle",0);
		spr.a.applyStateAnims();
	}

	override function onShoot() {
		super.onShoot();
		spr.a.play("humanShoot");
	}

	override function update() {
		super.update();

		// Flee AI
		if( time%6==0 && cd.has("alert") ) {
			fleeAng = null;
			var x = 0.;
			var y = 0.;
			var n = 0;
			for(e in en.Minion.ALL) {
				if( !canSee(e) )
					continue;
				x+=e.xx;
				y+=e.yy;
				n++;
			}
			if( n==0 )
				fleeAng = null;
			else {
				x/=n;
				y/=n;
				//fx.markFree(x,y);
				fleeAng = Math.atan2(yy-y, xx-x);
			}
		}

		if( !cd.has("alert") && time%3==0 ) {
			fleeAng = null;
			//fx.markCase(baseCx, baseCy);
			goto(baseCx, baseCy);
		}

		if( fleeAng!=null ) {
			dx+=Math.cos(fleeAng)*speed;
			dy+=Math.sin(fleeAng)*speed;
		}
	}
}