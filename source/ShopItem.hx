package;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class ShopItem extends ScaleButton
{
    var item:Item;

    public function new(item:Item, yThing:Float):Void{
        super(170, Std.int(120 * yThing) + 170, 1, 1.1);

        this.item = item;

        updateSpr();
    }

    public function updateSpr():Void{
        makeGraphic(280, 110, FlxColor.TRANSPARENT, true);
        stamp(new FlxSprite().loadGraphic("assets/images/shopitem1.png"));
        stamp(new FlxSprite().loadGraphic('assets/images/shopitem_${item.sprname}.png'), 144, 15);
        stamp(new FlxSprite().loadGraphic("assets/images/shopitem2.png"));
        if(ShopState.boughtItems.contains(item.name)){
            stamp(new FlxSprite().loadGraphic("assets/images/shopitembought.png"), 144, 15);
        }

        var text = new FlxText();
        text.setFormat(PlayState.font, 20, FlxColor.BROWN, CENTER, OUTLINE);
        text.borderColor = FlxColor.BROWN.getLightened(.2);
        text.borderSize = 1;
        text.fieldWidth = 110;
        text.text = item.name;
        
        stamp(text, 30, 30);
    }
}