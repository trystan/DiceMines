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
    public var pietyStat:String;

    public var onHitAbility:Ability;

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
        pietyStat = "0d0+0";
    }

    public function describe():String {
        var parts = new Array<String>();

        if (accuracyStat != "0d0+0") parts.push("accuracy " + accuracyStat);
        if (damageStat != "0d0+0") parts.push("damage " + damageStat);
        if (evasionStat != "0d0+0") parts.push("evasion " + evasionStat);
        if (resistanceStat != "0d0+0") parts.push("resistance " + resistanceStat);
        if (pietyStat != "0d0+0") parts.push("piety " + pietyStat);
        if (onHitAbility != null) parts.push("chance of " + onHitAbility.name);

        if (parts.length == 0)
            return name;
        else
            return '$name (${parts.join(", ")})';
    }

    public function onHit(owner:Creature, other:Creature):Void {
        if (onHitAbility == null)
            return;
        onHitAbility.itemUsage(owner, other);
    }
}
