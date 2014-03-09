package knave;

class Shadowcaster {
    private var mult:Array<Array<Int>>;
    private var radius:Int;
    private var cx:Int;
    private var cy:Int;

    private var squares:Grid<Bool>;

    public function new() {
        mult = [
            [1,  0,  0, -1, -1,  0,  0,  1],
            [0,  1, -1,  0,  0, -1,  1,  0],
            [0,  1,  1,  0,  0, -1, -1,  0],
            [1,  0,  0,  1, -1,  0,  0, -1]];
    }

    public function isLit(x:Int, y:Int):Bool {
        return squares.isInBounds(x-cx+radius, y-cy+radius)
            && (x-cx)*(x-cx)+(y-cy)*(y-cy) < radius*radius
            && squares.get(x-cx+radius, y-cy+radius);
    }

    private function setLit(x:Int, y:Int):Void {
        squares.set(x-cx+radius, y-cy+radius, true);
    }

    public function update(x:Int, y:Int, radius:Int, checkBlocked:Int -> Int -> Bool):Void {
        cx = x;
        cy = y;
        this.radius = radius;
        squares = new Grid(radius*2+1, radius*2+1);
        setLit(cx, cy);
        for (oct in 0 ... 8)
            cast_light(1, 1.0, 0.0, radius, mult[0][oct], mult[1][oct], mult[2][oct], mult[3][oct], checkBlocked);
    }

    private function cast_light(row:Int, start:Float, end:Float, radius:Int, xx:Int, xy:Int, yx:Int, yy:Int, checkBlocked):Void {
        if (start < end)
            return;

        var radius_squared = radius * radius;
        for (j in row ... radius+1) {
            var dx = -j-1; 
            var dy = -j;
            var blocked = false;
            var new_start = -99.0;
            while (dx <= 0) {
                dx += 1;
                var mapX = cx + dx * xx + dy * xy;
                var mapY = cy + dx * yx + dy * yy;
                var l_slope = (dx - 0.5) / (dy + 0.5);
                var r_slope = (dx + 0.5) / (dy - 0.5);

                if (start < r_slope)
                    continue;
                
                if (end > l_slope)
                    break;

                if (dx*dx + dy*dy < radius_squared)
                    setLit(mapX, mapY);

                if (blocked) {
                    if (checkBlocked(mapX, mapY)) {
                        new_start = r_slope;
                        continue;
                    } else {
                        blocked = false;
                        start = new_start;
                    }
                } else if (checkBlocked(mapX, mapY) && j < radius) {
                    blocked = true;
                    cast_light(j+1, start, l_slope, radius, xx, xy, yx, yy, checkBlocked);
                    new_start = r_slope;
                }
            }
            if (blocked)
                break;
        }
    }
}
