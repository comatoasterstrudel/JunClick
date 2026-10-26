import flixel.FlxG;
import flixel.FlxState;
import foxlite.renderer.FoxRenderer;

class InitState extends FlxState
{
    override function create():Void{
        super.create();

        // foxlite
        FoxRenderer.initLibs();

        // mouse 
        FlxG.mouse.useSystemCursor = true;
        
        FlxG.switchState(PlayState.new);
    }
}