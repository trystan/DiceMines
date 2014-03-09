package;

class Dice {

    public static function rollExact(number:Int, sides:Int, bonus:Int):Int {
        var total = bonus;
        for (i in 0 ... number)
            total += Math.floor(Math.random() * sides) + 1;
        return total;
    }

    public static function roll(what:String):Int {
        var number = Std.parseInt(what.split("d")[0]);
        var sides = Std.parseInt(what.split("d")[1].split("+")[0]);
        var bonus = Std.parseInt(what.split("+")[1]);
        return rollExact(number, sides, bonus);
    }
}
