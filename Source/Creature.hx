package;

import knave.Shadowcaster;

class Creature {
    public var world:PlayScreen;
    public var x:Int;
    public var y:Int;
    public var z:Int;
    public var glyph:String;

    public var light:Shadowcaster;

    public function new(glyph:String, x:Int, y:Int, z:Int) {
        this.glyph = glyph;
        this.x = x;
        this.y = y;
        this.z = z;
    }

    public function move(mx:Int, my:Int, mz:Int):Void {
        update();
    }

    public function update():Void {
        if (light == null)
            return;

        light.update(x, y, 25, function (vx:Int, vy:Int):Bool {
            return world.blocksVision(vx, vy, z);
        });
    }
}
