package;

class Ability {
    public var name:String;
    public var description:String;

    public function new(name:String, description:String) {
        this.name = name;
        this.description = description;
    }

    public function playerUsage(self:Creature):Void {
    }

    public function aiUsage(self:Creature): { percent:Float, func:Creature -> Void } { 
        return { percent: -10.0, func: function(self:Creature):Void { } };
    }

    public function itemUsage(item:Item, owner:Creature, other:Creature):Void {
    }
}
