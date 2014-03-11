package;

class Ability {
    public var name:String;
    public var description:String;
    public var func:PlayScreen -> Creature -> Void;

    public function new(name:String, description:String, func:PlayScreen -> Creature -> Void) {
        this.name = name;
        this.description = description;
        this.func = func;
    }
}
