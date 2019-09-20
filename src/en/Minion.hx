package en;

class Minion extends Zombie {
	public static var ALL : Array<Minion> = [];
	public var linked		: Bool;
	var target				: Null<Entity>;

	public function new(x,y) {
		super(x,y);
		ALL.push(this);

		linked = false;
		weight = 1;
		initLife(4);

		spr.a.registerStateAnim("zombieRun",4, function() return isWalking() && isEnraged());
		spr.a.registerStateAnim("zombieWalk",3, function() return isWalking());
		spr.a.registerStateAnim("zombieIdleBack",2, function() return cd.has("left"));
		spr.a.registerStateAnim("zombieIdleUp",1, function() return cd.has("up"));
		spr.a.registerStateAnim("zombieIdle",0);
		spr.a.applyStateAnims();

		var c = Color.randomColor(rnd(0,1), rnd(0.4,0.8), 0.6);
		spr.filters= [
			Color.getColorizeFilter(c, 0.3, 0.7),
			new flash.filters.GlowFilter(0x370606,0.8, 2,2,6),
		];

		cd.set("asleep", 99999);
	}

	function isAsleep() return cd.has("asleep");

	override function unregister() {
		super.unregister();
		ALL.remove(this);
		target = null;
	}

	function enrage() cd.set("rage", Const.seconds(0.5));
	public function isEnraged() return cd.has("rage");


	override public function hit(dmg:Int) {
		super.hit(dmg);
		//mt.flash.Sfx.playOne([
			//Assets.SBANK.zombieHit01,
			//Assets.SBANK.zombieHit02,
			//Assets.SBANK.zombieHit03,
		//], 0.3);
	}

	override public function onDie() {
		super.onDie();
		mt.flash.Sfx.playOne([
			Assets.SBANK.death03,
			Assets.SBANK.death04,
			Assets.SBANK.death05,
		], 0.5);
	}

	override public function onTouch(e:Entity) {
		super.onTouch(e);

		// Another minion reached my destination?
		if( e.is(Minion) && path.length>0 && !isEnraged() ) {
			var t = path[path.length-1];
			if( e.lastReached!=null && e.lastReached.x==t.x && e.lastReached.y==t.y && Lib.distanceSqr(cx, cy, t.x, t.y)<=2*2 ) {
				completePath(t.x, t.y);
			}
		}

		// Attack human
		if( !isStunned() && e.is(Human) && !cd.hasSet("attack", Const.seconds(0.25)) ) {
			Game.ME.fx.hit(this, e);
			e.repelFrom(this,rnd(0,0.25));
			e.hit(1);
			dir = e.xx>xx?1:-1;
			spr.a.play("zombieAttack");
			fx.slash(this,e);
			onAttack();
		}

		// Attack barricade
		if( !linked && !isStunned() && e.is(Barricade) && !cd.hasSet("attack", Const.seconds(0.25)) ) {
			Game.ME.fx.hit(this, e);
			e.hit(1);
			dir = e.xx>xx?1:-1;
			spr.a.play("zombieAttack");
			fx.slash(this,e);
			onAttack();
		}
	}

	function onAttack() {
		if( !Game.ME.cd.hasSet("hitSound",rnd(3,5)) )
			mt.flash.Sfx.playOne([
				Assets.SBANK.atk01,
				Assets.SBANK.atk02,
				Assets.SBANK.atk03,
				Assets.SBANK.atk04,
			], rnd(0.2,0.35));
	}

	public function link() {
		cd.unset("asleep");
		linked = true;
		target = null;
		cd.unset("rage");
		goto(hero.cx, hero.cy);
		blink(0x2874FF,0.7, 3);
	}

	public function unlink() {
		if( linked )
			linked = false;
	}

	function trackTarget(e:Entity) {
		target = e;
		if( target.is(Human) )
			tryAmbiant("atk", 15, [
				"Liveeer!",
				"RaaAaah...",
				"OooaAargh",
				"Braain!",
				"Kidneeey!",
				"Spinal cord!",
				"Eat humaaan",
				"Ketchup anyone?",
				"Meaaaat!",
				"Proteins!",
				"LuduUum!",
			]);
		if( target.is(Barricade) )
			tryAmbiant("atk", 15, [
				"Eat wooood",
				"Break thiiings",
				"DestroOoy",
				"RaaAaah...",
				"OooaAargh",
			]);
		enrage();
		if( !canSee(target) )
			goto(target.cx, target.cy);
	}

	override public function render() {
		super.render();
		selection.visible = linked;
	}

	override function update() {
		weight = path.length>0 ? 4+rnd(0,2) : 1;

		super.update();

		if( linked && hero.destroyed )
			unlink();

		if( target!=null && target.isDead() )
			target = null;

		speed = isEnraged() ? 0.072 : 0.062;

		// Direction
		if( path.length>0 ) {
			var pt = path[0];
			if( pt.x+0.5>cx+xr ) dir = 1;
			if( pt.x+0.5<cx+xr ) dir = -1;
		}

		// Render path
		if( !cd.hasSet("renderPath",6) ) {
			var g = pathPreview.graphics;
			g.clear();
			if( path.length>0 && !linked ) {
				g.lineStyle(1, 0x0071C4,1);
				g.moveTo(xx,yy);
				for(pt in path)
					g.lineTo( (pt.x+0.5)*Const.GRID, (pt.y+0.5)*Const.GRID );
			}
		}


		if( linked ) {
			var d = Const.GRID*1.5;
			if( distanceSqr(hero)<=d*d ) {
				// Reached hero
				completePath(hero.cx, hero.cy);
			}
			else {
				// Follow hero
				goto(hero.cx, hero.cy);
			}
		}
		else {
			if( !isStunned() && !isAsleep() && !cd.hasSet("track",6) ) {
				// Automatically track humans
				var best = null;
				for(e in en.Human.ALL) {
					if( canSeeInRange(e, 8*Const.GRID) || pathDistanceCheck(e,8) )
						if( best==null || distanceSqr(best)>distanceSqr(e) )
							best= e;
				}
				if( best!=null )
					trackTarget(best);

				// Automatically track barricades
				if( path.length==0 && target==null ) {
					var best = null;
					for(e in en.Barricade.ALL) {
						if( pathDistanceCheck(e,3+10) )
							if( best==null || distanceSqr(best)>distanceSqr(e) )
								best= e;
					}
					if( best!=null )
						trackTarget(best);
				}
			}
		}

		// Follow my enraged friends
		if( !linked && !isEnraged() ) {
			for(e in ALL)
				if( e!=this && e.isEnraged() && e.target!=null && pathDistanceCheck(e,5) )
					trackTarget(e.target);
		}

		// Directly go to the target if in front of me!
		if( target!=null && canSee(target) ) {
			cancelPath();
			var a = Math.atan2(target.yy-yy, target.xx-xx);
			dx+=Math.cos(a)*speed;
			dy+=Math.sin(a)*speed;
			dir = target.xx>xx ? 1 : -1;
		}

		var d = Const.seconds(rnd(0.9, 1.6));
		if( !isWalking() && !cd.hasSet("lookAround", d*2) ) {
			if( Std.random(2)==0 )
				cd.set("up", d);
			else
				cd.set("left", d);
		}
	}
}