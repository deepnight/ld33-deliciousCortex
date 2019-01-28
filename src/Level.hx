import mt.deepnight.Lib;
import mt.deepnight.slb.*;
import mt.deepnight.Color;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import mt.MLib;

import mt.deepnight.PathFinder;
import mt.deepnight.Bresenham;

class Level extends mt.Process {
	public var lid		: Int;
	public var grid		: Array<Array<{ hard:Bool, soft:Bool, stone:Bool }>>;
	public var wid		: Int;
	public var hei		: Int;

	var bmp				: Bitmap;
	var sprites			: Array<BSprite>;
	var pf				: PathFinder;
	var spots			: Map<String, Array<{cx:Int, cy:Int}>>;
	var stamps			: Map<String, Array<BitmapData>>;

	public function new(i:Int) {
		super(Game.ME);

		sprites = [];
		lid = i;
		spots = new Map();
		stamps = new Map();

		var source = Assets.tiles.getBitmapData("level",lid);
		wid = source.width;
		hei = source.height;

		stamps.set("blood", []);
		for(f in 0...Assets.tiles.countFrames("blood"))
			stamps.get("blood").push( Assets.tiles.getBitmapData("blood",f) );

		stamps.set("gblood", []);
		for(f in 0...Assets.tiles.countFrames("gblood"))
			stamps.get("gblood").push( Assets.tiles.getBitmapData("gblood",f) );

		stamps.set("plank", []);
		for(f in 0...Assets.tiles.countFrames("plank"))
			stamps.get("plank").push( Assets.tiles.getBitmapData("plank",f) );

		// Init
		grid = [];
		for(cx in 0...wid) {
			grid[cx] = [];
			for(cy in 0...hei)
				grid[cx][cy] = {
					soft	: false,
					hard	: false,
					stone	: false,
					//stone	: true, //HACK
				}
		}

		// Parse
		for(cx in 0...wid)
			for(cy in 0...hei) {
				var p = source.getPixel(cx,cy);
				switch( p ) {
					case 0xFFFFFF: setHardCollision(cx,cy);
					case 0x949494:
						setHardCollision(cx,cy);
						grid[cx][cy].stone = true;
					case 0xff9600: addSpot("torch", cx,cy);
					case 0xa44d1e: addSpot("door", cx,cy);
					case 0x00ffc0: addSpot("start", cx,cy);
					case 0xff0000: addSpot("walker", cx,cy);
					case 0x7f0000: addSpot("stander", cx,cy);
					case 0x2aff00: addSpot("tomb", cx,cy);
					case 0xff00ff: addSpot("exit", cx,cy);
				}
			}

		pf = new mt.deepnight.PathFinder(wid,hei);
		for(cx in 0...wid)
			for(cy in 0...hei)
				pf.setCollision(cx,cy, hasHardCollision(cx,cy));

		redraw();
	}


	function addSpot(k:String, x,y) {
		if( !spots.exists(k) )
			spots.set(k,[]);
		spots.get(k).push({ cx:x, cy:y });
	}

	public function getSpots(k:String) {
		return spots.exists(k) ? spots.get(k) : [];
	}


	function redraw() {
		// Detach
		if( bmp!=null ) {
			bmp.bitmapData.dispose();
			bmp.bitmapData = null;
			bmp.parent.removeChild(bmp);

			for(e in sprites)
				e.dispose();
			sprites = [];
		}

		var pt0 = new flash.geom.Point();

		var rseed = new mt.Rand(1866);


		var gbd = new flash.display.BitmapData(wid*Const.GRID, hei*Const.GRID, true, 0x0);
		var wbd = gbd.clone();

		var k = lid<=2 ? "ground" : "groundStone";
		for(cx in 0...wid)
			for(cy in 0...hei) {
				var x = cx*Const.GRID;
				var y = cy*Const.GRID;
				Assets.tiles.drawIntoBitmapRandom(gbd, x,y, k, rseed.random);
			}



		var gold = lid>=6;
		for(cx in 0...wid)
			for(cy in 0...hei) {
				var stone = isStone(cx,cy);
				var k = !stone ? (gold?"gold":"bush") : "stone";
				var k2 = !stone ? "smallBush" : "smallStone";
				var c = stone ? 25 : (gold ? 0 : 80);
				var x = cx*Const.GRID;
				var y = cy*Const.GRID;
				if( hasHardCollision(cx,cy) ) {
					var x = x+Const.GRID*0.5;
					var y = y+Const.GRID*0.5;
					Assets.tiles.drawIntoBitmapRandom(wbd, x+rseed.irange(0,1,true), y+rseed.irange(0,1,true), k, rseed.random, 0.5,0.5);
					if( rseed.random(100)<c )
						Assets.tiles.drawIntoBitmapRandom(wbd, x+rseed.irange(0,3,true), y+rseed.irange(0,3,true), k2, rseed.random, 0.5,0.5);
				}
			}

		var col = lid<=2 ? 0x481137 : 0x0F0C29;
		if( gold ) col = 0x4A0909;
		wbd.applyFilter(wbd, wbd.rect, pt0, new flash.filters.GlowFilter(0x0,0.3, 16,16,2, 2) );
		wbd.applyFilter(wbd, wbd.rect, pt0, new flash.filters.DropShadowFilter(6,-90, col,0.8, 0,2,1, 1,true) );
		wbd.applyFilter(wbd, wbd.rect, pt0, new flash.filters.DropShadowFilter(3,90, 0x2B0B21,0.8, 0,0,1) );

		if( lid<=2 ) {
			// Roots
			var perlin = gbd.clone();
			perlin.perlinNoise(16, 16, 2, 1866, false, true, 0, true);
			perlin.threshold(perlin, perlin.rect, pt0, "<", alpha(0x838383), 0x0);
			perlin.threshold(perlin, perlin.rect, pt0, ">", alpha(0x949494), 0x0);
			perlin.threshold(perlin, perlin.rect, pt0, "!=", 0x0, alpha(0xCC9D7B));
			perlin.applyFilter(perlin, perlin.rect, pt0, new flash.filters.DropShadowFilter(2,-90, 0x0,0.4, 0,2,1, 1,true) );
			perlin.applyFilter(perlin, perlin.rect, pt0, new flash.filters.DropShadowFilter(1,90, 0xFFFFFF,0.3, 0,2,1, 1,true) );
			gbd.draw(perlin, flash.display.BlendMode.OVERLAY);
			perlin.dispose();
		}
		else {
			var perlin = gbd.clone();
			perlin.perlinNoise(32, 32, 4, 1866, false, true, 0, true);
			perlin.threshold(perlin, perlin.rect, pt0, "<", alpha(0x818181), 0x0);
			perlin.threshold(perlin, perlin.rect, pt0, ">", alpha(0x949494), 0x0);
			perlin.threshold(perlin, perlin.rect, pt0, "!=", 0x0, alpha(0x292F43, 0.2));
			//perlin.applyFilter(perlin, perlin.rect, pt0, new flash.filters.DropShadowFilter(2,90, 0x0,0.4, 0,2,1, 1,true) );
			//perlin.applyFilter(perlin, perlin.rect, pt0, new flash.filters.DropShadowFilter(1,90, 0xFFFFFF,0.3, 0,2,1, 1,true) );
			gbd.draw(perlin, flash.display.BlendMode.OVERLAY);
			perlin.dispose();
		}

		// Composite
		gbd.copyPixels(wbd, wbd.rect, pt0, true);
		wbd.dispose();

		// Lightning
		var r = Assets.tiles.getBitmapData("ramp");
		var rc = Assets.tiles.getBitmapData("rampColor");
		//var light = new flash.display.BitmapData(gbd.width, gbd.height, false, 0x0);
		var s = 0.8;
		for(pt in getSpots("torch")) {
			var x = (pt.cx+0.5)*Const.GRID;
			var y = (pt.cy+0.5)*Const.GRID;
			var m = new flash.geom.Matrix();
			m.scale(s,s*0.8);
			m.translate(x-r.width*s*0.5, y-r.height*s*0.5*0.8);
			//m.scale(0.5,0.5);
			gbd.draw(rc, m, new flash.geom.ColorTransform(1,1,1,0.07), BlendMode.ADD);
			//m.scale(2,2);
			gbd.draw(r, m, new flash.geom.ColorTransform(1,1,1,1), BlendMode.OVERLAY);
			gbd.draw(r, m, new flash.geom.ColorTransform(1,1,1,0.5), BlendMode.OVERLAY);

			var s = Assets.tiles.get("torch", 0.5,0.5);
			Game.ME.sdm.add(s, Const.DP_BG_SPRITES);
			s.setPos(x,y-7);
			s.a.playAndLoop("torch");
			s.a.unsync();
			sprites.push(s);
		}
		//gbd.draw(light, BlendMode.ADD);
		r.dispose();
		//light.dispose();

		// Final
		bmp = new flash.display.Bitmap(gbd);
		Game.ME.sdm.add(bmp, Const.DP_BG);

	}

	public inline function isValid(x,y) {
		return x>=0 && x<wid && y>=0 && y<hei;
	}


	public function setHardCollision(x,y) {
		if( isValid(x,y) ) {
			grid[x][y].hard = true;
			grid[x][y].soft = true;
		}
	}
	public function setSoftCollision(x,y, v:Bool) {
		if( isValid(x,y) ) {
			grid[x][y].hard = false;
			grid[x][y].soft = v;
		}
	}

	public function hasHardCollision(x,y) {
		return isValid(x,y) ? grid[x][y].hard : true;
	}
	public function hasSoftCollision(x,y) {
		return isValid(x,y) ? grid[x][y].soft : true;
	}
	public function hasAnyCollision(x,y) {
		return isValid(x,y) ? grid[x][y].hard || grid[x][y].soft : true;
	}
	public function isStone(x,y) {
		return isValid(x,y) ? grid[x][y].stone : false;
	}

	public function sightCheck(fx:Int, fy:Int, tx:Int, ty:Int) {
		return Bresenham.checkThinLine(fx,fy, tx,ty, function(x,y) {
			return !hasAnyCollision(x,y);
		});
	}

	public function getPath(fx:Int, fy:Int, tx:Int, ty:Int) {
		var p = pf.getPath({x:fx, y:fy}, {x:tx, y:ty});
		return pf.smooth(p);
	}

	public function getPathDistance(fx:Int, fy:Int, tx:Int, ty:Int) {
		var p = pf.getPath({x:fx, y:fy}, {x:tx, y:ty});
		var d = 0;
		for(pt in p)
			if( hasSoftCollision(pt.x,pt.y) )
				d+=10;
			else
				d++;
		return d;
	}

	public function blood(x,y, ?n=1, ?pow=1.0, ?green=false) {
		var bd = bmp.bitmapData;
		var a = stamps.get(green?"gblood":"blood");
		for(i in 0...n) {
			var stamp = a[Std.random(a.length)];
			var m = new flash.geom.Matrix();
			m.translate(-stamp.width*0.5, -stamp.height*0.5);
			m.rotate(rnd(0,6.28));
			m.scale(rnd(1,1.5)*pow, rnd(1,1.5)*pow);
			m.translate(x,y);
			bd.draw(stamp, m, new flash.geom.ColorTransform(1,1,1,rnd(0.5, 0.7)), BlendMode.OVERLAY);
		}
	}

	public function plank(x,y) {
		var bd = bmp.bitmapData;
		var a = stamps.get("plank");
		var stamp = a[Std.random(a.length)];
		var m = new flash.geom.Matrix();
		m.translate(-stamp.width*0.5, -stamp.height*0.5);
		m.rotate(rnd(0,6.28));
		m.scale(rnd(1,1.5), rnd(1,1.5));
		m.translate(x,y);
		bd.draw(stamp, m, new flash.geom.ColorTransform(1,1,1,rnd(0.3, 0.5)));
	}


	override function onDispose() {
		super.onDispose();

		pf.destroy();
		pf = null;
		grid = null;

		for(e in sprites)
			e.dispose();
		sprites = null;

		for(a in stamps)
			for(e in a)
				e.dispose();
		stamps = null;

		bmp.bitmapData.dispose();
		bmp.bitmapData = null;
		bmp.parent.removeChild(bmp);
		bmp = null;
	}
}

