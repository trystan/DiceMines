package;

import knave.*;

class CharacterDisplay {
    
    public static function display(hero:Creature, display:AsciiDisplay, x:Int, y:Int, compact:Bool):Void {
        var light = Color.hsv(60, 90, 90).toInt();

        display.write(StringTools.rpad(hero.fullName, ' ', 20), x-1, y, light);
        if (compact) {
            display.write("[ min avg max ] ");
        } else {
            y++;
            display.write("Stats               [ min agv max ]", x-1, y, light);
        }
        y++;
        display.write("accuracy    " + breakdown(hero.effectiveAccuracyStat("idle")), x, y++);
        display.write("damage      " + breakdown(hero.effectiveDamageStat("idle")), x, y++);
        display.write("evasion     " + breakdown(hero.effectiveEvasionStat("idle")), x, y++);
        display.write("resistance  " + breakdown(hero.effectiveResistanceStat("idle")), x, y++);
        display.write("piety       " + breakdown(hero.effectivePietyStat("idle")), x, y++);
        display.write(hero.hp + "/" + hero.maxHp + " hit points", x, y++);
        y++;

        var hy = y - 8;
        for (line in Text.wordWrap(hero.about, display.widthInCharacters - x - 37))
            display.write(line, x + 35, hy++);

        if (compact) {
            var equipment = new Array<String>();
            if (hero.meleeWeapon != null)
                equipment.push(hero.meleeWeapon.name);
            if (hero.rangedWeapon != null)
                equipment.push(hero.rangedWeapon.name);
            if (hero.armor != null)
                equipment.push(hero.armor.name);

            if (equipment.length > 0)
                display.write("Uses " + Text.andList(equipment) + ".", x, y++);
        } else {
            display.write("Equipment:", x, y++);
            display.write("sword " + (hero.meleeWeapon == null ? "none" : hero.meleeWeapon.describe()), x, y++);
            display.write("bow   " + (hero.rangedWeapon == null ? "none" : hero.rangedWeapon.describe()), x, y++);
            display.write("armor " + (hero.armor == null ? "none" : hero.armor.describe()), x, y++);
            y++;
        }

        if (compact) {
            var list = Lambda.array(Lambda.map(hero.abilities, function(a):String { return a.name.toLowerCase(); }));
            if (list.length > 0)
                display.write("Knows " + Text.andList(list) + ".", x, y++);
        } else {
            display.write("Special abilities:", x-1, y++, light);
            for (ability in hero.abilities) {
                display.write(ability.name, x, y++);
                display.write(ability.description, x + 2, y++);
                y++;
            }
        }
    }

    private static function breakdown(dice:String):String {
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
