package knave;

class Bresenham {
    public var points:Array<IntPoint>;

    public function new(x0:Int, y0:Int, x1:Int, y1:Int) {
        points = new Array<IntPoint>();
        calculate(x0, y0, x1, y1);
    }

    private function calculate(x0:Int, y0:Int, x1:Int, y1:Int):Void {
        var dx = Math.floor(Math.abs(x1 - x0));
        var dy = Math.floor(Math.abs(y1 - y0));
        var sx = x0 < x1 ? 1 : -1;
        var sy = y0 < y1 ? 1 : -1;
        var err = dx - dy;

        while (true) {
            points.push(new IntPoint(x0, y0));

            if (x0 == x1 && y0 == y1)
                break;

            var e2 = err * 2;
            if (e2 > -dx) {
                err -= dy;
                x0 += sx;
            }
            if (e2 < dx){
                err += dx;
                y0 += sy;
            }
        }
    }

    public static function line(x0:Int, y0:Int, x1:Int, y1:Int):Bresenham {
        return new Bresenham(x0, y0, x1, y1);
    }
}
