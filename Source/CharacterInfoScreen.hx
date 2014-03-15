package;

import StringTools;
import knave.*;

class CharacterInfoScreen extends Screen {
    private var world:PlayScreen;
    private var party:Array<Creature>;
    private var index:Int = 0;

    public function new(world:PlayScreen, party:Array<Creature>) {
        super();
        this.world = world;
        this.party = party;

        on("v", exit);
        on("p", function() {
            index--;
            if (index < 0)
                index = party.length - 1;
            rl.trigger("redraw");
        });
        on("n", function(){
            index++;
            if (index == party.length)
                index = 0;
            rl.trigger("redraw");
        });
        on("escape", exit);
        on("enter", exit);
        on("draw", draw);
    }
    
    private function draw(display:AsciiDisplay):Void {
        display.clear();

        CharacterDisplay.display(party[index], display, 3, 2, false);

        display.writeCenter("-- [p]revious party member, [n]ext party member --", display.heightInCharacters - 2, Color.hsv(60, 90, 90).toInt());

        display.update();
    }
}
