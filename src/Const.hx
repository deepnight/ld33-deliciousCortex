class Const { //}
	public static var WID = Std.int(flash.Lib.current.stage.stageWidth);
	public static var HEI = Std.int(flash.Lib.current.stage.stageHeight);
	public static var FPS = 30;
	public static function seconds(v:Float) : Int return mt.MLib.round(v*FPS);
	public static var UPSCALE = -1;
	#if debug
	public static var FORCED_UPSCALE = 2;
	#else
	public static var FORCED_UPSCALE = -1;
	#end
	public static var GRID = 12;

	public static var COMMAND_RANGE_CASE = 5.5;
	public static var COMMAND_RANGE = COMMAND_RANGE_CASE*GRID;

	private static var uniq = 0;
	public static var DP_BG = uniq++;
	public static var DP_BG_SPRITES = uniq++;
	public static var DP_ENTITY = uniq++;
	public static var DP_FX = uniq++;
	public static var DP_UI = uniq++;
	public static var DP_TOP = uniq++;
}
