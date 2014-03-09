package knave;

class Bindings {

    private var subscribers:Map<String, Array<Dynamic>>;
    private var queue:Array<{ message:String, arg:Dynamic }>;
    private var isProcessing = false;

    public function new() {
        subscribers = new Map<String, Array<Dynamic>>();
        queue = new Array<{ message:String, arg:Dynamic }>();
    }

    public function on(message:String, messageOrFunc:Dynamic, arg:Dynamic = null):Void {
        if (subscribers[message] == null)
            subscribers[message] = new Array<Dynamic>();
        subscribers[message].push({ func:messageOrFunc, arg:arg });
    }

    public function trigger(message:String, arg:Dynamic = null):Void {
        queue.push({ message:message, arg:arg });
        process();
    }

    private function process():Void {
        if (isProcessing)
            return;

        isProcessing = true;
        while (queue.length > 0) {
            var message = queue.shift();
            if (subscribers[message.message] == null)
                continue;

            for (handler in subscribers[message.message]) {
                if (Std.is(handler.func, String)) {
                    var arg = message.arg == null ? handler.arg : message.arg;
                    trigger(cast(handler.func, String), arg);
                } else if (message.arg != null)
                    handler.func(message.arg);
                 else if (handler.arg != null)
                    handler.func(handler.arg);
                else
                    handler.func();
            }
        }
        isProcessing = false;
    }
}
