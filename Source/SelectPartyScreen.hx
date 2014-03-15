package;

import knave.*;

class SelectPartyScreen extends Screen {
    private var party:Array<Creature>;
    private var list:Array<Creature>;

    public function new(){
        super();

        Factory.init();
        party = new Array<Creature>();
        newList();

        on("a", accept, 0);
        on("b", accept, 1);
        on("c", accept, 2);
        on("d", accept, 3);
        on("e", accept, 4);
        on("n", newList);
        on("enter", function():Void { 
            if (party.length > 0)
                switchTo(new WorldGenScreen(party));
        });
        on("draw", draw);
    }

    private function newList():Void {
        list = new Array<Creature>();

        for (i in 0 ... 5)
            list.push(Factory.hero());
        if (rl != null)
            rl.trigger("redraw");
    }

    private function accept(index:Int):Void {
        party.push(list[index]);
        newList();
    }

    private function draw(display:AsciiDisplay):Void {
        display.clear();

        var hilight = Color.hsv(60, 90, 90).toInt();

        display.writeCenter("-- press [a] through [e] to add to your party, [n] to view the next set of recruits --", 2, hilight);

        var x = 6;
        var y = 4;
        var i = 0;
        for (c in list) {
            display.write("[" + ("abcdef".charAt(i++)) + ']', x-5, y, hilight);

            CharacterDisplay.display(c, display, x, y, true);

            y = display.cursorY + 2;
        }

        if (party.length > 0)
            display.writeCenter("-- press [enter] to enter the dice mines --", display.heightInCharacters - 2, hilight);
        display.update();
    }
} 
