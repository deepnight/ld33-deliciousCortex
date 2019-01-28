import mt.deepnight.Buffer;
import mt.deepnight.slb.*;
import mt.MLib;
import mt.flash.Key;

class Game extends FlashProcess { //}
	public static var ME : Game;

	public var buffer(get,never)	: Buffer; inline function get_buffer() return Main.ME.buffer;
	public var fx					: Fx;
	public var scroller				: flash.display.Sprite;
	public var sdm					: mt.flash.DepthManager;
	public var level				: Level;
	public var hero					: en.Hero;
	public var flag					: en.Flag;
	public var cm					: mt.deepnight.Cinematic;
	var dark						: BSprite;
	public var flags				: Map<String,Bool>;

	public var viewport				: { tx:Null<Float>, ty:Null<Float>, x:Float, y:Float, dx:Float, dy:Float };

	public var mask					: flash.display.Bitmap;

	public function new() {
		super();
		ME = this;
		flags = new Map();

		scroller = new flash.display.Sprite();
		buffer.dm.add(scroller, Const.DP_BG);
		sdm = new mt.flash.DepthManager(scroller);

		cm = new mt.deepnight.Cinematic(Const.FPS);

		var w = new flash.display.Sprite();
		sdm.add(w, Const.DP_FX);
		fx = new Fx(this,w);
		viewport = { tx:null, ty:null, x:0, y:0, dx:0, dy:0 }

		dark = Assets.tiles.get("dark");
		buffer.dm.add(dark, Const.DP_FX);
		dark.width = buffer.width;
		dark.height = buffer.height;
		dark.alpha = 0.9;

		mask = new flash.display.Bitmap( buffer.createSimilarBitmap(false) );
		buffer.dm.add(mask, Const.DP_TOP);
		mask.bitmapData.fillRect(mask.bitmapData.rect, alpha(0x0d0000));

		new ui.Status();


		#if debug
		setFlag("control");
		startLevel(0, true);
		#else
		startLevel(0, true);
		#end
	}

	override function onResize() {
		super.onResize();
		Main.ME.onResize();
	}


	public function nextLevel(?delta=1) {
		cd.set("lock", 9999);
		showMask();
		delayer.add( function() {
			startLevel(level.lid+delta, true);
			cd.unset("lock");
		}, 1000);
	}

	function startLevel(lid:Int, ?first=false) {
		if( level!=null ) {
			level.destroy();
			for(e in Entity.ALL)
				e.destroy();
		}

		//setFlag("hack", false);

		fx.clear();
		ui.Instruction.clear();
		ui.Arrow.clear();
		cm.cancelEverything();
		resetFocus();

		level = new Level(lid);

		var pt = level.getSpots("start")[0];
		hero = new en.Hero(pt.cx,pt.cy);
		flag = new en.Flag();
		ui.Status.CURRENT.refresh();

		for(pt in level.getSpots("tomb"))
			new en.Tomb(pt.cx,pt.cy);

		for(pt in level.getSpots("exit"))
			new en.Exit(pt.cx,pt.cy);

		for(pt in level.getSpots("walker"))
			new en.Walker(pt.cx,pt.cy);

		for(pt in level.getSpots("stander"))
			new en.Stander(pt.cx,pt.cy);

		for(pt in level.getSpots("door"))
			new en.Barricade(pt.cx,pt.cy);

		viewport.x = hero.xx;
		viewport.y = hero.yy;

		function spawnBasePack() {
			Assets.SBANK.zombies01(0.15);
			spawnPack(hero.cx-7, hero.cy, 4, true);
			spawnPack(hero.cx-6, hero.cy+1, 4, true);
			spawnPack(hero.cx-8, hero.cy+2, 4, true);
			spawnPack(hero.cx-8, hero.cy+1, 4, true);
		}

		switch( lid ) {
			case 0 :
				var x = hero.cx;
				var e = en.Human.closestTo(hero);
				e.dir = 1;
				if( first )
					cm.create({
						#if debug
						//Assets.startMusic();
						#else
						hero.setPosCase(-1,hero.cy);
						2000;
						hero.setPosCase(0,hero.cy);
						hero.goto(x+1,hero.cy);
						1500>>focus(22*Const.GRID, hero.yy);
						1500;
						e.dir = -1;
						300;
						e.goto(e.cx-1, e.cy);
						200;
						ui.Say.on(e, "You shall not PASS!");
						600;
						ui.Instruction.show("Press SPACE to continue.");
						end;
						ui.Instruction.clear();
						ui.Say.on(e, "We, the City Watch, are currently investigating the area.") > end;
						hero.goto(x,hero.cy);
						500;
						hero.dir = 1;
						ui.Say.on(hero, "Excuse me sir. But I'm the Evil Lord of Terrible Darkness, and I actually live here.") > end;
						ui.Say.on(hero, "And, as a matter of fact, this forest is MY private property.") > end;
						ui.Say.on(hero, "I would be grateful if you would leave the place immediatly.") > end;
						ui.Say.on(e, "Evil lord, my ass.") > end;
						ui.Say.on(e, "GET LOST, you monster.") > end;
						ui.Say.clear();
						//Assets.startMusic();
						400;
						Assets.SBANK.say01(1);
						ui.Ambiant.on(hero, "Indeed.");
						500;
						hero.dir = -1;
						#end
						focus(0,hero.yy);
						spawnBasePack();
						1000;
						ui.Say.on(en.Minion.ALL[0], "BraaaAaAain..") > end;
						ui.Say.clear();
						resetFocus();
						ui.Instruction.show("Press ARROWS keys to move (WASD also works).");
					});
				else
					spawnBasePack();

			case 6 :
				cm.create({
					1000;
					ui.Say.on(hero, "I think I finally got rid of them.") > end;
					ui.Say.on(hero, "I really wonder what they were looking for.") > end;
					ui.Say.clear();
				});
		}

		if( first )
			showLevelTitle();
	}

	function showLevelTitle() {
		//#if !debug
		new ui.Title(switch( level.lid ) {
			case 0 : "The Entrance";
			case 1 : "The Family Cemetery";
			case 2 : "The Old Gardens";
			case 3 : "The Crypt";
			case 4 : "The Purgatory";
			case 5 : "Tormented tombs";
			case 6 : "Home sweet home";
			default : "???";
		});
		delayer.add( hideMask, 1200 );
		//#else
		//hideMask();
		//#end
	}

	public function spawnPack(cx,cy, n, ?exhume=false, ?autoLink=false) {
		for(i in 0...n) {
			var e = new en.Minion(cx,cy);
			if( exhume )
				e.exhume();
			if( autoLink ) {
				if( !hero.linking )
					hero.linking = true;
				e.link();
			}
		}
	}

	public function setFlag(id:String, ?v=true) flags.set(id,v);
	public function removeFlag(id:String, ?v=true) flags.remove(id);
	public function hasFlag(id:String) return flags.get(id)==true;
	public function doOnce(id:String) {
		if( !hasFlag(id) ) {
			setFlag(id);
			return true;
		}
		else
			return false;
	}


	public function isLocked() {
		return !cm.isEmpty() || cd.has("lock");
	}

	override function onDispose() {
		super.onDispose();

		fx = null;
		cm.destroy();
		cm = null;
		flags = null;

		mask.bitmapData.dispose();
		mask.bitmapData = null;
		mask = null;
	}

	public function showMask() {
		mask.visible = true;
		tw.create(mask.alpha, 0>1, 600);
	}

	public function hideMask() {
		tw.create(mask.alpha, 0, 1500);
	}


	override function postUpdate(dt) {
		super.postUpdate(dt);

		fx.update(dt);
		Assets.tiles.updateChildren();

		if( time%2==0 ) {
			Entity.ALL.sort( function(a,b) {
				return Reflect.compare(a.yy+a.zpriority, b.yy+b.zpriority);
			});
			for(e in Entity.ALL)
				sdm.over(e.spr);
		}

		for(e in Entity.ALL)
			e.render();
	}

	public function focus(x:Float, y:Float) {
		viewport.tx = x;
		viewport.ty = y;
	}

	public function resetFocus() {
		viewport.tx = viewport.ty = null;
	}

	function updateTutorial() {
		if( level.lid==0 ) {
			if( hasFlag("move") && doOnce("control") ) {
				var x = 0.;
				var y = 0.;
				for(e in en.Minion.ALL) {
					x+=e.xx;
					y+=e.yy;
				}
				x/=en.Minion.ALL.length;
				y/=en.Minion.ALL.length;
				new ui.Arrow(x/Const.GRID,y/Const.GRID);
				new ui.Instruction("Press SPACE near your minions to take their control!");
			}

			if( hasFlag("controlDone") && doOnce("attack") ) {
				var e = en.Human.closestTo(hero);
				new ui.Instruction("Bring them here, then press SPACE again to release them!");
				new ui.Arrow(e.cx-7, e.cy);
			}
		}

		if( level.lid==1 ) {
			if( hero.cx>=10 && doOnce("restart") ) {
				new ui.Instruction("Hit R at any time to restart current level.");
			}
			if( hero.cx>=20 )
				ui.Instruction.clear();
		}

		if( level.lid>=6 && hero.cy<=20 && doOnce("ending") ) {
			cm.create({
				ui.Say.on(hero, "I will have to clean this mess, one day.") > end;
				ui.Say.clear();
				ui.Instruction.show("Thank you for playing! Check DEEPNIGHT.NET for more!");
			});
		}

		//if( hero.cx>=16 && doOnce("hack") ) {
			//var e = en.Human.closestTo(hero);
			//cm.create({
				//e.dir = -1;
				//ui.Arrow.clear();
				//ui.Instruction.clear();
				//ui.Say.on(hero, "Gentlemen, lunch time.") > end;
				//ui.Say.clear();
			//});
		//}
	}

	override function update(dt) {
		super.update(dt);

		updateTutorial();

		cm.update();

		for(e in Entity.ALL)
			if( !e.destroyed )
				e.update();

		while( Entity.GC.length>0 )
			Entity.GC[0].unregister();

		var s = 0.4;
		var tx = viewport.tx==null ? hero.xx : viewport.tx;
		var ty = viewport.ty==null ? hero.yy : viewport.ty;
		if( tx>viewport.x+50 ) viewport.dx+=s;
		if( tx<viewport.x-50 ) viewport.dx-=s;
		if( ty>viewport.y+20 ) viewport.dy+=s;
		if( ty<viewport.y-20 ) viewport.dy-=s;
		viewport.x+=viewport.dx;
		viewport.y+=viewport.dy;
		viewport.dx*=0.85;
		viewport.dy*=0.85;
		viewport.x = MLib.fclamp(viewport.x, buffer.width*0.5, level.wid*Const.GRID-buffer.width*0.5);
		viewport.y = MLib.fclamp(viewport.y, buffer.height*0.5, level.hei*Const.GRID-buffer.height*0.5-8);

		//scroller.x = -Std.int(viewport.x - buffer.width*0.5);
		scroller.y = -Std.int(viewport.y - buffer.height*0.5);

		if( Key.isToggled(Key.R) && !cd.hasSet("restart", Const.seconds(5)) ) {
			showMask();
			cd.set("lock", Const.seconds(1));
			delayer.add( function() {
				hideMask();
				startLevel(level.lid);
				showLevelTitle();
			},800);
		}

		#if debug
		if( Key.isToggled(Key.T) )
			fx.death(hero);

		if( Key.isToggled(Key.N) )
			nextLevel();

		if( Key.isToggled(Key.P) )
			nextLevel(-1);

		if( Key.isToggled(Key.S) )
			spawnPack(hero.cx, hero.cy, 3, true, true);
		#end
	}
}


