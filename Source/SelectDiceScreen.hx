package;

import knave.*;

class SelectDiceScreen extends Screen {
    private var world:PlayScreen;
    private var player:Creature;
    private var callbackFunction:Int -> Int -> Void;
    private var number:Int = 1;
    private var sides:Int = 1;
    private var section:Int = 0;

    public function new(world:PlayScreen, player:Creature, callbackFunction: Int -> Int -> Void) {
        super();
        this.world = world;
        this.player = player;
        this.callbackFunction = callbackFunction;

        on("1", accept, 1);
        on("2", accept, 2);
        on("3", accept, 3);
        on("4", accept, 4);
        on("5", accept, 5);
        on("6", accept, 6);
        on("7", accept, 7);
        on("8", accept, 8);
        on("9", accept, 9);
        on("escape", exit);
        on("enter", function():Void { 
            exit();
            if (player.dice[sides-1] >= number) {
                callbackFunction(number, sides);
            }
            rl.trigger("redraw");
        });
        on("draw", draw);
    }

    private function accept(amount:Int):Void {
        if (section == 0) {
            number = amount;
            section++;
        } else {
            sides = amount;
            section = 0;
        }
        rl.trigger("redraw");
    }
    
    private function draw(display:AsciiDisplay):Void {
        world.draw(display);

        var fg = new Color(200, 200, 200).toInt();
        var bg = new Color(4, 4, 8).toInt();

        var dice = new Array<String>();
        for (i in 0 ... 9) {
            if (player.dice[i] == 0)
                continue;
            dice.push(player.dice[i] + "d" + (i+1));
        }
        var description = dice.join(" ");

        var y = 12;
        display.writeCenter("                                     ", y++, fg, bg);
        display.writeCenter("  You have:                          ", y++, fg, bg);
        display.writeCenter("                                     ", y++, fg, bg);
        display.writeCenter("                                     ", y, fg, bg);
        display.writeCenter( description, y++, fg, bg);
        display.writeCenter("                                     ", y++, fg, bg);
        display.writeCenter("  How many dice do you want to use?  ", y++, fg, bg);
        display.writeCenter("                                     ", y++, fg, bg);
        display.writeCenter('  ${number}d$sides                                ', y++, fg, bg);
        display.writeCenter("                                     ", y++, fg, bg);
        display.writeCenter("     [1-9] or [escape] or [enter]    ", y++, fg, bg);
        display.writeCenter("                                     ", y++, fg, bg);
        display.update();
    }
}
