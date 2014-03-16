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
            display.write("Stats:              [ min agv max ]", x-1, y, light);
        }
        y++;
        display.write("accuracy    " + breakdown(hero.effectiveAccuracyStat("idle")), x, y++);
        display.write("damage      " + breakdown(hero.effectiveDamageStat("idle")), x, y++);
        display.write("evasion     " + breakdown(hero.effectiveEvasionStat("idle")), x, y++);
        display.write("resistance  " + breakdown(hero.effectiveResistanceStat("idle")), x, y++);
        display.write("piety       " + breakdown(hero.effectivePietyStat("idle")), x, y++);

        if (compact) {
            var totalDice = 0;
            for (i in 0 ... 9)
                totalDice += hero.dice[i];
            display.write(hero.hp + "/" + hero.maxHp + ' hit points, $totalDice total dice', x, y++);
        } else {
            var dice = new Array<String>();
            for (i in 0 ... 9) {
                if (hero.dice[i] == 0)
                    continue;
                dice.push(hero.dice[i] + "d" + (i+1));
            }
            var description = dice.join(" ");
            y++;
            display.write(hero.hp + "/" + hero.maxHp + " hit points", x, y++);
            if (description.length > 0) {
                y++;
                display.write("Has " + description, x, y++);
            }
        }
        y++;

        var hy = y - (compact ? 8 : 10);
        var hx = x + 35;

        if (compact) {
            var equipment = new Array<String>();
            if (hero.meleeWeapon != null)
                equipment.push(hero.meleeWeapon.name);
            if (hero.rangedWeapon != null)
                equipment.push(hero.rangedWeapon.name);
            if (hero.armor != null)
                equipment.push(hero.armor.name);

            for (line in Text.wordWrap(hero.about, display.widthInCharacters - x - 37))
                display.write(line, hx, hy++);

            var moreDetails = "";
            if (equipment.length > 0)
                moreDetails += Text.sentence(hero.name + " uses " + Text.andList(equipment) + ".") + " ";

            var list = Lambda.array(Lambda.map(hero.abilities, function(a):String { return a.name.toLowerCase(); }));
            if (list.length > 0)
                moreDetails += Text.sentence(hero.getSubjectPronoun() + " knows " + Text.andList(list) + ".") + " ";

            if (moreDetails.length > 0) {
                for (line in Text.wordWrap(moreDetails, display.widthInCharacters - x - 37))
                    display.write(line, hx, hy++);
            }

        } else {
            for (line in Text.wordWrap(hero.about, display.widthInCharacters - x - 37))
                display.write(line, hx, hy++);

            display.write('${hero.name} is currently ${cast(hero.ai, AllyAi).currently}', hx, hy++);
            
            display.write("Equipment:", x-1, y++, light);
            if (hero.meleeWeapon != null)
                display.write(hero.meleeWeapon.describe(), x, y++);
            if (hero.rangedWeapon != null)
                display.write(hero.rangedWeapon.describe(), x, y++);
            if (hero.armor != null)
                display.write(hero.armor.describe(), x, y++);
            y++;

            display.write("Special abilities:", x-1, y++, light);
            for (ability in hero.abilities) {
                display.write(ability.name, x, y++);
                display.write(ability.description, x + 2, y++);
                y++;
            }
        }

        display.cursorX = x;
        display.cursorY = Math.floor(Math.max(y, hy));
    }

    private static function breakdown(dice:String):String {
        var d = Dice.fromString(dice);
        var min0 = d.number + d.bonus;
        var max0 = d.number * d.sides + d.bonus;
        var min = Math.floor(Math.min(min0, max0));
        var max = Math.floor(Math.max(min0, max0));
        var avg = Math.floor((min + max) / 2);
        return StringTools.lpad(dice, " ", 6)
            + " [ " + StringTools.lpad(min + "", " ", 3)
            + " " + StringTools.lpad(avg + "", " ", 3)
            + " " + StringTools.lpad(max + "", " ", 3)
            + " ]";
    }
}
