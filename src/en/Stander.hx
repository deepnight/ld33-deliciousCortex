package en;

class Stander extends Human {
	public function new(x,y) {
		super(x,y);

		speed = 0;
		initLife(45);

		spr.a.registerStateAnim("standerIdle",0);
		spr.a.applyStateAnims();
	}

	override function onShoot() {
		super.onShoot();
		spr.a.play("standerShoot");
	}

	override function update() {
		super.update();
	}
}