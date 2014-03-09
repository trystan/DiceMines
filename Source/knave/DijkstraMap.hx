package knave;

class DijkstraMap {
    private var value:Grid<Float>;

    public static function combine<T>(map1:DijkstraMap, map2:DijkstraMap, op:Float -> Float -> Float):DijkstraMap {
        var m = new DijkstraMap(map1.value.width, map1.value.height);
        m.value = Grid.combine(map1.value, map2.value, op);
        return m;
    }

    public function new(w:Int, h:Int):Void {
        value = new Grid<Float>(w, h, 9999);
    }

    public function get(x:Int, y:Int):Float {
        return value.get(x, y);
    }

    public function makeMap(canEnter:Int -> Int -> Bool, start:IntPoint):Void {
        value = new Grid<Float>(value.width, value.height, 9999);
        var open:Array<DistancePoint> = [new DistancePoint(start.x, start.y, 1)];
        value.set(start.x, start.y, 1);

        var tries = 0;
        while (open.length > 0 && tries++ < 10000) {
            var current = open[0];
            open.splice(0, 1);

            for (offset in [[-1,0],[0,-1],[0,1],[1,0]]) {
                var neighbor = new DistancePoint(current.x + offset[0], current.y + offset[1], current.distance + 1);

                if (!canEnter(neighbor.x, neighbor.y))
                    continue;

                if (value.get(neighbor.x, neighbor.y) <= neighbor.distance)
                    continue;

               value.set(neighbor.x, neighbor.y, neighbor.distance);
                open.push(neighbor);
            }
        }
    }
}

class DistancePoint extends IntPoint {
    public var distance:Float;

    public function new(x:Int, y:Int, dist:Float) {
        super(x, y);
        distance = dist;
    }
}
