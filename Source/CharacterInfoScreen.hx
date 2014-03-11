package;

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

        var x = 3;
        var y = 2;
        display.write(player.name, x-1, y++);
        y++;
        display.write("hp: " + player.hp + "/" + player.maxHp, x, y++);
        y++;
        display.write("accuracy:   " + breakdown(player.accuracyStat), x, y++);
        display.write("evasion:    " + breakdown(player.evasionStat), x, y++);
        display.write("damage:     " + breakdown(player.damageStat), x, y++);
        display.write("resistance: " + breakdown(player.resistanceStat), x, y++);
        y++;
        display.write("sword: " + (player.meleeWeapon == null ? " - no sword - " : player.meleeWeapon.describe()), x, y++);
        display.write("bow:   " + (player.rangedWeapon == null ? " - no bow - " : player.rangedWeapon.describe()), x, y++);
        display.write("armor: " + (player.armor == null ? " - no armor - " : player.armor.describe()), x, y++);
        y++;

        display.write("Special actions:", x-1, y++);
        y++;
        for (action in player.actions) {
            display.write(action.name, x, y++);
            y++;
        }

        display.update();
    }

    private function breakdown(dice:String):String {
        var number = Std.parseInt(dice.split("d")[0]);
        var sides = Std.parseInt(dice.split("d")[1].split("+")[0]);
        var bonus = Std.parseInt(dice.split("+")[1]);
        var min = number + bonus;
        var max = number * sides + bonus;
        var avg = Math.floor((min + max) / 2);
        return '$dice  [ $min to $max, $avg average ]';
    }
}
