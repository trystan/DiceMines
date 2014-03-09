package;

import knave.Screen;
import knave.AsciiDisplay;
import knave.Color;

class EndScreen extends Screen {
    public function new(){
            super();

        on("enter", function():Void { 
            switchTo(new PlayScreen());
            rl.trigger("redraw");
        });
        on("draw", draw);
    }

    private function draw(display:AsciiDisplay):Void {
        var color = new Color(200, 200, 200).toInt();
        display.write("You died.", 2, 2, color);
        display.write("Press [enter] to restart", 2, 4, color);
        display.update();
    }
} 
