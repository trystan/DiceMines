package test;
import knave.*;

class ScreenTests extends haxe.unit.TestCase {

    public function test_exposes_bindings():Void {
        var screen = new Screen();
        var called = false;
        screen.on("a", function():Void { called = true; });
        screen.trigger("a");
        assertEquals(true, called);
    }
}
