package;

class Dice {
    public var number:Int;
    public var sides:Int;
    public var bonus:Int;

    public function new(number:Int, sides:Int, bonus:Int) {
        if (sides < 0) {
            sides = Math.floor(Math.abs(sides));
            number = -Math.floor(Math.abs(number));
        }

        this.number = number;
        this.sides = sides;
        this.bonus = bonus;
    }

    public function plus(other:Dice):Dice {
        return new Dice(number + other.number, sides + other.sides, bonus + other.bonus);
    }

    public function minus(other:Dice):Dice {
        return new Dice(number - other.number, sides - other.sides, bonus - other.bonus);
    }

    public function toString():String {
        return number + "d" + sides + (bonus < 0 ? "-" : "+") + bonus;
    }

    public function rollAll():Int {
        var total = 0;
        for (i in 0 ... Math.floor(Math.abs(number)))
            total += Math.floor(Math.random() * sides) + (sides < 0 ? -1 : 1);
        return total * (number < 0 ? -1 : 1) + bonus;
    }

    public static function fromString(dice:String):Dice {
        var halfs = dice.split("d");
        var number = Std.parseInt(halfs[0]);
        var sides = 0;
        var bonus = 0;
        if (halfs[1].indexOf("-") == -1) {
            sides = Std.parseInt(halfs[1].split("+")[0]);
            bonus = Std.parseInt(halfs[1].split("+")[1]);
        } else {
            sides = Std.parseInt(halfs[1].split("-")[0]);
            bonus = Std.parseInt(halfs[1].split("-")[1]);
        }
        return new Dice(number, sides, bonus);
    }

    public static function rollExact(number:Int, sides:Int, bonus:Int):Int {
        return new Dice(number, sides, bonus).rollAll();
    }

    public static function add(a:String, b:String):String {
        return fromString(a).plus(fromString(b)).toString();
    }

    public static function subtract(a:String, b:String):String {
        return fromString(a).minus(fromString(b)).toString();
    }

    public static function roll(what:String):Int {
        return fromString(what).rollAll();
    }
}
