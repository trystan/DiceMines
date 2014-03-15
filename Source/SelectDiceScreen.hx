package;

import knave.*;

class SelectDiceScreen extends Screen {
    private var player:Creature;
    private var prompt:String;
    private var callbackFunction:Int -> Int -> Void;
    private var number:Int = -1;
    private var sides:Int = -1;
    private var section:Int = 0;

    public function new(player:Creature, prompt:String, callbackFunction: Int -> Int -> Void) {
        super();
        this.player = player;
        this.prompt = prompt;
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
        on("backspace", function() {
            if (section == 2) {
                sides = -1;
                section = 1;
            } else if (section == 1) {
                number = -1;
                section = 0;
            }
            rl.trigger("redraw");
        });
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
        } else if (section == 1) {
            sides = amount;
            section = 2;
        }
        rl.trigger("redraw");
    }
    
    private function draw(display:AsciiDisplay):Void {
        var fg = new Color(200, 200, 200).toInt();
        var bg = new Color(4, 4, 8).toInt();

        var dice = new Array<String>();
        for (i in 0 ... 9) {
            if (player.dice[i] == 0)
                continue;
            dice.push(player.dice[i] + "d" + (i+1));
        }
        var description = dice.join(" ");

        var isBad = section == 2 && player.dice[sides-1] < number;
        var hilight = isBad ? new Color(250, 50, 50).toInt() : new Color(250, 250, 150).toInt();

        var x = Math.floor(display.widthInCharacters / 2 - 30);
        var y = 12;
        display.write("                                                           ", x, y++, fg, bg);
        display.write("                                                           ", x, y, fg, bg);
        display.write("  You have: " + description, x, y++, fg, bg);
        display.write("                                                           ", x, y++, fg, bg);
        display.write("                                                           ", x, y, fg, bg);
        display.write("  " + prompt + " ", x, y, fg, bg);
        switch (section) {
            case 0: display.write("_", null, null, hilight, bg);
            case 1: display.write(number + "d_", null, null, hilight, bg);
            case 2: display.write(number + "d" + sides, null, null, hilight, bg);
        }
        y++;
        display.write("                                                           ", x, y++, fg, bg);
        display.write("  [1-9] or [escape] or [enter]                             ", x, y++, fg, bg);
        display.write("                                                           ", x, y++, fg, bg);
        display.update();
    }
}
