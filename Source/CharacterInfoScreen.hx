package;

import StringTools;
import knave.*;

class CharacterInfoScreen extends Screen {
    private var world:PlayScreen;
    private var player:Creature;

    public function new(world:PlayScreen, player:Creature) {
        super();
        this.world = world;
        this.player = player;

        on("@", exit);
        on("escape", exit);
        on("enter", exit);
        on("draw", draw);
    }
    
    private function draw(display:AsciiDisplay):Void {
        display.clear();

        CharacterDisplay.display(player, display, 3, 2, false);

        display.update();
    }
}
