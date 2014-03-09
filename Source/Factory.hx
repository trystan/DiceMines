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

    public static function item():Item {
        return new Item(")", Color.hsv(30, 80, 80), "ranged", "short bow");
    }
}
