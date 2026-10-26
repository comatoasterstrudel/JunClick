package;

import ctUtil.CtUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSignal;

class ScaleButton extends FlxSprite
{
    var baseX:Int = 0;
    var baseY:Int = 0;
    var baseScale:Float;
    var size:Float = 1.2;

    public var hoverSignal = new FlxSignal();

    var lastSelected:Bool = false;
    
    public function new(x:Int, y:Int, baseScale:Float, ?size:Float = 1.2):Void{
        this.baseX = x;
        this.baseY = y;
        this.baseScale = baseScale;
        this.size = size;

        super(0,0);
    }

    override function update(elapsed:Float):Void{
        super.update(elapsed);

        align(elapsed);
    }

    public function align(elapsed:Float):Void{
        if(FlxG.mouse.overlaps(this, this.camera)){
            scale.set(
                CtUtil.lerpThing(scale.x, baseScale * size, elapsed, 15),
                CtUtil.lerpThing(scale.y, baseScale * size, elapsed, 15),
            );

            if(!lastSelected) hoverSignal.dispatch();

            lastSelected = true;
        } else {
            scale.set(
                CtUtil.lerpThing(scale.x, baseScale * 1, elapsed, 15),
                CtUtil.lerpThing(scale.y, baseScale * 1, elapsed, 15),
            );

            lastSelected = false;
        }

        updateHitbox();

        setPosition(baseX - width / 2, baseY - height / 2);
    }
}