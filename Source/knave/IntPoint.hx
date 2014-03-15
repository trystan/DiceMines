package knave;

class IntPoint {
    public var x:Int;
    public var y:Int;
    public var z:Int;

    public function new (x:Int, y:Int, z:Int = 0) {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    public function equals(x2:Int, y2:Int, z2:Int = 0):Bool {
        return this.x == x2 && this.y == y2 && this.z == z2;
    }

    public function plus(other:IntPoint):IntPoint {
        return new IntPoint(x+other.x, y+other.y, z+other.z);
    }

    public function minus(other:IntPoint):IntPoint {
        return new IntPoint(x-other.x, y-other.y, z-other.z);
    }

    public function offsets4():Array<IntPoint> {
        return [new IntPoint(-1,0,0), new IntPoint(0,-1,0), new IntPoint(0,1,0), new IntPoint(1,0,0)];
    }

    public function neighbors4():Array<IntPoint> {
        var all = new Array<IntPoint>();
        for (offset in offsets4())
            all.push(this.plus(offset));
        return all;
    }

    public function neighbors5():Array<IntPoint> {
        var all = new Array<IntPoint>();
        all.push(this.plus(new IntPoint(0,0,0)));
        for (offset in offsets4())
            all.push(this.plus(offset));
        return all;
    }

    public function offsets6():Array<IntPoint> {
        return [new IntPoint(-1,0,0), new IntPoint(0,-1,0), new IntPoint(0,1,0), new IntPoint(1,0,0), new IntPoint(0,0,1), new IntPoint(0,0,-1)];
    }

    public function neighbors6():Array<IntPoint> {
        var all = new Array<IntPoint>();
        for (offset in offsets6())
            all.push(this.plus(offset));
        return all;
    }

    public function neighbors7():Array<IntPoint> {
        var all = new Array<IntPoint>();
        all.push(this.plus(new IntPoint(0,0,0)));
        for (offset in offsets6())
            all.push(this.plus(offset));
        return all;
    }

    public function offsets8():Array<IntPoint> {
        return [new IntPoint(-1,-1,0), new IntPoint(-1,0,0), new IntPoint(-1,1,0), new IntPoint(0,-1,0), new IntPoint(0,1,0), new IntPoint(1,-1,0), new IntPoint(1,0,0), new IntPoint(1,1,0)];
    }

    public function neighbors8():Array<IntPoint> {
        var all = new Array<IntPoint>();
        for (offset in offsets8())
            all.push(this.plus(offset));
        return all;
    }

    public function neighbors9():Array<IntPoint> {
        var all = new Array<IntPoint>();
        all.push(this.plus(new IntPoint(0, 0, 0)));
        for (offset in offsets8())
            all.push(this.plus(offset));
        return all;
    }

    public function offsets10():Array<IntPoint> {
        return [new IntPoint(-1,-1,0), new IntPoint(-1,0,0), new IntPoint(-1,1,0), new IntPoint(0,-1,0), new IntPoint(0,1,0), new IntPoint(1,-1,0), new IntPoint(1,0,0), new IntPoint(1,1,0), new IntPoint(0,0,1), new IntPoint(0,0,-1)];
    }

    public function neighbors10():Array<IntPoint> {
        var all = new Array<IntPoint>();
        for (offset in offsets10())
            all.push(this.plus(offset));
        return all;
    }

    public function neighbors11():Array<IntPoint> {
        var all = new Array<IntPoint>();
        all.push(this.plus(new IntPoint(0,0,0)));
        for (offset in offsets10())
            all.push(this.plus(offset));
        return all;
    }

    public function distanceTo(other:IntPoint):Float {
        return Math.sqrt(distanceSquaredTo(other));
    }

    public function distanceSquaredTo(other:IntPoint):Float {
        return (x-other.x)*(x-other.x) + (y-other.y)*(y-other.y) + (z-other.z)*(z-other.z);
    }

    public function toString():String { 
        return '($x,$y,$z)';
    }
}
