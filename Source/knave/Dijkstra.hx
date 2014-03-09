package knave;

class Dijkstra  {
    private var visited:Map<String, IntPoint>;

    public function new() {
        visited = new Map<String, IntPoint>();
    }

    private function makePath(endNode:IntPoint):Array<IntPoint> {
        var path:Array<IntPoint> = [];
        while (visited.get(endNode.toString()) != endNode) {
            path.push(endNode);
            endNode = visited.get(endNode.toString());
        }
        path.push(endNode);
        path.reverse();
        path.shift();
        return path;
    }

    public function pathTo(canEnter:Int -> Int -> Bool, start:IntPoint, check:Int -> Int -> Bool):Array<IntPoint> {
        var open:Array<IntPoint> = [start];
        visited.set(start.toString(), open[0]);

        while (open.length > 0) {
            var current = open[0];
            open.splice(0, 1);

            if (check(current.x, current.y))
                return makePath(current);

            for (offset in [[-1,0],[0,-1],[0,1],[1,0],[-1,-1],[-1,1],[1,-1],[1,1]]) {
                var neighbor = new IntPoint(current.x + offset[0], current.y + offset[1]);

                if (visited.get(neighbor.toString()) != null)
                    continue;

                visited.set(neighbor.toString(), current);

                if (check(neighbor.x, neighbor.y))
                    return makePath(neighbor);

                if (!canEnter(neighbor.x, neighbor.y))
                    continue;

                open.push(neighbor);
            }
        }
        return [];
    }

    public static function findPath(canEnter:Int -> Int -> Bool, sx:Int, sy:Int, check:Int -> Int -> Bool):Array<IntPoint> {
        return new Dijkstra().pathTo(canEnter, new IntPoint(sx, sy), check);
    }

    public static function findNearest(canEnter:Int -> Int -> Bool, sx:Int, sy:Int, check:Int -> Int -> Bool):IntPoint {
        var path = new Dijkstra().pathTo(canEnter, new IntPoint(sx, sy), check);
        if (path.length > 0)
            return path[path.length - 1];
        else
            return null;
    }
}
