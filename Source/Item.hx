package;

import knave.Color;

class Item {
    public var glyph:String;
    public var color:Color;
    public var name:String;

    public var type:String;

    public function new(glyph:String, color:Color, type:String, name:String) {
        this.glyph = glyph;
        this.color = color;
        this.type = type;
        this.name = name;
    }
}
