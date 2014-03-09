package;

class Dice {

    public static function rollExact(number:Int, sides:Int, bonus:Int):Int {
        var total = bonus;
        for (i in 0 ... Math.floor(Math.abs(number)))
            total += Math.floor(Math.random() * sides) + (sides < 0 ? -1 : 1);
        return total;
    }

    public static function add(a:String, b:String):String {
        var numberA = Std.parseInt(a.split("d")[0]);
        var sidesA = Std.parseInt(a.split("d")[1].split("+")[0]) * (numberA < 0 ? -1 : 1);
        var bonusA = Std.parseInt(a.split("+")[1]);

        var numberB = Std.parseInt(b.split("d")[0]);
        var sidesB = Std.parseInt(b.split("d")[1].split("+")[0]) * (numberB < 0 ? -1 : 1);
        var bonusB = Std.parseInt(b.split("+")[1]);

        var numberC = numberA + numberB;
        var sidesC = sidesA + sidesB;
        var bonusC = bonusA + bonusB;

        return numberC + "d" + sidesC + "+" + bonusC;
    }

    public static function roll(what:String):Int {
        var number = Std.parseInt(what.split("d")[0]);
        var sides = Std.parseInt(what.split("d")[1].split("+")[0]) * (number < 0 ? -1 : 1);
        var bonus = Std.parseInt(what.split("+")[1]);
        return rollExact(number, sides, bonus);
    }
}
