package knave;

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.PixelSnapping;
import flash.geom.Rectangle;
import flash.geom.Point;
import openfl.Assets;

class AsciiDisplay extends Sprite {
    public static var codePage437_9x16:BitmapData;
    // Much thanks to Alloy for this png from http://dwarffortresswiki.org/index.php/File:Alloy_curses_12x12.png
    public static var codePage437_12x12:BitmapData;
   
    public var widthInCharacters:Int = 1;
    public var heightInCharacters:Int = 1;
    public var characterWidth:Int = 1;
    public var characterHeight:Int = 1;

    public var cursorX:Int;
    public var cursorY:Int;

    public var forceRedrawAll:Bool;

    private var charCodes:Array<Array<Int>>;
    private var background:Array<Array<Int>>;
    private var foreground:Array<Array<Int>>;
    private var oldCharCodes:Array<Array<Int>>;
    private var oldBackground:Array<Array<Int>>;
    private var oldForeground:Array<Array<Int>>;
    private var screenBitmapData:BitmapData;
    private var bitmapChild:Bitmap;
    private var glyphs:Array<BitmapData>;

#if neko
    private var fontBg:Int = 0xff000000;
    private var fontFg:Int = 0xffc0c0c0;
#else
    private var fontBg:Int = 0x000000;
    private var fontFg:Int = 0xc0c0c0;
#end

    public function new(widthInCharacters = 80, heightInCharacters = 24) {
        if (codePage437_9x16 == null)
            codePage437_9x16 = Assets.getBitmapData("assets/cp437_9x16.png");
        
        if (codePage437_12x12 == null)
            codePage437_12x12 = Assets.getBitmapData("assets/cp437_12x12.png");

        super();

        useSize(widthInCharacters, heightInCharacters);
        useFont(codePage437_9x16, 9, 16);

        scaleX = 1;
        scaleY = 1;
    }

    public function useSize(widthInCharacters:Int, heightInCharacters:Int):Void {
        this.widthInCharacters = widthInCharacters;
        this.heightInCharacters = heightInCharacters;
        this.charCodes = makeGrid(" ".charCodeAt(0));
        this.background = makeGrid(fontBg);
        this.foreground = makeGrid(fontFg);
        this.oldCharCodes = makeGrid(" ".charCodeAt(0));
        this.oldBackground = makeGrid(fontBg);
        this.oldForeground = makeGrid(fontFg);
        this.forceRedrawAll = true;

        redoBitmap();
    }

    public function useFont(font:BitmapData, w:Int, h:Int):Void {
        this.characterWidth = w;
        this.characterHeight = h;
        this.forceRedrawAll = true;

        var fontWidthInCharacters = font.width / w;
        var origin = new Point(0, 0);
        this.glyphs = [];
        for (i in 0 ... 256) {
            var sx = Math.floor(i % fontWidthInCharacters) * characterWidth;
            var sy = Math.floor(i / fontWidthInCharacters) * characterHeight;
            var box = new Rectangle(sx, sy, characterWidth, characterHeight); 
            glyphs[i] = new BitmapData(characterWidth, characterHeight);
            glyphs[i].copyPixels(font, box, origin);
        }

        redoBitmap();
    }

    private function redoBitmap():Void {
        if (bitmapChild != null)
            removeChild(bitmapChild);

        screenBitmapData = new BitmapData(widthInCharacters * characterWidth, heightInCharacters * characterHeight, false, fontBg);
        bitmapChild = new Bitmap(screenBitmapData, PixelSnapping.AUTO, false);
        addChild(bitmapChild);
        centerOnStage();
    }

    private function makeGrid<T>(value:T):Array<Array<T>> {
        var grid = new Array<Array<T>>();
        for (x in 0 ... widthInCharacters) {
            var row = [];
            for (y in 0 ... heightInCharacters)
                row.push(value);
            grid.push(row);
        }
        return grid;
    }

    public function setBackground(color:Int, x:Int, y:Int):Void {
        if (x < 0 || y < 0 || x >= widthInCharacters || y >= heightInCharacters)
            return;

        background[x][y] = color;
    }

    public function getBackground(x:Int, y:Int):Int {
        if (x < 0 || y < 0 || x >= widthInCharacters || y >= heightInCharacters)
            return fontBg;

        return background[x][y];
    }

    public function setForeground(color:Int, x:Int, y:Int):Void {
        if (x < 0 || y < 0 || x >= widthInCharacters || y >= heightInCharacters)
            return;

        foreground[x][y] = color;
    }

    public function getForeground(x:Int, y:Int):Int {
        if (x < 0 || y < 0 || x >= widthInCharacters || y >= heightInCharacters)
            return fontBg;

        return foreground[x][y];
    }

    public function setCharCode(x:Int, y:Int, charCode:Int):Void {
        if (x < 0 || y < 0 || x >= widthInCharacters || y >= heightInCharacters)
            return;

        charCodes[x][y] = charCode;
    }

    public function getCharCode(x:Int, y:Int):Int {
        if (x < 0 || y < 0 || x >= widthInCharacters || y >= heightInCharacters)
            return 0;

        return charCodes[x][y];
    }

    public function setChar(x:Int, y:Int, char:String):Void {
        setCharCode(x, y, char.charCodeAt(0));
    }

    public function getChar(x:Int, y:Int):String {
        return String.fromCharCode(getCharCode(x, y));
    }

    public function clear():Void {
        var defaultCharCode = " ".charCodeAt(0);
        for (x in 0 ... widthInCharacters)
        for (y in 0 ... heightInCharacters) {
            charCodes[x][y] = defaultCharCode;
            background[x][y] = fontBg;
            foreground[x][y] = fontFg;
        }
    }

    public function write(string:String, ?x:Int = null, ?y:Int = null, ?fg:Int = null, ?bg:Int = null):Void {
        if (x != null) cursorX = x;
        if (y != null) cursorY = y;

        for (i in 0 ... string.length) {
            if (cursorX >= widthInCharacters) {
                cursorX = 0;
                cursorY++;
            }

            setChar(cursorX, cursorY, string.charAt(i));
            if (fg != null)
                setForeground(fg, cursorX, cursorY);
            if (bg != null)
                setBackground(bg, cursorX, cursorY);
            cursorX++;
        }
    }

    public function writeCenter(string:String, ?y:Int = null, ?fg:Int = null, ?bg:Int = null):Void {
        write(string, Math.floor((widthInCharacters - string.length) / 2), y, fg, bg);
    }

    public function centerOnStage():Void {
        if (stage != null && bitmapChild != null) {
            bitmapChild.x = x = (stage.stageWidth - bitmapChild.width) / 2;
            bitmapChild.y = y = (stage.stageHeight - bitmapChild.height) / 2;
            stage.invalidate();
        }
    }

    public function update():Void {
        screenBitmapData.lock();
        try {
            var sourceRect:Rectangle = new Rectangle(0, 0, characterWidth, characterHeight);

            for (x in 0 ... widthInCharacters)
            for (y in 0 ... heightInCharacters) {
                if (!forceRedrawAll
                        && oldForeground[x][y] == foreground[x][y]
                        && oldBackground[x][y] == background[x][y]
                        && oldCharCodes[x][y] == charCodes[x][y])
                    continue;

                oldForeground[x][y] = foreground[x][y];
                oldBackground[x][y] = background[x][y];
                oldCharCodes[x][y] = charCodes[x][y];

                var bitmapdata:BitmapData = glyphs[charCodes[x][y]];
                var destPoint = new Point(x * characterWidth, y * characterHeight);

                if (background[x][y] != fontBg || foreground[x][y] != fontFg)
                {
                    var destRect = new Rectangle(x * characterWidth, y * characterHeight, characterWidth, characterHeight);
                    var pixels = bitmapdata.getVector(sourceRect); 
                    
                    for(index in 0 ... pixels.length)
                    {
                        if(Std.int(pixels[index]) == 0xff000000)
                            pixels[index] = background[x][y];
                        else if(foreground[x][y] != fontFg)
                           pixels[index] = foreground[x][y];
                    }
                    screenBitmapData.setVector(destRect, pixels);
                } else {
                    screenBitmapData.copyPixels(bitmapdata, sourceRect, destPoint);
                }
            }
        }
        catch (e:Dynamic)
        {
            screenBitmapData.unlock();
            throw e;
        }
        screenBitmapData.unlock();
        forceRedrawAll = false;
    }
}
