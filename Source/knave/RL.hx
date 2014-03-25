package knave;

import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.Event;

class RL {
    private var bindings:Bindings;
    private var inputTranslator:InputTranslator;
    private var screenStack:Array<Screen>;

    public var currentScreen:Screen;

    public var lastMouseEvent:MouseEvent;
    public var lastKeyboardEvent:KeyboardEvent;

    public function new(bindings:Bindings = null, inputTranslator:InputTranslator = null) {
        this.bindings = bindings != null ? bindings : new Bindings();
        this.inputTranslator = inputTranslator != null ? inputTranslator : new InputTranslator();
        this.screenStack = new Array<Screen>();
    }

    public function onMouseMove(event:MouseEvent):Void {
        lastMouseEvent = event;
    }

    public function onKeyDown(event:KeyboardEvent):Void {
        lastKeyboardEvent = event;
        inputTranslator.handleKeyboard(event);
    }

    public function triggerKeyDown(key:String):Void {
        onKeyDown(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, key.charCodeAt(0), key.charCodeAt(0)));
    }

    public function onTick(event:Event):Void {
        if (lastMouseEvent != null) {
            trigger("mouse", { x: lastMouseEvent.localX, y: lastMouseEvent.localY });
            lastMouseEvent = null;
        }

        if (inputTranslator.last_keyboard_event != null)
        {
            var e = inputTranslator.last_keyboard_event;
            inputTranslator.last_keyboard_event = null;
            var screen = currentScreen;
            screen.trigger(e);
            screen.trigger("keypress", e);
        }

        trigger("tick");
    }

    public function on(message:String, messageOrFunc:Dynamic, args:Dynamic = null):Void {
        if (Std.is(messageOrFunc, String))
            bindings.on(message, function():Void { trigger(messageOrFunc, args); }, args);
        else
            bindings.on(message, messageOrFunc, args);
    }

    public function trigger(message:String, args:Dynamic = null):Void {
        bindings.trigger(message, args);
        if (currentScreen != null)
            currentScreen.trigger(message, args);
    }

    public function enter(screen:Screen):Void {
        screen.rl = this;
        screenStack.push(screen);
        currentScreen = screen;
        trigger("redraw");
    }

    public function exit():Void {
        if (screenStack.length == 0)
            return;

        screenStack.pop();
        currentScreen = screenStack[screenStack.length - 1];
        trigger("redraw");
    }

    public function switchTo(screen:Screen):Void {
        screen.rl = this;
        screenStack.pop();
        screenStack.push(screen);
        currentScreen = screen;
        trigger("redraw");
    }
}
