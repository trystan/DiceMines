package knave;

class Screen {
    private var bindings:Bindings;
    public var rl:RL;

    public function new(bindings:Bindings = null) {
        this.bindings = bindings != null ? bindings : new Bindings();
    }

    public function on(message:String, messageOrFunc:Dynamic, arg:Dynamic = null):Void {
        bindings.on(message, messageOrFunc, arg);
    }

    public function trigger(message:String, arg:Dynamic = null):Void {
        bindings.trigger(message, arg);
    }

    public function enter(screen:Screen):Void {
        rl.enter(screen);
    }

    public function exit():Void {
        rl.exit();
    }

    public function switchTo(screen:Screen):Void {
        rl.switchTo(screen);
    }
}
