package;

import ctUtil.CtUtil;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
class ShopState extends FlxSubState {
    var leaveButton:ScaleButton;

    var camShop:FlxCamera;
    var camShopItem:FlxCamera;

    var exit:Void->Void;

    public static var targetScrollY:Float = 0;

    public static final items:Array<Item> = [
        {
            name: "Orange Soda",
            sprname: "orangesoda",
            description: "I have orange soda in my room",
            effect: "+ 1 Duck Per Quarter Second",
            cost: 100
        },
        {
            name: "Veggie Burger",
            sprname: "veggieburger",
            description: "Heh!! Impossible..!",
            effect: "+ 2 Ducks Per Quarter Second",
            cost: 200
        },
        {
            name: "Tofu",
            sprname: "tofu",
            description: "Some sort of mole would love it !",
            effect: "+ 3 Ducks Per Quarter Second",
            cost: 300
        },
        {
            name: "Grand Painting",
            sprname: "grandposter",
            description: "asdads",
            effect: "",
            cost: 400
        },
    ];

    public static var boughtItems:Array<String> = [];

    var itemSprites:FlxTypedSpriteGroup<ShopItem>;

    var priceBg:FlxSprite;
    var priceText1:FlxText;
    var priceText2:FlxText;
    var priceText3:FlxText;

    public function new(camShopItem:FlxCamera, exit:Void->Void):Void{
        super();

        this.camShopItem = camShopItem;

        camShop = new FlxCamera();
        camShop.bgColor = FlxColor.TRANSPARENT;
        FlxG.cameras.add(camShop);

        itemSprites = new FlxTypedSpriteGroup<ShopItem>();
        itemSprites.camera = this.camShopItem;
        add(itemSprites);

        for(i in 0...items.length){
            var thing = new ShopItem(items[i], i);
            thing.camera = this.camShopItem;
            itemSprites.add(thing);

            thing.hoverSignal.add(function():Void{
                updatePriceBox(items[i]);
            });
        }

        priceBg = new FlxSprite(330, 90).loadGraphic("assets/images/shopbg.png");
        priceBg.camera = camShop;
        priceBg.alpha = .5;
        add(priceBg);

        leaveButton = new ScaleButton(FlxG.width - 150, FlxG.height - 70, .9);
		leaveButton.antialiasing = false;
		leaveButton.loadGraphic("assets/images/getoutbutton.png");
		leaveButton.align(2);
        leaveButton.camera = camShop;
		add(leaveButton);

        priceText1 = new FlxText();
        priceText1.setFormat(PlayState.font, 33, FlxColor.BROWN, CENTER, OUTLINE);
        priceText1.borderColor = FlxColor.YELLOW;
        priceText1.borderSize = 2;
        priceText1.fieldWidth = priceBg.width - 20;
        priceText1.antialiasing = false;
        add(priceText1);

        priceText2 = new FlxText();
        priceText2.setFormat(PlayState.font, 20, FlxColor.BROWN, CENTER, OUTLINE);
        priceText2.borderColor = FlxColor.YELLOW;
        priceText2.borderSize = 2;
        priceText2.fieldWidth = priceBg.width - 20;
        priceText2.antialiasing = false;
        add(priceText2);

        priceText3 = new FlxText();
        priceText3.setFormat(PlayState.font, 28, FlxColor.BROWN, CENTER, OUTLINE);
        priceText3.borderColor = FlxColor.YELLOW;
        priceText3.borderSize = 2;
        priceText3.fieldWidth = priceBg.width - 20;
        priceText3.antialiasing = false;
        add(priceText3);
        
        this.exit = exit;
    }

    override function update(elapsed:Float):Void{
        super.update(elapsed);

        handleScrolling(elapsed);

        for(i in 0...itemSprites.members.length){
            var spr = itemSprites.members[i];
            var item = items[i];

            if(FlxG.mouse.overlaps(spr, spr.camera) && FlxG.mouse.justPressed){
                if(!boughtItems.contains(item.name)){
                    if(item.cost <= PlayState.ducks){
                        PlayState.ducks -= item.cost;
                        boughtItems.push(item.name);
                        spr.updateSpr();
                        updatePriceBox(item);
                    } else {
                        // not enough money
                    }
                } else {
                    //
                }
            }
        }
        
        if(FlxG.mouse.overlaps(leaveButton) && FlxG.mouse.justPressed){
            exit();
            close();
        }
    }

    function handleScrolling(elapsed:Float):Void{
        var maxScroll = FlxMath.bound(120 * (items.length - 3), 0);

        if(FlxG.mouse.x < FlxG.width / 2){ // left side of screen
            targetScrollY -= (FlxG.mouse.wheel * 2000) * elapsed;
        }
        
        targetScrollY = FlxMath.bound(targetScrollY, 0, maxScroll);

        camShopItem.scroll.y = CtUtil.lerpThing(camShopItem.scroll.y, targetScrollY, elapsed, 15);
    }

    function updatePriceBox(item:Item):Void{
        priceBg.alpha = 1;

        priceText1.text = item.name;
        
        CtUtil.centerSpriteOnSprite(priceText1, priceBg, true, false);
        priceText1.y = priceBg.y + 10;

        priceText2.text = item.description + "\n\n" + item.effect;
        CtUtil.centerSpriteOnSprite(priceText2, priceBg, true, false);
        priceText2.y = priceText1.y + priceText1.height + 10;

        if(ShopState.boughtItems.contains(item.name)){
            priceText3.text = "BOUGHT !! :)";
        } else {
            priceText3.text = "COST: " + item.cost + " Ducks";
        }
        CtUtil.centerSpriteOnSprite(priceText3, priceBg, true, false);
        priceText3.y = priceBg.y + priceBg.height - 25 - priceText3.height;

    }
}