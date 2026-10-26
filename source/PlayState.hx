package;

import ctUtil.CtUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.shapes.FlxShapeCircle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import foxlite.FoxCamera;
import foxlite.FoxModel;
import foxlite.FoxScene;
import foxlite.extras.FoxFPSCamera;
import foxlite.material.FoxMaterial;
import foxlite.sky.FoxPanoramaSky;
import foxlite.texture.FoxTexture;

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

	override public function create()
	{
		super.create();

		scene = new FoxScene(FlxG.width, FlxG.height);
		scene.scrollFactor.set(0, 0);
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
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		handleClick();

		jun.scale.setTo(
			FlxMath.bound(CtUtil.lerpThing(jun.scale.x, targetScaleX, elapsed, scaleSpeed), 1, maxJunSize),
			FlxMath.bound(CtUtil.lerpThing(jun.scale.y, targetScaleY, elapsed, scaleSpeed), 1, maxJunSize),
			FlxMath.bound(CtUtil.lerpThing(jun.scale.z, targetScaleZ, elapsed, scaleSpeed), 1, maxJunSize),
		);
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
			}
		} else {
			targetScaleX = 1;
			targetScaleY = 1;
			targetScaleZ = 1;
		}
	}
}
