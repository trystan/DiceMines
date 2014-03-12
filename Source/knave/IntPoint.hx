package knave;

class IntPoint {
    public var x:Int;
    public var y:Int;

    public function new (x:Int, y:Int) {
        this.x = x;
        this.y = y;
    }

    public function plus(other:IntPoint):IntPoint {
        return new IntPoint(x+other.x, y+other.y);
    }

    public function minus(other:IntPoint):IntPoint {
        return new IntPoint(x-other.x, y-other.y);
    }

    public function offsets8():Array<IntPoint> {
        return [new IntPoint(-1,-1), new IntPoint(-1,0), new IntPoint(-1,1), new IntPoint(0,-1), new IntPoint(0,1), new IntPoint(1,-1), new IntPoint(1,0), new IntPoint(1,1)];
    }

    public function neighbors8():Array<IntPoint> {
        var all = new Array<IntPoint>();
        for (offset in offsets8())
            all.push(this.plus(offset));
        return all;
    }

    public function distanceTo(other:IntPoint):Float {
        return Math.sqrt(distanceSquaredTo(other));
    }

    public function distanceSquaredTo(other:IntPoint):Float {
        return (x-other.x)*(x-other.x) + (y-other.y)*(y-other.y);
    }

    public function toString():String { 
        return '$x,$y';
    }
}
