package;

import knave.IntPoint;
import knave.AStar;

class NpcAi {
    public var world:PlayScreen;
    public var target:Creature;
    public var path:Array<IntPoint>;

    public var homeX:Int;
    public var homeY:Int;
    public var homeZ:Int;

    public function new(target:Creature) {
        this.target = target;
        target.ai = this;

        this.homeX = target.x;
        this.homeY = target.y;
        this.homeZ = target.z;
    }

    public function update():Void {
        world = target.world;

        if (target.sleepCounter > 0)
            return;

        if (target.canSee(world.player)) {
            if (target.fearCounter > 0) {
                target.runFrom(world.player);
                return;
            }

            for (ability in target.abilities) {
                var data = ability.aiUsage(target);
                if (data == null || data.percent < Math.random())
                    continue;
                data.func(target);
                return;
            }

            if (target.rangedWeapon != null) {
                if (Math.random() < 0.5)
                    target.rangedAttack(world.player.x, world.player.y);
                else
                    target.wander();
            } else {
                path = AStar.pathTo(target.x, target.y, world.player.x, world.player.y, function(tx:Int, ty:Int):Bool {
                    return !world.isEmptySpace(tx, ty, target.z) && !world.blocksMovement(tx, ty, target.z);
                }, 20);
                followPath();
            }
        } else if (path != null && path.length > 0) {
            followPath();
        } else if (homeZ == target.z && (homeX-target.x)*(homeX-target.x)+(homeY-target.y)*(homeY-target.y) > 7*7) {
            path = AStar.pathTo(target.x, target.y, homeX, homeY, function(tx:Int, ty:Int):Bool {
                return !world.isEmptySpace(tx, ty, target.z) && !world.blocksMovement(tx, ty, target.z);
            }, 20);
            followPath();
        } else {
            target.wander();
        }
    }

    private function followPath():Void {
        if (path == null || path.length == 0)
            return;
        if (Math.random() < 0.1) {
            target.wander();
            path = null;
            return;
        }
        var next = path.shift();
        var mx = next.x - target.x;
        var my = next.y - target.y;
        if (Math.abs(mx) > 1 || Math.abs(my) > 1) {
            path = null;
            target.wander();
        } else
            target.move(mx, my, 0);
    }

}
