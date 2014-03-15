package;

import flash.display.Sprite;
import haxe.ds.Vector;
import knave.*;
import test.*;

import StringTools;

class Main extends Sprite {

    public function new() {
        super ();

        var r = new haxe.unit.TestRunner();
        r.add(new AsciiDisplayTests());
        r.add(new BindingsTests());
        r.add(new ScreenTests());
        r.add(new RLTests());
        if (!r.run())
            return;

        var rl = new RLBuilder()
            .useAsciiDisplay(Math.floor(stage.stageWidth / 12), Math.floor(stage.stageHeight / 12))
            .useFont(AsciiDisplay.codePage437_12x12, 12, 12)
            .useHJKLYUBN()
            .useNumpad()
            .withScreen(new SelectPartyScreen())
            .addToSprite(this);
    }
}
