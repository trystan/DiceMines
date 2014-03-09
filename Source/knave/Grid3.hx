package knave;

class Grid3<T> {
    public var data:Array<Array<Array<T>>>;
    public var width:Int;
    public var height:Int;
    public var depth:Int;

    public function new(w:Int, h:Int, d:Int) {
        width = w;
        height = h;
        depth =d;
        data = new Array<Array<Array<T>>>();
        for (x in 0 ... w) {
            var row = new Array<Array<T>>();
            for (y in 0 ... h) {
                var col = new Array<T>();
                for (z in 0 ... d)
                    col.push(null);
                row.push(col);
            }
            data.push(row);
        }
    }

    public function isInBounds(x:Int, y:Int, z:Int):Bool {
        return x >= 0 && y >= 0 && z >= 0 && x < width && y < height && z < depth;
    }

    public function get(x:Int, y:Int, z:Int):T {
        return isInBounds(x, y, z) ? data[x][y][z] : null;
    }

    public function set(x:Int, y:Int, z:Int, value:T):Void {
        if (isInBounds(x, y, z))
            data[x][y][z] = value;
    }
}

