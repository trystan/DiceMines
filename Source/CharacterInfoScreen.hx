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

        var light = Color.hsv(60, 20, 99).toInt();
        var x = 3;
        var y = 2;
        display.write(player.name, x-1, y++, light);
        y++;
        display.write("hp: " + player.hp + "/" + player.maxHp, x, y++);
        y++;
        display.write("Stats:              [ min agv max ]", x-1, y++, light);
        display.write("accuracy:   " + breakdown(player.accuracyStat), x, y++);
        display.write("damage:     " + breakdown(player.damageStat), x, y++);
        display.write("evasion:    " + breakdown(player.evasionStat), x, y++);
        display.write("resistance: " + breakdown(player.resistanceStat), x, y++);
        display.write("piety:      " + breakdown(player.pietyStat), x, y++);
        y++;
        display.write("Equipment:   (only affects stats when used)", x-1, y++, light);
        display.write("sword: " + (player.meleeWeapon == null ? " - no sword - " : player.meleeWeapon.describe()), x, y++);
        display.write("bow:   " + (player.rangedWeapon == null ? " - no bow - " : player.rangedWeapon.describe()), x, y++);
        display.write("armor: " + (player.armor == null ? " - no armor - " : player.armor.describe()), x, y++);
        y++;

        display.write("Special abilities:", x-1, y++, light);
        for (ability in player.abilities) {
            display.write(ability.name, x, y++);
            display.write(ability.description, x + 2, y++);
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
        return StringTools.lpad(dice, " ", 6)
            + " [ " + StringTools.lpad(min + "", " ", 3)
            + " " + StringTools.lpad(avg + "", " ", 3)
            + " " + StringTools.lpad(max + "", " ", 3)
            + " ]";
    }
}
