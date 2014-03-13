package;

import knave.Screen;
import knave.AsciiDisplay;
import knave.Color;

class EndScreen extends Screen {
    private var playScreen:PlayScreen;

    public function new(playScreen:PlayScreen){
        super();

        this.playScreen = playScreen;

        on("enter", function():Void { 
            switchTo(new WorldGenScreen());
        });
        on("draw", draw);
    }

    private function draw(display:AsciiDisplay):Void {
        display.clear();
        playScreen.draw(display);

        var fg = Color.hsv(60, 90, 90).toInt();
        var bg = new Color(0,0,0);
        display.writeCenter("you are dead", 2, fg);
        display.writeCenter("-- press [enter] to restart --", 4, fg);
        display.update();
    }
} 
