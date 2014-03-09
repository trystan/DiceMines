package;

import knave.Color;

class Factory {

    public static function spider():Creature {
        var c = new Creature("s", "spider", 0, 0, 0);
        c.accuracyStat = "5d5+5";
        return c;
    }

    public static function bear():Creature {
        var c = new Creature("b", "bear", 0, 0, 0);
        c.damageStat = "5d5+5";
        return c;
    }

    public static function ghost():Creature {
        var c = new Creature("g", "ghost", 0, 0, 0);
        c.evasionStat = "5d5+5";
        return c;
    }

    public static function elemental():Creature {
        var c = new Creature("e", "earth elemental", 0, 0, 0);
        c.resistanceStat = "5d5+5";
        return c;
    }

    public static function enemy():Creature {
        switch (Math.floor(Math.random() * 4)) {
            case 0: return spider();
            case 1: return bear();
            case 2: return ghost();
            default: return elemental();
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
        var list = [{ name:"crappy armor",    accuracy:"0d0+0", evasion:"-1d2+0", damage:"0d0+0", resistance:"-1d2+0"},
                    { name:"light armor",     accuracy:"0d0+0", evasion:"-1d1+0", damage:"0d0+0", resistance:"1d1+0"},
                    { name:"medium armor",    accuracy:"0d0+0", evasion:"-1d2+0", damage:"0d0+0", resistance:"1d2+0"},
                    { name:"heavy armor",     accuracy:"0d0+0", evasion:"-2d2+0", damage:"0d0+0", resistance:"2d2+0"},
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
