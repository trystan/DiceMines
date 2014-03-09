package test;
import knave.*;

import flash.events.KeyboardEvent;
import flash.events.Event;

class RLTests extends haxe.unit.TestCase {

    public function test_exposes_bindings():Void {
        var rl = new RL();
        var called = false;
        rl.on("a", function():Void { called = true; });
        rl.trigger("a");
        assertEquals(true, called);
    }

    public function test_can_enter_a_new_scree():Void {
        var rl = new RL();
        var screen = new Screen();
        rl.enter(screen);
        assertEquals(screen, rl.currentScreen);
    }

    public function test_can_exit_to_previous_screen():Void {
        var rl = new RL();
        var screen1 = new Screen();
        var screen2 = new Screen();
        rl.enter(screen1);
        assertEquals(screen1, rl.currentScreen);
        rl.enter(screen2);
        assertEquals(screen2, rl.currentScreen);
        rl.exit();
        assertEquals(screen1, rl.currentScreen);
    }

    public function test_can_switch_to_other_screen():Void {
        var rl = new RL();
        var screen1 = new Screen();
        var screen2 = new Screen();
        rl.enter(screen1);
        rl.switchTo(screen2);
        assertEquals(screen2, rl.currentScreen);
        rl.exit();
        assertEquals(null, rl.currentScreen);
    }

    public function test_triggered_messages_are_passed_to_current_screen():Void {
        var rl = new RL();
        var messages = new Array<String>();
        var screen = new Screen();
        screen.on("a", function():Void { messages.push("a"); });
        rl.enter(screen);
        rl.trigger("a");
        assertEquals("a", messages[0]);
    }

    public function test_triggers_tick_events():Void {
        var rl = new RL();
        var called = false;
        var screen = new Screen();
        screen.on("tick", function():Void { called = true; });
        rl.enter(screen);
        rl.onTick(new Event(Event.ENTER_FRAME));
        assertEquals(true, called);
    }

    public function test_triggers_keyboard_events_on_tick():Void {
        var rl = new RL();
        var called = false;
        var screen = new Screen();
        screen.on("A", function():Void { called = true; });
        rl.enter(screen);
        rl.onKeyDown(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, 65, 65));
        rl.onTick(new Event(Event.ENTER_FRAME));
        assertEquals(true, called);
    }
}
