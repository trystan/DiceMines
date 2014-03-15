package knave;

class AStar {
    private var open:Array<AStarNode> = null;
    private var closed:Array<AStarNode> = null;

    public var offsets:Array<Array<Int>>;

    private var canEnter:IntPoint -> Bool;
    private var start:IntPoint;

    public function new(canEnter:IntPoint -> Bool, start:IntPoint) {
        offsets = [[ -1, 0], [0, -1], [0, 1], [1, 0], [ -1, -1], [ -1, 1], [1, -1], [1, 1]];
        this.canEnter = canEnter;
        this.start = start;
    }

    public function findPathTo(end:IntPoint, giveUpAfter:Int):Array<IntPoint> { 
        if(!canEnter(end) || start.x == end.x && start.y == end.y)
            return [];

        var startNode = new AStarNode(start.x, start.y, start.z, null);
        startNode.g = 0;
        startNode.h = getHCost(start, end);
        startNode.f = startNode.g + startNode.h;

        open = [startNode];
        closed = [];

        while(open.length > 0 && giveUpAfter-- > 0) {
            var current = open[0];

            closed.push(current);
            open.splice(0,1);

            if(current.x == end.x && current.y == end.y)
                break;

            for (offset in offsets) {
                var neighbor = new IntPoint(current.x + offset[0], current.y + offset[1], current.z);

                var newG:Int = getGCost(current, neighbor);

                if (!canEnter(neighbor) || getFromList(closed, neighbor) != null)
                    continue;

                if (neighbor.x == end.x && neighbor.y == end.y) {
                    var endNode = new AStarNode(neighbor.x, neighbor.y, current.z, current);
                    endNode.g = newG;
                    endNode.h = getHCost(neighbor, end);
                    endNode.f = endNode.g + endNode.h;
                    open.unshift(endNode);
                    break;
                }

                var visited = getFromList(open, neighbor);

                if(visited == null) {
                    var newNode = new AStarNode(neighbor.x, neighbor.y, current.z, current);
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
        var thisStep:AStarNode = getFromList(closed, end);
        if (thisStep == null)
            return [];

        var steps:Array<IntPoint> = [];
        while(thisStep.x != start.x || thisStep.y != start.y) {
            steps.push(thisStep);
            thisStep = thisStep.parentNode;
        }

        steps.reverse();
        return steps;
    }

    private function getGCost(from:IntPoint, to:IntPoint):Int {
        return Math.floor(Math.max(Math.abs(from.x - to.x), Math.abs(from.y - to.y)));
    }

    private function getHCost(from:IntPoint, to:IntPoint):Int {
        return Math.floor(Math.abs(from.x - to.x) + Math.abs(from.y - to.y));
    }

    private function getFromList(list:Array<AStarNode>, loc:IntPoint):AStarNode {
        for (other in list){
            if (other.x == loc.x && other.y == loc.y)
                return other;
        }
        return null;
    }

    private function sortOnFCost(n1:AStarNode, n2:AStarNode):Int {
        if (n1.f < n2.f)
            return -1;
        else if (n1.f > n2.f)
            return 1;
        else
            return 0;
    }

    public static function pathTo(start:IntPoint, end:IntPoint, canEnter:IntPoint -> Bool, giveUpAfter:Int = 10000):Array<IntPoint> {
        return new AStar(canEnter, start).findPathTo(end, giveUpAfter);
    }
}

class AStarNode extends IntPoint {
    public var g:Int = 0;
    public var h:Int = 0;
    public var f:Int = 0;
    public var parentNode:AStarNode = null;

    public function new(x:Int, y:Int, z:Int, parent:AStarNode) {
        super(x, y, z);
        this.parentNode = parent;
    }
}
