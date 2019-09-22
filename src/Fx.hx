import dn.heaps.HParticle;

import en.*;
import Const;

class Fx extends dn.Process {
	var wrapper			: h2d.Object;
	var game(get,never)	: Game; inline function get_game() return Game.ME;
	var parts			: Array<FParticle>;
	var bpool			: BitmapDataPool;

	public function new(p:dn.Process, wrapper:h2d.Object) {
		super(p);
		this.wrapper = wrapper;

		parts = FParticle.initPool(wrapper, 500);
		bpool = new mt.deepnight.BitmapDataPool();

		bpool.addBitmapData( "slash", Assets.tiles.getBitmapData("fxSlash") );

		var c = bpool.createCanvas("mark", 32,32);
		c.circle(8,0xFFCC00);
		c.filter( new flash.filters.GlowFilter(0xFF6000,0.5, 8,8,4,2) );

		var c = bpool.createCanvas("blood", 4,4);
		c.dot(1,0xFF0000);
		c.filter( new flash.filters.GlowFilter(0x660000,1, 2,2,4) );

		var c = bpool.createCanvas("gblood", 4,4);
		c.dot(1,0x53EF25);
		c.filter( new flash.filters.GlowFilter(0x103027,1, 2,2,4) );

		var c = bpool.createCanvas("bone", 6,4);
		c.line(3,0xDFCAAA);
		c.filter( new flash.filters.GlowFilter(0x2C2110,0.8, 2,2,4) );

		var c = bpool.createCanvas("plank", 6,4);
		c.box(5,2,0x7B3817);
		c.filter( new flash.filters.GlowFilter(0x371A0B,0.8, 2,2,4) );

		var c = bpool.createCanvas("wood", 6,4);
		c.line(2,0xB75322);
		c.filter( new flash.filters.GlowFilter(0x371A0B,0.8, 2,2,4) );

		var c = bpool.createCanvas("stone", 6,6);
		c.box(2,2,0x6399C5);
		c.filter( new flash.filters.DropShadowFilter(1,-90, 0x0,0.15, 0,0,1, 1,true) );
		c.filter( new flash.filters.GlowFilter(0x1A3144,0.8, 2,2,4) );
	}

	public function clear() {
		for( p in parts )
			p.kill();
	}

	override function onDispose() {
		super.onDispose();

		wrapper.parent.removeChild(wrapper);
		wrapper = null;

		bpool.destroy();
		bpool = null;

		for(p in parts)
			p.dispose();
		parts = null;
	}


	public function alloc(x:Float, y:Float) {
		var p = FParticle.allocFromPool(parts, x,y);
		if( p.parent!=wrapper )
			wrapper.addChild(p);
		return p;
	}

	public function allocBmp(id:String, x:Float, y:Float) {
		var p = FParticle.allocFromPool(parts, x,y);
		p.useBitmapData(bpool.get(id), false);
		if( p.parent!=wrapper )
			wrapper.addChild(p);
		return p;
	}

	function sendToBg(p:FParticle) {
		Game.ME.scroller.add(p, Const.DP_BG);
	}

	public function death(e:Entity) {
		for(i in 0...35) {
			var p = allocBmp(e.is(Human)?"blood":"gblood", e.xx+rnd(0,5,true), e.yy-rnd(0,10));
			p.alpha = rnd(0.5,1);
			p.blendMode = NORMAL;
			p.dx = rnd(0,1,true);
			p.dy = -rnd(1,6);
			p.gy = rnd(0.1,0.2);
			p.frict = 0.96;
			p.life = rnd(90,200);
			p.groundY = e.yy+rnd(0,8,true);
			p.onBounce = function() {
				p.dr = 0;
				p.gy = p.dx = p.dy = 0;
				p.rotation = 0;
			}
			p.bounceMul = 0;
			sendToBg(p);
		}
		for(i in 0...20) {
			var p = allocBmp("bone", e.xx+rnd(0,5,true), e.yy-rnd(0,10));
			p.blendMode = NORMAL;
			p.alpha = rnd(0.3,1);
			p.scaleX = rnd(0.5,1);
			p.dx = rnd(0,0.7,true);
			p.dy = -rnd(2,4);
			p.rotation = rnd(0,360);
			p.dr = rnd(0,15,true);
			p.gy = rnd(0.1,0.2);
			p.frict = 0.96;
			p.life = rnd(90,200);
			p.groundY = e.yy+rnd(0,8,true);
			var n = 0;
			p.onBounce = function() {
				if( n>=2 ) {
					p.dr = 0;
					p.gy = p.dx = p.dy = 0;
				}
				p.rotation = 0;
				n++;
			}
			p.bounceMul = 0.8;
			sendToBg(p);
		}
	}

	public function stoneExplosion(e:Entity) {
		for(i in 0...35) {
			var p = allocBmp("stone", e.xx+rnd(0,5,true), e.yy-rnd(0,10));
			p.alpha = rnd(0.4,1);
			p.alpha = rnd(0.5,1);
			p.blendMode = NORMAL;
			p.rotation = rnd(0,360);
			p.dr = rnd(5,30,true);
			p.dx = rnd(0,1.5,true);
			p.dy = -rnd(1,3);
			p.gy = rnd(0.1,0.2);
			p.frict = 0.96;
			p.life = rnd(200,400);
			p.groundY = e.yy+rnd(0,8,true);
			p.onBounce = function() {
				p.dr = 0;
				p.gy = p.dx = p.dy = 0;
				//p.rotation = 0;
			}
			p.bounceMul = 0;
			sendToBg(p);
		}
	}

	public function woodExplosion(e:Entity) {
		for(i in 0...40) {
			var p = allocBmp("wood", e.xx+rnd(0,5,true), e.yy-rnd(0,10));
			p.alpha = rnd(0.5,1);
			p.blendMode = NORMAL;
			p.dx = rnd(0,1,true);
			p.dy = -rnd(1,6);
			p.dr = rnd(10,30,true);
			p.rotation = rnd(0,360);
			p.gy = rnd(0.1,0.2);
			p.frict = 0.96;
			p.life = rnd(500,600);
			p.groundY = e.yy+rnd(0,8,true);
			p.onBounce = function() {
				p.dr = 0;
				p.gy = p.dx = p.dy = 0;
				p.rotation = 0;
			}
			p.bounceMul = 0;
			sendToBg(p);
		}
		for(i in 0...20) {
			var p = allocBmp("plank", e.xx+rnd(0,5,true), e.yy-rnd(0,10));
			p.blendMode = NORMAL;
			p.alpha = rnd(0.3,1);
			p.scaleX = rnd(0.5,1);
			p.scaleY = rnd(0.5,1);
			p.dx = rnd(0,0.7,true);
			p.dy = -rnd(2,4);
			p.rotation = rnd(0,360);
			p.dr = rnd(0,15,true);
			p.gy = rnd(0.1,0.2);
			p.frict = 0.96;
			p.life = rnd(500,600);
			p.groundY = e.yy+rnd(0,8,true);
			var n = 0;
			p.onBounce = function() {
				if( n>=2 ) {
					p.dr = 0;
					p.gy = p.dx = p.dy = 0;
				}
				p.rotation = 0;
				n++;
			}
			p.bounceMul = 0.8;
			sendToBg(p);
		}
	}

	public function hit(from:Entity, e:Entity) {
		var k = e.is(Human)?"blood":e.is(Zombie)?"gblood":"wood";
		for(i in 0...4) {
			var p = allocBmp(k, e.xx+rnd(0,5,true), e.yy-rnd(0,10));
			p.blendMode = NORMAL;
			p.dx = rnd(0,1) * (from.xx>e.xx?-1:1);
			p.dy = -rnd(0,1);
			//p.rotation = rnd(0,360);
			//p.dr = rnd(0,15,true);
			p.gy = rnd(0,0.1);
			p.frict = 0.96;
			p.life = rnd(50,95);
			p.groundY = e.yy+rnd(0,8,true);
			p.onBounce = function() {
				p.dr = 0;
				p.gy = p.dx = p.dy = 0;
				p.rotation = 0;
			}
			p.bounceMul = 0;
		}
	}

	public function highlight(e:Entity) {
		bpool.initIfNeeded("highlight", 32,32, function(c) {
			c.circle(8, 0x48A4FF,1);
			c.filter( new flash.filters.GlowFilter(0x182BAB,1, 8,8,3,2) );
		});
		for(i in 0...4) {
			var p = allocBmp("highlight", e.xx, e.yy);
			p.fadeIn(0.1,0.06);
			p.scaleY = 0.5;
			p.fadeOutSpeed = 0.02;
			p.life = 4;
		}
	}

	public function slash(from:Entity, to:Entity) {
		var p = allocBmp("slash", (from.xx+to.xx)*0.5, (from.yy+to.yy)*0.5-6);
		p.scaleX = p.scaleY = rnd(1,2);
		p.scaleX*=from.dir;
		p.scaleY*=Std.random(2)*2-1;
		p.rotation = rnd(0,45,true);
		//p.dx = 0.3;
		//p.dy = 0.8;
		p.filters = [
			new flash.filters.GlowFilter(0xFF4000,0.7, 16,16,3),
		];
		p.frict = 0.8;
		p.life = rnd(0,3);
	}


	public function shoot(from:Entity, to:Entity) {
		var fx = from.xx;
		var fy = from.yy-5;
		var tx = to.xx;
		var ty = to.yy-rnd(2,8);
		var d = Lib.distance(fx,fy,tx,ty);
		var a = Math.atan2(ty-fy, tx-fx);

		bpool.initIfNeeded("bullet", 32,16, function(c) {
			c.line(18,0xFFFF80,1);
			c.filter( new flash.filters.GlowFilter(0xE83400,1, 8,8,6, 2) );
		});

		for(i in 0...4) {
			var a = a+rnd(0,0.1,true);
			var p = allocBmp("bullet",fx+rnd(0,1,true),fy+rnd(0,1,true));
			p.life = irnd(4,5);
			p.scaleX = rnd(0.5,1.5);
			p.moveAng(a, d/p.life);
			p.delay = i*3;
			p.fadeOutSpeed = 1;
			p.rotation = MLib.toDeg(a);
		}
	}

	public function markCase(cx,cy) {
		var p = allocBmp("mark", (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.life = 20;
		p.fadeOutSpeed = 0.02;
	}

	public function markFree(x,y) {
		var p = allocBmp("mark", x,y);
		p.life = 20;
		p.fadeOutSpeed = 0.02;
	}

	public function exhume(e:Entity) {
		bpool.initIfNeeded("dirt", 8,8, function(c) {
			c.dot(2,0x50291D);
			c.filter( new flash.filters.GlowFilter(0x1F100C,0.7, 2,2,4) );
		});
		for(i in 0...30) {
			var p = allocBmp("dirt", e.xx+rnd(0,6,true), e.yy+rnd(-1,3));
			p.blendMode = NORMAL;
			p.scaleX = rnd(0.5,1.5);
			p.scaleY = rnd(0.5,1);
			p.rotation = rnd(0,360);
			p.life = rnd(15,30);
			p.dx = rnd(0,0.5,true);
			p.dy = -rnd(0,1.5);
			p.gy = 0.1;
			p.frict = 0.96;
			p.delay = i*2;
			p.groundY = e.yy+rnd(0,2);
		}
	}

	public function tomb(e:Entity) {
		bpool.initIfNeeded("tomb", 8,8, function(c) {
			c.dot(1,0x00FF40);
			c.filter( new flash.filters.GlowFilter(0x00FF40,0.7, 4,4,4) );
		});
		var p = allocBmp("tomb", e.xx+rnd(0,8,true), e.yy-rnd(0,5));
		p.blendMode = NORMAL;
		p.fadeIn(rnd(0.2, 0.9), 0.04);
		p.dx = rnd(0,0.5,true);
		p.dy = rnd(0,0.5,true);
		p.gx = rnd(0,0.02,true);
		p.gy = rnd(0,0.02,true);
		p.gy -= rnd(0,0.05);
		p.life = rnd(15,30);
		p.fadeOutSpeed = 0.02;
		p.frict = 0.8;
	}


	public function flies(e:Entity) {
		bpool.initIfNeeded("fly", 8,8, function(c) {
			c.dot(1,0x0);
			c.filter( new flash.filters.GlowFilter(0x0,0.5, 2,2,4) );
		});
		for(i in 0...2) {
			var p = allocBmp("fly", e.xx+rnd(2,12,true), e.yy-rnd(2,20));
			p.blendMode = NORMAL;
			p.fadeIn(rnd(0.5, 1), 0.06);
			p.dx = rnd(0,0.7,true);
			p.dy = rnd(0,0.5,true);
			p.gx = rnd(0,0.02,true);
			p.gy = rnd(0,0.02,true);
			p.life = rnd(15,30);
			p.fadeOutSpeed = 0.02;
			p.onUpdate = function() {
				p.dx+=rnd(0,0.1,true);
				p.dy+=rnd(0,0.1,true);
			}
			p.frict = 0.8;
			sendToBg(p);
		}
	}


	override function update(dt) {
		super.update(dt);

		for(p in parts)
			p.update();
	}
}
