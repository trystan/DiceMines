package knave;

class Raycaster {
    private var radius:Int;
    private var cx:Int;
    private var cy:Int;

    private var squares:Grid<Int>;

    private var unknown = 0;
    private var visible = 1;
    private var notvisible = 2;

    public function new() {
    }

    public function isLit(x:Int, y:Int):Bool {
        return (x-cx)*(x-cx)+(y-cy)*(y-cy) < radius*radius && squares.get(x-cx+radius, y-cy+radius) == visible;
    }

    private function setLit(x:Int, y:Int):Void {
        squares.set(x-cx+radius, y-cy+radius, visible);
    }

    private function setUnlit(x:Int, y:Int):Void {
        squares.set(x-cx+radius, y-cy+radius, notvisible);
    }

    public function update(x:Int, y:Int, radius:Int, checkBlocked:Int -> Int -> Bool):Void {
        cx = x;
        cy = y;
        this.radius = radius;
        squares = new Grid(radius*2+1, radius*2+1);

        var radiusSquared = radius * radius;
        for(tx in -radius ... radius+1)
        for(ty in -radius ... radius+1) {
            if (tx*tx+ ty*ty > radiusSquared)
                continue;

            var blocked = false;
            for (p in Bresenham.line(cx, cy, cx+tx, cy+ty).points) {
                if (p.x==cx+tx && p.y==cy+ty)
                    break;
                if (checkBlocked(p.x,p.y)) {
                    blocked = true;
                    break;
                }
            }
            if (blocked)
                setUnlit(cx+tx, cy+ty);
            else
                setLit(cx+tx, cy+ty);
        }
    }
}
