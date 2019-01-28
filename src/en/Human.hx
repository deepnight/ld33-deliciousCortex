package en;

import mt.deepnight.Lib;
import mt.deepnight.slb.*;
import mt.MLib;

import mt.flash.Key;

class Human extends Entity {
	public static var ALL : Array<Human> = [];


	private function new(x,y) {
		super(x,y);
		ALL.push(this);

		weight = 25;
		dir = Std.random(2)*2-1;
	}

	public static function closestTo(t:Entity) {
		var best : Human = null;
		for(e in ALL)
			if( !e.destroyed && ( best==null || e.distanceSqr(t)<best.distanceSqr(t) ) )
				best = e;
		return best;
	}

	override function unregister() {
		super.unregister();
		ALL.remove(this);
	}

	override public function hit(d) {
		super.hit(d);

		if( level.lid==0 && !Game.ME.doOnce("attackDone") ) {
			if( !cd.hasSet("shout",rnd(7,10)) )
				Game.ME.delayer.add( mt.flash.Sfx.playOne.bind([
					Assets.SBANK.hit01,
					Assets.SBANK.hit02,
					Assets.SBANK.hit03,
				], 0.2), 100 );

			ui.Instruction.clear();
			ui.Arrow.clear();
		}
	}

	override public function onDie() {
		super.onDie();
		Assets.SBANK.death01(1);
		ui.Ambiant.on(this, [
			"Noooo!",
			"Arrrgh!!",
			"I can't...",
			"HEELP M...!!",
			"AAARRgggblbl...",
		]);
	}

	function onShoot() {
	}

	override function update() {
		super.update();

		if( !isStunned() && !Game.ME.isLocked() && !cd.has("shoot") ) {
			function getScore(e:Entity) {
				return distanceSqr(e) * e.life/e.maxLife;
			}
			var best : en.Zombie = null;
			var d = Const.GRID*6;
			for(e in en.Zombie.ALL) {
				if( e.destroyed )
					continue;
				if( canSee(e) && distanceSqr(e)<=d*d && ( best==null || getScore(e)<getScore(best) ) )
					best = e;
			}

			if( best!=null ) {
				if( life>5 )
					tryAmbiant("shoot", 40, [
						"Zombies!",
						"Attack!",
						"Fire!",
						"FIRE!!",
						"Hold this position!",
						"Incoming!!",
						"Monsters!!",
						"OMG!",
					]);
				Game.ME.fx.shoot(this,best);
				Game.ME.fx.hit(this,best);
				best.repelFrom(this,1);
				best.stun( rnd(3,5) );
				best.hit(1);
				dir = best.xx>xx ? 1 : -1;
				cd.set("shoot", Const.seconds(0.7*rnd(0.9, 1.1)));
				cd.set("alert", cd.get("shoot")+30);
				mt.flash.Sfx.playOne([
					Assets.SBANK.bow01,
					Assets.SBANK.bow02,
					Assets.SBANK.bow03,
				], 0.3);
				onShoot();
			}
		}
	}
}