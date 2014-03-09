package;

import knave.Color;

class Item {
    public var glyph:String;
    public var color:Color;
    public var name:String;

    public var accuracyStat:String;
    public var damageStat:String;
    public var evasionStat:String;
    public var resistanceStat:String;

    public var type:String;

    public function new(glyph:String, color:Color, type:String, name:String) {
        this.glyph = glyph;
        this.color = color;
        this.type = type;
        this.name = name;

        accuracyStat = "0d0+0";
        damageStat = "0d0+0";
        evasionStat = "0d0+0";
        resistanceStat = "0d0+0";
    }
}
