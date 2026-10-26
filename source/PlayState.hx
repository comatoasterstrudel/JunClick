package;

import ctUtil.CtUtil;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.shapes.FlxShapeCircle;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import foxlite.FoxCamera;
import foxlite.FoxInstancedModel;
import foxlite.FoxModel;
import foxlite.FoxScene;
import foxlite.extras.FoxFPSCamera;
import foxlite.material.FoxMaterial;
import foxlite.sky.FoxPanoramaSky;
import foxlite.texture.FoxTexture;
import openfl.filters.BlurFilter;
import openfl.geom.Vector3D;

class PlayState extends FlxState
{
	// base foxlite stuff
	var scene:FoxScene;
	var cam3d:FoxFPSCamera;

	// models
	var sky:FoxPanoramaSky;
	var jun:FoxModel;

	// jun scale vals
	var targetScaleX:Float = 1;
	var targetScaleY:Float = 1;
	var targetScaleZ:Float = 1;
	var scaleSpeed:Float = 15;
	final maxJunSize:Float = 3;
	final clickSizes = FlxPoint.get(.1, .2);

	// clicking stuff?
	var clickHitbox:FlxShapeCircle;
	var hitboxSize:Int = 100;
	var cursor:FlxSprite;

	// ducks
	public static var ducks:Int = 0;
	
	// bg ducks
	var duckSprites:Array<FoxModel> = [];
	
	// numbers
	var numbers:FlxTypedSpriteGroup<FlxText>;

	// ui
	var duckText:FlxText;
	var duckText2:FlxText;
	var behindTextTab:FlxSprite;

	//font
	public static var font:String = "assets/fonts/FFCommaTrial-Regular.ttf";

	// shop
	var shopButton:ScaleButton;

	var camEverything:FlxCamera;
	var camShopItem:FlxCamera;
	var camTop:FlxCamera;

	var canLeave:Bool = true;
	
	override public function create()
	{
		super.create();

		camEverything = new FlxCamera();
		camEverything.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(camEverything, true);

		camShopItem = new FlxCamera();
		camShopItem.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(camShopItem, false);

		camTop = new FlxCamera();
		camTop.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(camTop, false);

		scene = new FoxScene(FlxG.width, FlxG.height);
		scene.scrollFactor.set(0, 0);
		scene.camera = camEverything;
		add(scene);

		cam3d = new FoxFPSCamera();
		cam3d.enableControls = false;
		cam3d.bgColor = FlxColor.WHITE;
		scene.foxCameras.push(cam3d);

		#if (debug && moveCamera) 
		cam3d.enableControls = true;
		#end

		sky = new FoxPanoramaSky(FoxMaterial.createSky(FoxTexture.fromImage("sky")));
		sky.angleX = 50;
		scene.add(sky);

		jun = new FoxModel(0, 0, -3);
		jun.loadOBJ("models/jun.obj");
		jun.angleY = -15;
		scene.add(jun);

		clickHitbox = new FlxShapeCircle(0, 0, hitboxSize, {}, FlxColor.RED);
		clickHitbox.screenCenter();
		clickHitbox.alpha = 0;
		add(clickHitbox);

		#if (debug && showHitbox)
		clickHitbox.alpha = .5;
		#end

		cursor = new FlxSprite().makeGraphic(1,1, FlxColor.BLUE);
		cursor.visible = false;
		add(cursor);

		#if (debug && showCursor)
		clickHitbox.visible = true;
		#end

		numbers = new FlxTypedSpriteGroup<FlxText>();
		numbers.camera = camEverything;
		add(numbers);

		behindTextTab = new FlxSprite().loadGraphic("assets/images/tab.png");
		add(behindTextTab);

		duckText = new FlxText();
		duckText.setFormat(font, 20, FlxColor.YELLOW, CENTER, OUTLINE, FlxColor.BROWN.getLightened(.1));
		duckText.borderSize = 3;
		add(duckText);

		duckText2 = new FlxText();
		duckText2.setFormat(font, 35, FlxColor.YELLOW, CENTER, OUTLINE, FlxColor.BROWN.getLightened(.2));
		duckText2.borderSize = 4;
		add(duckText2);

		for(thing in [duckText, duckText2, behindTextTab]){
			thing.camera = camTop;
		}

		// dont lag when spawning ducks pls
		var rubberduck = addRubberDuck();
		rubberduck.destroy();
		duckSprites = [];

		shopButton = new ScaleButton(FlxG.width - 150, FlxG.height - 70, .9);
		shopButton.antialiasing = false;
		shopButton.loadGraphic("assets/images/shopbutton.png");
		shopButton.align(2);
		shopButton.camera = camEverything;
		add(shopButton);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		handleClick();

		handleJunScale(elapsed);

		handleDuckText(elapsed);

		handleRubberDucks(elapsed);

		handleShopMenu();
	}

	function handleClick():Void{
		cursor.setPosition(FlxG.mouse.x, FlxG.mouse.y);

		clickHitbox.scale.set(jun.scale.x, jun.scale.y);
		clickHitbox.updateHitbox();
		clickHitbox.screenCenter();

		if(FlxG.pixelPerfectOverlap(cursor, clickHitbox)){ // overlapping jun
			targetScaleX = 1.2;
			targetScaleY = 1.2;
			targetScaleZ = 1.2;

			// click!
			if(FlxG.mouse.justReleased){
				jun.scale.setTo(
					jun.scale.x + FlxG.random.float(clickSizes.x, clickSizes.y),
					jun.scale.y + FlxG.random.float(clickSizes.x, clickSizes.y),
					jun.scale.z + FlxG.random.float(clickSizes.x, clickSizes.y)
				);

				var number = new FlxText();
				
				var amount = getDuckPerClick();
				ducks += amount;
				number.text = '+ ${amount}';
				number.setFormat(font, 30, FlxColor.YELLOW, CENTER, OUTLINE, FlxColor.BROWN);
				number.borderSize = 3;
				CtUtil.centerSpriteOnSprite(number, cursor, true, true);
				number.x += FlxG.random.float(-10, 10);
				FlxTween.tween(number, {y: number.y - 100, alpha: 0}, 1.5, {onComplete: function(f):Void{
					number.destroy();
				}});
				numbers.add(number);

				addRubberDuck();

				duckText2.scale.set(FlxG.random.float(1.3, 1.5), FlxG.random.float(1.3, 1.5));
			}
		} else {
			targetScaleX = 1;
			targetScaleY = 1;
			targetScaleZ = 1;
		}
	}

	function handleJunScale(elapsed:Float):Void{
		jun.scale.setTo(
			FlxMath.bound(CtUtil.lerpThing(jun.scale.x, targetScaleX, elapsed, scaleSpeed), 1, maxJunSize),
			FlxMath.bound(CtUtil.lerpThing(jun.scale.y, targetScaleY, elapsed, scaleSpeed), 1, maxJunSize),
			FlxMath.bound(CtUtil.lerpThing(jun.scale.z, targetScaleZ, elapsed, scaleSpeed), 1, maxJunSize),
		);
	}

	public function handleDuckText(elapsed:Float):Void{
		duckText.text = 'How many rubber ducks Jun has:';
		duckText.screenCenter(X);
		duckText.y = 4;

		duckText2.scale.set(
			CtUtil.lerpThing(duckText2.scale.x, 1, elapsed, scaleSpeed),
			CtUtil.lerpThing(duckText2.scale.y, 1, elapsed, scaleSpeed),
		);
		duckText2.text = Std.string(ducks);
		duckText2.screenCenter(X);
		duckText2.y = duckText.y + duckText.height + 5;

		behindTextTab.setGraphicSize(FlxG.width - 20, 120);
		behindTextTab.screenCenter(X);
		behindTextTab.y = -20;
	}

	function addRubberDuck():FoxModel{
		if(duckSprites.length > 300){
			return null;
		}

		var duck = new FoxModel(FlxG.random.float(-7, 7), 5, FlxG.random.float(-4.3, -6.5));
		duck.loadOBJ("models/rubber_duck.obj");
		duck.angleX = FlxG.random.float(-360, 360);
		duck.angleY = FlxG.random.float(-360, 360);
		duck.angleZ = FlxG.random.float(-360, 360);
		scene.add(duck);

		duckSprites.push(duck);

		return duck;
	}

	function handleRubberDucks(elapsed:Float):Void{
		var removeThese:Array<FoxModel> = [];

		for(duck in duckSprites){
			duck.y -= elapsed;
			
			if(duck.y < -7){
				removeThese.push(duck);
			}
		}

		for(duck in removeThese){
			duckSprites.remove(duck);
			duck.destroy();
		}
	}

	function getDuckPerClick():Int
	{
		return 1;
	}

	function handleShopMenu():Void{
		if(canLeave && FlxG.mouse.overlaps(shopButton) && FlxG.mouse.justReleased){
			var blurFilter = new BlurFilter(8, 8, 1);
			camEverything.filters = [blurFilter];
			shopButton.visible = false;

			canLeave = false;

			openSubState(new ShopState(camShopItem, function():Void{
				camEverything.filters = [];
				shopButton.visible = true;

				new FlxTimer().start(0.1, function(f):Void{
					canLeave = true;
				});
			}));
		}
	}
}
