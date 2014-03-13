package knave;

import flash.display.Sprite;
import flash.display.StageDisplayState; 
import flash.display.StageScaleMode; 
import flash.display.BitmapData;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.Event;

import flash.Lib;

class RLBuilder {

    public var rl:RL;
    public var display:AsciiDisplay;
    public var helperSprite:HelperSprite;

    public function new(){
        rl = new RL();
    }

    public function useAsciiDisplay(widthInCharacters:Int, heightInCharacters:Int):RLBuilder {
        display = new AsciiDisplay(widthInCharacters, heightInCharacters);
        rl.on("redraw", function():Void { rl.trigger("draw", display); });
        helperSprite = new HelperSprite(rl, display);
        return this;
    }

    public function useFont(font:BitmapData, characterWidth:Int, characterHeight:Int):RLBuilder {
        display.useFont(font, characterWidth, characterHeight);
        rl.trigger("redraw");
        return this;
    }

    public function toggleFullScreenWith(key:String):RLBuilder {
        rl.on(key, function():Void {
            if (display.stage.displayState != StageDisplayState.NORMAL)
                display.stage.displayState = StageDisplayState.NORMAL;
            else
                display.stage.displayState = StageDisplayState.FULL_SCREEN;

            display.useSize(Math.floor(display.stage.stageWidth / display.characterWidth), Math.floor(display.stage.stageHeight / display.characterHeight));
            rl.trigger("redraw");
        });
        return this;
    }

    public function addToSprite(mainSprite:Sprite):RLBuilder {
        mainSprite.addChild(helperSprite);
        display.centerOnStage();
        return this;
    }

    public function withScreen(startingScreen:Screen):RLBuilder {
        rl.enter(startingScreen);
        return this;
    }

    public function on(message:String, messageOrFunc:Dynamic, args:Dynamic = null):RLBuilder {
        rl.on(message, messageOrFunc, args);
        return this;
    }

    public function useHJKLYUBN():RLBuilder {
      on("h", "left");
      on("l", "right");
      on("k", "up");
      on("j", "down");
      on("y", "up left");
      on("u", "up right");
      on("b", "down left");
      on("n", "down right");
      return this;
    }

    public function useNumpad():RLBuilder {
      on("numpad 4", "left");
      on("numpad 6", "right");
      on("numpad 8", "up");
      on("numpad 2", "down");
      on("numpad 7", "up left");
      on("numpad 9", "up right");
      on("numpad 1", "down left");
      on("numpad 3", "down right");
      on("numpad 5", ".");
      return this;
    }
}

class HelperSprite extends flash.display.Sprite {
    private var rl:RL;
    private var display:AsciiDisplay;

    public function new(rl:RL, display:AsciiDisplay) {
        super();
        this.rl = rl;
        this.display = display;

        if (stage != null) init();
        else addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(e:Event = null):Void {
        removeEventListener(Event.ADDED_TO_STAGE, init);
        stage.addEventListener(KeyboardEvent.KEY_DOWN, rl.onKeyDown);
        stage.addEventListener(MouseEvent.MOUSE_MOVE, rl.onMouseMove);
        // stage.addEventListener(MouseEvent.CLICK, onMouseEvent);
        stage.addEventListener(Event.ENTER_FRAME, rl.onTick);
        stage.addChild(display);
    }
}
