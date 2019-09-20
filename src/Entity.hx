import en.*;

class Entity {
	public static var GC : Array<Entity> = [];
	public static var ALL : Array<Entity> = [];

	public var cd				: mt.Cooldown;
	public var tw				: mt.deepnight.Tweenie;

	public var cx				: Int;
	public var cy				: Int;
	public var xr				: Float;
	public var yr				: Float;

	public var dx				: Float;
	public var dy				: Float;

	public var xx(get,never)	: Float;
	public var yy(get,never)	: Float;

	public var dir				: Int;
	public var destroyed		: Bool;
	public var weight			: Float;
	public var speed			: Float;

	public var spr				: BSprite;
	public var life				: Int;
	public var maxLife			: Int;

	var level(get,never)		: Level; inline function get_level() return Game.ME.level;
	var path					: Array<{x:Int, y:Int}>;
	var lastReached				: Null<{x:Int, y:Int}>;

	var fx(get,never)			: Fx; inline function get_fx() return Game.ME.fx;
	var hero(get,never)			: en.Hero; inline function get_hero() return Game.ME.hero;
	var time(get,never)			: Float; inline function get_time() return Game.ME.time;
	var pathPreview				: flash.display.Sprite;

	public var shadow			: BSprite;
	public var zpriority		: Int;

	public function new(x,y) {
		ALL.push(this);

		destroyed = false;
		zpriority = 0;
		path = [];
		dx = dy = 0;
		setPosCase(x,y);
		xr = rnd(0.2,0.8);
		yr = rnd(0.2,0.8);
		dir = 1;
		weight = 1;
		speed = 0.02;
		initLife(1);
		//speed*=2;

		cd = new mt.Cooldown();
		tw = new mt.deepnight.Tweenie(Const.FPS);

		pathPreview = new flash.display.Sprite();
		Game.ME.sdm.add(pathPreview, Const.DP_BG);
		pathPreview.blendMode = ADD;
		pathPreview.alpha = 0.6;
		//pathPreview.filters = [
			//new flash.filters.GlowFilter(0x0D108E,1, 16,16,2),
		//];

		spr = new mt.deepnight.slb.BSprite( Assets.tiles );
		Game.ME.sdm.add(spr, Const.DP_ENTITY);
		spr.setCenterRatio(0.5,1);
		spr.filters = [
			new flash.filters.GlowFilter(0x1A122C,0.8, 2,2,6),
		];

		shadow = Assets.tiles.get("shadow", 0.5,0.5);
		Game.ME.sdm.add(shadow, Const.DP_BG);
		shadow.alpha = 0.6;
	}

	function toString() return "Entity@"+cx+","+cy;
	inline function alpha(rgb:UInt,?alpha=1.0) : UInt return mt.deepnight.Color.addAlphaF(rgb, alpha);
	function rnd(min,max,?sign) return Lib.rnd(min,max,sign);
	function irnd(min,max,?sign) return Lib.irnd(min,max,sign);

	public function setPosCase(x,y) {
		cx = x;
		cy = y;
		xr = 0.5;
		yr = 0.5;
		dx = dy = 0;
	}

	public function repelFrom(e:Entity, ?pow=1.0) {
		dx*=0.3;
		dy*=0.3;
		var a = Math.atan2(yy-e.yy, xx-e.xx);
		dx+=Math.cos(a)*0.4*pow;
		dy+=Math.sin(a)*0.4*pow;
	}

	public function initLife(v) {
		life = maxLife = v;
	}

	public function hit(dmg:Int) {
		life-=dmg;
		if( !is(Barricade) )
			level.blood(xx,yy, 0.25, !is(en.Human));

		if( life<=0 && !destroyed ) {
			life = 0;
			onDie();
		}
		else
			blink(0xFFEC00, 1, 3);
	}

	public function blink(c:UInt, r:Float, d:Int) {
		cd.set("blink", d);
		cd.onComplete("blink", function() {
			spr.transform.colorTransform = new flash.geom.ColorTransform();
		});
		spr.transform.colorTransform = mt.deepnight.Color.getColorizeCT(c, r);
	}

	public function tryAmbiant(?lockId="global", pctChance:Float, ?str:String, ?a:Array<String>) {
		if( Std.random(100)<pctChance && !Game.ME.cd.hasSet("ambiant_"+lockId, Const.seconds(6)) ) {
			ui.Ambiant.on(this, str,a);
		}
	}

	public inline function isDead() return life<=0 || destroyed;

	public function onDie() {
		if( is(Barricade) )
			fx.woodExplosion(this);
		else {
			fx.death(this);
			level.blood(xx,yy, 2, !is(en.Human));
		}
		destroy();
	}

	public function goto(x:Int,y:Int) {
		if( isStunned() )
			return;

		path = level.getPath(cx,cy, x,y);
		lastReached = null;
	}

	public function completePath(x,y) {
		lastReached = { x:x, y:y }
		path = [];
	}
	public function cancelPath() {
		lastReached = null;
		path = [];
	}

	public function canBePushed() return weight>0;

	public inline function isStunned() return cd.has("stun");
	public function stun(d:Float) cd.set("stun",d, false);
	public inline function isWalking() return MLib.fabs(dx)>=speed*0.3 || MLib.fabs(dy)>=speed*0.3;
	public function distanceCaseSqr(e:Entity) return Lib.distanceSqr(cx+xr,cy+yr, e.cx+e.xr,e.cy+e.yr);
	public function distanceSqr(e:Entity) return Lib.distanceSqr(xx,yy, e.xx,e.yy);
	public function distance(e:Entity) return Lib.distance(xx,yy, e.xx,e.yy);
	public function pathDistanceCheck(e:Entity, d:Float) {
		if( distanceCaseSqr(e)>d*d )
			return false;
		else
			return level.getPathDistance(cx,cy, e.cx,e.cy)<=d;
	}

	public function canSee(e:Entity) {
		return level.sightCheck(cx,cy,e.cx,e.cy) || level.sightCheck(e.cx,e.cy, cx,cy);
	}

	public function canSeeInRange(e:Entity, d:Float) {
		return distanceSqr(e)<=d*d && canSee(e);
	}

	inline function get_xx() return (cx+xr)*Const.GRID;
	inline function get_yy() return (cy+yr)*Const.GRID;

	public inline function destroy() {
		if( !destroyed ) {
			destroyed = true;
			GC.push(this);
		}
	}

	public function unregister() {
		GC.remove(this);
		ALL.remove(this);

		shadow.dispose();
		shadow = null;

		tw.destroy();
		tw = null;

		cd.destroy();
		cd = null;

		pathPreview.graphics.clear();
		pathPreview.parent.removeChild(pathPreview);
		pathPreview = null;

		path = null;

		spr.dispose();
		spr = null;
	}

	public function render() {
		spr.x = Std.int(xx);
		spr.y = Std.int(yy);
		spr.scaleX = MLib.fabs(spr.scaleX) * dir;
		shadow.x = spr.x;
		shadow.y = spr.y;
	}

	public function onTouch(e:Entity) {
	}

	public function is(c:Class<Entity>) {
		return Std.is(this, c);
	}

	public function as<T>(c:T) : T {
		return cast this;
	}

	function circularCollisions() {
		if( !canBePushed() )
			return;

		var radius = Const.GRID*1;
		var repel = 0.04;

		for(e in ALL) {
			if( e!=this && e.canBePushed() && MLib.iabs(cx-e.cx)<=1 && MLib.iabs(cy-e.cy)<=1 ) {
				var d = Lib.distance(xx,yy, e.xx,e.yy);
				if( d<=radius ) {
					var a = Math.atan2(e.yy-yy, e.xx-xx);
					var wr = weight / (weight+e.weight);
					if( wr>=0.9 ) wr = 1;
					if( wr<=0.1 ) wr = 0;
					dx -= Math.cos(a) * (1-wr)*repel;
					dy -= Math.sin(a) * (1-wr)*repel;
					e.dx += Math.cos(a) * wr*repel;
					e.dy += Math.sin(a) * wr*repel;
					onTouch(e);
					e.onTouch(this);
				}
			}
		}
	}

	public function update() {
		cd.update();
		tw.update();

		var frict = 0.5;
		var repel = 0.01;

		// Pathfinding
		if( path.length>0 ) {
			var end = path[path.length-1];
			//var pt = path[0];
			//if( MLib.fabs((pt.x+0.5)-(cx+xr))<=0.45 && MLib.fabs((pt.y+0.5)-(cy+yr))<=0.45 )
				//path.shift();

			//trace(path);
			for(i in 0...path.length) {
				var i = path.length-i-1;
				var pt = path[i];
				if( MLib.fabs((pt.x+0.5)-(cx+xr))<=0.5 && MLib.fabs((pt.y+0.5)-(cy+yr))<=0.5 ) {
					path.splice(0,i+1);
					//trace(pt+" "+cx+","+cy);
					break;
				}
			}
			//for(pt in path)
				//Game.ME.fx.mark(pt.x, pt.y);
			if( path.length>0 ) {
				var pt = path[0];
				var a = Math.atan2((pt.y+0.5)*Const.GRID-yy, (pt.x+0.5)*Const.GRID-xx);
				dx+=Math.cos(a)*speed;
				dy+=Math.sin(a)*speed;
			}
			else
				completePath(end.x, end.y);
		}

		// Collisions/repels
		circularCollisions();

		// X
		xr+=dx;
		dx*=frict;
		if( MLib.fabs(dx)<=0.01 ) dx = 0;

		if( level.hasAnyCollision(cx-1,cy) ) {
			if( xr<=0.15 )
				xr = 0.15;
			if( xr<=0.4 )
				dx += (dx<0?4:1) * repel;
		}
		if( level.hasAnyCollision(cx+1,cy) ) {
			if( xr>=0.85 )
				xr = 0.85;
			if( xr>=0.7 )
				dx -= (dx>0?6:1) * repel;
		}

		while( xr>1 ) {
			cx++;
			xr--;
		}
		while( xr<0 ) {
			cx--;
			xr++;
		}

		// Y
		yr+=dy;
		dy*=frict;
		if( MLib.fabs(dy)<=0.01 ) dy = 0;
		if( level.hasAnyCollision(cx,cy-1) ) {
			if( yr<=0.4 )
				yr = 0.4;
			if( yr<=0.7 )
				dy += (dy<0?4:1) * repel;
		}
		if( level.hasAnyCollision(cx,cy+1) && yr>=0.9 ) {
			yr = 0.9;
			dy *= 0.2;
		}

		while( yr>1 ) {
			cy++;
			yr--;
		}
		while( yr<0 ) {
			cy--;
			yr++;
		}
	}
}