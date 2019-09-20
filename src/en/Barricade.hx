package en;

class Barricade extends Entity {
	public static var ALL : Array<Barricade> = [];

	var wid			: Int;
	var hei			: Int;
	var crates		: Array<BSprite>;

	public function new(x,y) {
		super(x,y);
		ALL.push(this);

		weight = 999;
		wid = hei = 1;
		initLife(22);
		zpriority = -99999;
		crates = [];

		spr.set(isVertical()?"barricadeV":"barricadeH");
		spr.setCenterRatio(0.5,0.5);
		spr.filters = [];
		xr = 0.5;
		yr = 0.7;
		shadow.visible = false;
		setCollisions(true);

		for(i in 0...4)
			level.plank(xx+rnd(3,10,true), yy-rnd(1,8));

		//var d = Std.random(2)*2-1;
		//var s = Assets.tiles.getRandom("tinyCrate");
		//Game.ME.sdm.add(s, Const.DP_BG);
		//crates.push(s);
		//s.setCenter(0.5,0.5);
		//s.x = xx-Const.GRID*d;
		//s.y = yy;
		//if( Std.random(100)<30 ) {
			//d*=-1;
			//var s = Assets.tiles.getRandom("tinyCrate");
			//Game.ME.sdm.add(s, Const.DP_BG);
			//crates.push(s);
			//s.setCenter(0.5,0.5);
			//s.x = xx + (Const.GRID-rnd(2,6))*d;
			//s.y = yy + rnd(0,3,true);
		//}
	}

	function isVertical() return level.hasAnyCollision(cx,cy-1);

	function setCollisions(v:Bool) {
		for(x in cx...cx+wid)
			for(y in cy...cy+hei)
				level.setSoftCollision(x,y, v);
	}

	override function unregister() {
		super.unregister();
		ALL.remove(this);
		for(e in crates)
			e.dispose();
		crates = null;
	}

	override public function onTouch(e:Entity) {
		super.onTouch(e);
	}

	override public function hit(d) {
		super.hit(d);

		cd.set("shake", Const.seconds(1.5));
	}

	override public function onDie() {
		super.onDie();
		mt.flash.Sfx.playOne([
			Assets.SBANK.explosion01,
			Assets.SBANK.explosion02,
			Assets.SBANK.explosion03,
		], 0.4);
		setCollisions(false);
		for(i in 0...5)
			level.plank(xx+rnd(0,6,true), yy-rnd(0,10));
	}

	override function update() {
		super.update();
	}
}