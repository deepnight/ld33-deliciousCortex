import flash.display.Sprite;
class FlashProcess extends mt.Process {
	public static var DEFAULT_PARENT : Sprite = flash.Lib.current;

	public var root			: Sprite;
	var pt0					: flash.geom.Point;

	public function new(?p, ?ctx:Sprite) {
		super(p, Const.FPS);
		name = "FProcess";

		pt0 = new flash.geom.Point();

		root = new Sprite();
		if( ctx!=null )
			ctx.addChild(root);
		else
			DEFAULT_PARENT.addChild(root);
	}


	override public function onDispose() {
		super.onDispose();

		pt0 = null;

		if( root.parent!=null )
			root.parent.removeChild(root);
		root = null;
	}
}