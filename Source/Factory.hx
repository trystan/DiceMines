package;

import StringTools;
import knave.Color;

class Factory {

    private static function maybeBig(c:Creature, z:Int):Creature {
        var chance = z * 2;
        if (Math.random() * 100 > chance)
            return c;

        c.glyph = c.glyph.toUpperCase();
        c.name = "big " + c.name;
        c.fullName = "the " + c.name;

        c.maxHp += 10;
        c.hp += 10;
        c.accuracyStat = Dice.add(c.accuracyStat, "1d2+1");
        c.evasionStat = Dice.add(c.evasionStat, "1d2+1");
        c.damageStat = Dice.add(c.damageStat, "1d1+2");
        c.resistanceStat = Dice.add(c.resistanceStat, "1d2+1");

        return c;
    }

    public static function spider(z:Int):Creature {
        var c = new Creature("s", "spider", 0, 0, 0);
        c.accuracyStat = "5d5+" + Math.floor(5 + z / 3);
        return maybeBig(c, z);
    }

    public static function bear(z:Int):Creature {
        var c = new Creature("b", "bear", 0, 0, 0);
        c.damageStat = "5d5+" + Math.floor(5 + z / 3);
        return maybeBig(c, z);
    }

    public static function ghost(z:Int):Creature {
        var c = new Creature("g", "ghost", 0, 0, 0);
        c.evasionStat = "5d5+" + Math.floor(5 + z / 3);
        return maybeBig(c, z);
    }

    public static function elemental(z:Int):Creature {
        var c = new Creature("e", "earth elemental", 0, 0, 0, "n");
        c.resistanceStat = "5d5+" + Math.floor(5 + z / 3);
        return maybeBig(c, z);
    }

    public static function orc(z:Int):Creature {
        var c = new Creature("o", "orc", 0, 0, 0);

        c.accuracyStat = Dice.add(c.accuracyStat, "1d1+1");
        c.evasionStat = Dice.add(c.evasionStat, "1d1+1");
        c.damageStat = Dice.add(c.damageStat, "1d1+1");
        c.resistanceStat = Dice.add(c.resistanceStat, "1d1+1");
        
        if (Math.random() < 0.5)
            c.meleeWeapon = meleeWeapon();
        else
            c.rangedWeapon = rangedWeapon();

        if (Math.random() < 0.5)
            c.armor = armor();
        return maybeBig(c, z);
    }

    public static function enemy(z:Int):Creature {
        switch (Math.floor(Math.random() * 5)) {
            case 0: return spider(z);
            case 1: return bear(z);
            case 2: return ghost(z);
            case 3: return elemental(z);
            default: return orc(z);
        }
    }

    public static function rangedWeapon():Item {
        var list = [{ name:"crappy bow",    accuracy:"-1d2+0", evasion:"0d0+0", damage:"-1d2+0", resistance:"0d0+0"},
                    { name:"short bow",     accuracy:"2d2+0", evasion:"0d0+0", damage:"1d1+0", resistance:"0d0+0"},
                    { name:"medium bow",    accuracy:"1d2+0", evasion:"0d0+0", damage:"1d2+0", resistance:"0d0+0"},
                    { name:"long bow",      accuracy:"1d1+0", evasion:"0d0+0", damage:"2d2+0", resistance:"0d0+0"},
                    { name:"silver bow",    accuracy:"1d1+5", evasion:"0d0+0", damage:"1d1+5", resistance:"0d0+0"},
                    { name:"heroic bow",    accuracy:"1d1+1", evasion:"0d0+1", damage:"1d1+1", resistance:"0d0+1"}];

        var def = list[Math.floor(Math.random() * list.length)];
        var i = new Item(")", Color.hsv(30, 80, 80), "ranged", def.name);
        i.accuracyStat = def.accuracy;
        i.evasionStat = def.evasion;
        i.damageStat = def.damage;
        i.resistanceStat = def.resistance;
        return i;
    }

    public static function meleeWeapon():Item {
        var list = [{ name:"crappy sword",    accuracy:"-1d2+0", evasion:"0d0+0", damage:"-1d2+0", resistance:"0d0+0"},
                    { name:"short sword",     accuracy:"2d2+0", evasion:"0d0+0", damage:"1d1+0", resistance:"0d0+0"},
                    { name:"medium sword",    accuracy:"1d2+0", evasion:"0d0+0", damage:"1d2+0", resistance:"0d0+0"},
                    { name:"long sword",      accuracy:"1d1+0", evasion:"0d0+0", damage:"2d2+0", resistance:"0d0+0"},
                    { name:"silver sword",    accuracy:"1d1+5", evasion:"0d0+0", damage:"1d1+5", resistance:"0d0+0"},
                    { name:"heroic sword",    accuracy:"1d1+1", evasion:"0d0+1", damage:"1d1+1", resistance:"0d0+1"}];
        
        var def = list[Math.floor(Math.random() * list.length)];
        var i = new Item("|", Color.hsv(180, 20, 80), "melee", def.name);
        i.accuracyStat = def.accuracy;
        i.evasionStat = def.evasion;
        i.damageStat = def.damage;
        i.resistanceStat = def.resistance;
        return i;
    }

    public static function armor():Item {
        var list = [{ name:"crappy armor",    accuracy:"0d0+0", evasion:"-1d2+0", damage:"0d0+0", resistance:"-1d1+0"},
                    { name:"light armor",     accuracy:"0d0+0", evasion:"-1d1+0", damage:"0d0+0", resistance:"1d2+0"},
                    { name:"medium armor",    accuracy:"0d0+0", evasion:"-1d2+0", damage:"0d0+0", resistance:"2d2+0"},
                    { name:"heavy armor",     accuracy:"0d0+0", evasion:"-2d2+0", damage:"0d0+0", resistance:"2d3+0"},
                    { name:"silver armor",    accuracy:"0d0+0", evasion:"-1d1+5", damage:"0d0+0", resistance:"1d1+5"},
                    { name:"heroic armor",    accuracy:"0d0+1", evasion:"-1d1+1", damage:"0d0+1", resistance:"0d0+1"}];

        var def = list[Math.floor(Math.random() * list.length)];
        var i = new Item("[", Color.hsv(90, 40, 80), "armor", def.name);
        i.accuracyStat = def.accuracy;
        i.evasionStat = def.evasion;
        i.damageStat = def.damage;
        i.resistanceStat = def.resistance;
        return i;
    }

    public static function item():Item {
        switch (Math.floor(Math.random() * 3)) {
            case 0: return rangedWeapon();
            case 1: return meleeWeapon();
            default: return armor();
        }
    }
}
