package knave;

class AStar3 {
    private var open:Array<AStar3Node> = null;
    private var closed:Array<AStar3Node> = null;

    private var neighbors:IntPoint -> Array<IntPoint>;
    private var start:IntPoint;

    public function new(neighbors:IntPoint -> Array<IntPoint>, start:IntPoint) {
        this.neighbors = neighbors;
        this.start = start;
    }

    public function findPathTo(end:IntPoint, giveUpAfter:Int):Array<IntPoint> { 
        if(start.x == end.x && start.y == end.y && start.z == end.z)
            return [];

        var startNode = new AStar3Node(start.x, start.y, start.z, null);
        startNode.g = 0;
        startNode.h = getHCost(start, end);
        startNode.f = startNode.g + startNode.h;

        open = [startNode];
        closed = [];

        while(open.length > 0 && giveUpAfter-- > 0) {
            var current = open[0];

            closed.push(current);
            open.splice(0,1);

            if(current.x == end.x && current.y == end.y && current.z == end.z)
                break;

            for (neighbor in neighbors(current)) {
                var newG:Int = getGCost(current, neighbor);

                if (getFromList(closed, neighbor) != null)
                    continue;

                if (neighbor.x == end.x && neighbor.y == end.y && neighbor.z == end.z) {
                    var endNode = new AStar3Node(neighbor.x, neighbor.y, neighbor.z, current);
                    endNode.g = newG;
                    endNode.h = getHCost(neighbor, end);
                    endNode.f = endNode.g + endNode.h;
                    open.unshift(endNode);
                    break;
                }

                var visited = getFromList(open, neighbor);

                if(visited == null) {
                    var newNode = new AStar3Node(neighbor.x, neighbor.y, neighbor.z, current);
                    newNode.g = newG;
                    newNode.h = getHCost(neighbor, end);
                    newNode.f = newNode.g + newNode.h;
                    open.push(newNode);
                }
                else if(newG < visited.g) {
                    visited.parentNode = current;
                    visited.g = newG;
                    visited.f = visited.g + visited.h;
                }
            }

            open.sort(sortOnFCost);
        }

        if (giveUpAfter == 0)
            return null;

        return walkBackToStart(end);
    }

    private function walkBackToStart(end:IntPoint):Array<IntPoint> {
        var thisStep = getFromList(closed, end);
        if (thisStep == null)
            return [];

        var steps:Array<IntPoint> = [];
        while(thisStep.x != start.x || thisStep.y != start.y || thisStep.z != start.z) {
            steps.push(thisStep);
            thisStep = thisStep.parentNode;
        }

        steps.reverse();
        return steps;
    }

    private function getGCost(from:IntPoint, to:IntPoint):Int {
        return Math.floor(Math.max(Math.max(Math.abs(from.x - to.x), Math.abs(from.y - to.y)), Math.abs(from.z - to.z)));
    }

    private function getHCost(from:IntPoint, to:IntPoint):Int {
        return Math.floor(Math.abs(from.x - to.x) + Math.abs(from.y - to.y) + Math.abs(from.z - to.z));
    }

    private function getFromList(list:Array<AStar3Node>, loc:IntPoint):AStar3Node {
        for (other in list){
            if (other.x == loc.x && other.y == loc.y && other.z == loc.z)
                return other;
        }
        return null;
    }

    private function sortOnFCost(n1:AStar3Node, n2:AStar3Node):Int {
        if (n1.f < n2.f)
            return -1;
        else if (n1.f > n2.f)
            return 1;
        else
            return 0;
    }

    public static function pathTo(start:IntPoint, end:IntPoint, neighbors:IntPoint -> Array<IntPoint>, giveUpAfter:Int = 10000):Array<IntPoint> {
        return new AStar3(neighbors, start).findPathTo(end, giveUpAfter);
    }
}

class AStar3Node extends IntPoint {
    public var g:Int = 0;
    public var h:Int = 0;
    public var f:Int = 0;
    public var parentNode:AStar3Node = null;

    public function new(x:Int, y:Int, z:Int, parent:AStar3Node) {
        super(x, y, z);
        this.parentNode = parent;
    }
}
