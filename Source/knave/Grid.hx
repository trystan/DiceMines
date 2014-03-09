package knave;

class Grid<T> {
    public var data:Array<Array<T>>;
    public var width:Int;
    public var height:Int;

    public static function combine<T>(grid1:Grid<T>, grid2:Grid<T>, op:T -> T -> T):Grid<T> {
        var g = new Grid<T>(grid1.width, grid1.height);
        for (x in 0 ... g.width)
        for (y in 0 ... g.height) {
            g.set(x, y, op(grid1.get(x, y), grid2.get(x, y)));
        }
        return g;
    }

    public function new(w:Int, h:Int, defaultValue:T = null) {
        width = w;
        height = h;
        data = new Array<Array<T>>();
        for (x in 0 ... w) {
            var row = new Array<T>();
            for (y in 0 ... h)
                row.push(defaultValue);
            data.push(row);
        }
    }

    public function isInBounds(x:Int, y:Int):Bool {
        return x >= 0 && y >= 0 && x < width && y < height;
    }

    public function get(x:Int, y:Int):T {
        return isInBounds(x, y) ? data[x][y] : null;
    }

    public function set(x:Int, y:Int, value:T):Void {
        if (isInBounds(x, y))
            data[x][y] = value;
    }
}

