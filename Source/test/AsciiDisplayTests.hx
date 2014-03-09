package test;
import knave.*;

class AsciiDisplayTests extends haxe.unit.TestCase {

#if neko
    private var black:Int = 0xff000000;
    private var gray:Int = 0xffc0c0c0;
#else
    private var black:Int = 0x000000;
    private var gray:Int = 0xc0c0c0;
#end

    public function test_display_starts_empty():Void {
        var display = new AsciiDisplay();
        assertEquals(" ", display.getChar(0,0));
    }
    
    public function test_display_returns_0_when_getting_out_of_bounds():Void {
        var display = new AsciiDisplay();
        assertEquals(0, display.getCharCode(-1, 0));
        assertEquals(0, display.getCharCode( 0,-1));
        assertEquals(0, display.getCharCode(99, 0));
        assertEquals(0, display.getCharCode( 0,99));
    }

    public function test_display_can_set_char():Void {
        var display = new AsciiDisplay();
        display.setChar(0,0, "a");
        assertEquals("a", display.getChar(0,0));
    }
    
    public function test_display_can_write_string():Void {
        var display = new AsciiDisplay();
        display.write("pizza", 1, 1);
        assertEquals(" ", display.getChar(0,1));
        assertEquals("p", display.getChar(1,1));
        assertEquals("i", display.getChar(2,1));
        assertEquals("z", display.getChar(3,1));
        assertEquals("z", display.getChar(4,1));
        assertEquals("a", display.getChar(5,1));
    }

    public function test_display_write_defaults_to_after_last_position():Void {
        var display = new AsciiDisplay();
        display.write("pizza", 1, 1);
        display.write("s");
        assertEquals("a", display.getChar(5,1));
        assertEquals("s", display.getChar(6,1));
    }

    public function test_display_write_wraps_at_end_of_line():Void {
        var display = new AsciiDisplay();
        display.write("pizza", 77, 1);
        assertEquals("z", display.getChar(79,1));
        assertEquals("z", display.getChar(0,2));
    }

    public function test_display_can_be_any_size():Void {
        var display = new AsciiDisplay(5, 6);
        assertEquals(5, display.widthInCharacters);
        assertEquals(6, display.heightInCharacters);
    }

    public function test_display_defaults_to_80_by_24():Void {
        var display = new AsciiDisplay();
        assertEquals(80, display.widthInCharacters);
        assertEquals(24, display.heightInCharacters);
    }

    public function test_display_background_color_defaults_to_black():Void {
        var display = new AsciiDisplay();
        assertEquals(black, display.getBackground(1,1));
    }

    public function test_display_background_color_can_be_set():Void {
        var display = new AsciiDisplay();
        display.setBackground(0xff0000, 1, 1);
        assertEquals(0xff0000, display.getBackground(1,1));
    }

    public function test_display_background_color_out_of_bounds_is_black():Void {
        var display = new AsciiDisplay();
        assertEquals(black, display.getBackground(-1,-1));
    }

    public function test_display_foreground_color_defaults_to_gray():Void {
        var display = new AsciiDisplay();
        assertEquals(gray, display.getForeground(1,1));
    }

    public function test_display_foreground_color_can_be_set():Void {
        var display = new AsciiDisplay();
        display.setForeground(0xff0000, 1, 1);
        assertEquals(0xff0000, display.getForeground(1,1));
    }

    public function test_display_foreground_color_out_of_bounds_is_black():Void {
        var display = new AsciiDisplay();
        assertEquals(black, display.getForeground(-1,-1));
    }

    public function test_clear():Void {
        var display = new AsciiDisplay();
        display.write("z", 1, 1);
        display.setBackground(0xffffff, 1, 1);
        display.setForeground(0xffffff, 1, 1);
        display.clear();
        assertEquals(" ", display.getChar(1,1));
    }
}
