package;

import knave.IntPoint;
import knave.Bresenham;

class Projectile {
    public var x:Int;
    public var y:Int;
    public var z:Int;
    public var tx:Int;
    public var ty:Int;
    public var isDone:Bool = false;

    public var accuracyStat:String;
    public var damageStat:String;
    public var owner:Creature;

    public var path:Array<IntPoint>;

    public function new(x:Int, y:Int, z:Int, tx:Int, ty:Int, owner:Creature) {
        this.x = x;
        this.y = y;
        this.z = z;
        this.tx = tx;
        this.ty = ty;
        this.owner = owner;
        accuracyStat = owner.accuracyStat;
        damageStat = owner.damageStat;
        path = Bresenham.line(x, y, tx, ty).points;
        update();
    }

    public function update():Void {
        if (path.length > 0) {
            var next = path.shift();
            x = next.x;
            y = next.y;
        } else {
            isDone = true;
        }
    }
}
