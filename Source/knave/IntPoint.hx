package knave;

class IntPoint {
    public var x:Int;
    public var y:Int;
    public function new (x:Int, y:Int) {
        this.x = x;
        this.y = y;
    }
    public function toString():String { 
        return '$x,$y';
    }
}
