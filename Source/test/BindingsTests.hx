package test;
import knave.*;

class BindingsTests extends haxe.unit.TestCase {

    public function test_trigger_calls_subscribbed_callbacks():Void {
        var bindings = new Bindings();
        var wasCalled = false;
        bindings.on("a", function():Void {
            wasCalled = true;
        });
        bindings.trigger("a");
        assertEquals(true, wasCalled);
    }

    public function test_trigger_calls_subscribbed_callbacks_in_order():Void {
        var bindings = new Bindings();
        var messages = new Array<String>();
        bindings.on("a", function():Void {
            bindings.trigger("b");
            messages.push("a");
        });
        bindings.on("b", function():Void {
            bindings.trigger("c");
            messages.push("b");
        });
        bindings.on("c", function():Void {
            messages.push("c");
        });
        bindings.trigger("a");
        assertEquals("a", messages[0]);
        assertEquals("b", messages[1]);
        assertEquals("c", messages[2]);
    }

    public function test_can_have_multiple_callbacks():Void {
        var bindings = new Bindings();
        var times = 0;
        bindings.on("a", function():Void { times++; });
        bindings.on("a", function():Void { times++; });
        bindings.trigger("a");
        assertEquals(2, times);
    }

    public function test_callback_can_be_another_message():Void {
        var bindings = new Bindings();
        var messages = new Array<String>();
        bindings.on("a", "b");
        bindings.on("a", function():Void { messages.push("a"); });
        bindings.on("b", function():Void { messages.push("b"); });
        bindings.trigger("a");
        assertEquals("a", messages[0]);
        assertEquals("b", messages[1]);
    }

    public function test_bindings_can_have_an_argument():Void {
        var bindings = new Bindings();
        var args = new Array<String>();
        bindings.on("a", function(x:String):Void { args.push(x); }, "testing");
        bindings.trigger("a");
        assertEquals("testing", args[0]);
    }

    public function test_triggers_can_have_an_argument():Void {
        var bindings = new Bindings();
        var args = new Array<String>();
        bindings.on("a", function(x:String):Void { args.push(x); });
        bindings.trigger("a", "testing");
        assertEquals("testing", args[0]);
    }

    public function test_trigger_argument_overrides_binding_argument():Void {
        var bindings = new Bindings();
        var args = new Array<String>();
        bindings.on("a", function(x:String):Void { args.push(x); }, "binding");
        bindings.trigger("a", "trigger");
        assertEquals("trigger", args[0]);
    }

    public function test_other_message_argument_overrides_binding_argument():Void {
        var bindings = new Bindings();
        var args = new Array<String>();
        bindings.on("a", "b", "other");
        bindings.on("b", function(x:String):Void { args.push(x); }, "binding");
        bindings.trigger("a");
        assertEquals("other", args[0]);
    }

    public function test_trigger_argument_overrides_other_message_argument():Void {
        var bindings = new Bindings();
        var args = new Array<String>();
        bindings.on("a", "b", "other");
        bindings.on("b", function(x:String):Void { args.push(x); }, "binding");
        bindings.trigger("a", "trigger");
        assertEquals("trigger", args[0]);
    }

    public function test_ignores_messages_wihtout_callbacks():Void {
        var bindings = new Bindings();
        var args = new Array<String>();
        bindings.on("a", "b");
        bindings.trigger("b");
        assertEquals(true, true);
    }
}
