package en;

class Hero extends Zombie {
	public var linking		: Bool;
	var range				: h2d.Object;
	var hitFeedback			: HSprite;

	public function new(x,y) {
		super(x,y);

		linking = false;
		weight = 30;
		speed*=3.6;
		#if debug
		speed*=1.6;
		#end
		initLife(6);

		hitFeedback = Assets.tiles.get("hit");
		hitFeedback.setSize(Game.ME.buffer.width, Game.ME.buffer.height);
		hitFeedback.visible = false;
		Game.ME.buffer.add(hitFeedback, Const.DP_UI);

		range = new h2d.Object();
		Game.ME.scroller.add(range, Const.DP_BG);
		range.graphics.lineStyle(1,0x80FF00,1);
		range.graphics.drawCircle(0,0, Const.COMMAND_RANGE-Const.GRID*0.8);
		//range.blendMode = ADD;

		spr.a.registerStateAnim("kingWalk",3, function() return isWalking());
		//spr.a.registerStateAnim("kingIdleBack",2, function() return cd.has("left"));
		//spr.a.registerStateAnim("kingIdleUp",1, function() return cd.has("up"));
		spr.a.registerStateAnim("kingIdle",0);
		spr.a.applyStateAnims();
	}

	override function unregister() {
		super.unregister();

		hitFeedback.dispose();
		hitFeedback = null;

		range.parent.removeChild(range);
		range = null;
	}

	override public function onTouch(e:Entity) {
		super.onTouch(e);
		if( e.is(Human) ) {
			var e = e.as(Human);
		}
	}

	override public function onDie() {
		super.onDie();
		new ui.Instruction("You \"died\". Press R to resurrect");
		Assets.SBANK.death02(1);
		ui.Status.CURRENT.refresh();
	}

	override public function hit(dmg:Int) {
		super.hit(dmg);
		Assets.SBANK.hit04(1);
		hitFeedback.visible = true;
		tw.create(hitFeedback.alpha, 1>0, TEaseIn, 350).end( function() {
			hitFeedback.visible = false;
		});
		ui.Status.CURRENT.refresh();
	}

	override public function render() {
		super.render();
		range.x = spr.x;
		range.y = spr.y;
		range.visible = !linking && !Game.ME.isLocked();
		#if debug
		range.visible = false;
		#end
		if( range.visible )
			range.alpha = 0.15 + Math.cos(time*0.3)*0.05;
	}

	override function update() {
		super.update();

		var actionKey = Key.isToggled(Key.SPACE) || Key.isToggled(Key.X) || Key.isToggled(Key.E) || Key.isToggled(Key.F);

		if( !isStunned() && !Game.ME.isLocked() ) {
			// Move controls
			if( Key.isDown(Key.LEFT) || Key.isDown(Key.A) || Key.isDown(Key.Q) ) {
				Game.ME.setFlag("move");
				dir = -1;
				dx-=speed;
			}
			if( Key.isDown(Key.RIGHT) || Key.isDown(Key.D) ) {
				Game.ME.setFlag("move");
				dir = 1;
				dx+=speed;
			}
			if( Key.isDown(Key.UP) || Key.isDown(Key.Z) || Key.isDown(Key.W) ) {
				Game.ME.setFlag("move");
				dy-=speed;
			}
			if( Key.isDown(Key.DOWN) || Key.isDown(Key.S) ) {
				Game.ME.setFlag("move");
				dy+=speed;
			}


			if( Game.ME.hasFlag("control") && actionKey ) {
				if( !linking ) {
					// Call followers
					var d = Const.COMMAND_RANGE;
					d*=d;
					for(e in en.Minion.ALL)
						if( distanceSqr(e)<=d && pathDistanceCheck(e,Const.COMMAND_RANGE_CASE*1.5) ) {
							e.link();
							linking = true;
							Game.ME.setFlag("controlDone");
						}
					if( linking )
						Assets.SBANK.select(1);
				}
				else {
					// Release followers
					Assets.SBANK.unselect(1);
					linking = false;
					for(e in en.Minion.ALL)
						e.unlink();
				}
			}
		}

		// Cancel link if minions are dead
		if( linking ) {
			var n = 0;
			for(e in en.Minion.ALL)
				if( !e.destroyed && e.linked ) {
					n++;
					break;
				}
			if( n==0 )
				linking = false;
		}

		// Skip message
		if( ( actionKey || Key.isToggled(Key.ESCAPE) ) && Game.ME.isLocked() )
			Game.ME.cm.signal();

		fx.flies(this);

		//if( Assets.music.isBeatFrame() )
			//blink(0xFFFFFF, 0.5, 2);

		// Idle animation
		//var d = Const.seconds(rnd(0.9, 1.6));
		//if( !Game.ME.isLocked() && !isWalking() && !cd.hasSet("lookAround", d*2) ) {
			//if( Std.random(2)==0 )
				//cd.set("up", d);
			//else
				//cd.set("left", d);
		//}
	}
}