package;

import knave.IntPoint;
import knave.AStar;
import knave.AStar3;

class NpcAi {
    public var world:World;
    public var self:Creature;
    public var enemy:Creature;
    public var path:Array<IntPoint>;

    public function new(self:Creature) {
        this.self = self;
        self.ai = this;
    }

    public function update():Void {
        world = self.world;

        if (self.z != world.player.z)
            return;

        if (self.sleepCounter > 0)
            return;

        enemy = nearestVisibleEnemy();

        if (enemy != null && self.fearCounter > 0) {
            self.runFrom(enemy);
            return;
        }

        if (enemy != null && Math.random() > 0.5) {
            if (useAbility())
                return;

            if (self.rangedWeapon != null) {
                if (Math.random() < 0.5)
                    self.rangedAttack(enemy.x, enemy.y);
                else
                    self.wander();
            } else {
                goTo(enemy.x, enemy.y, enemy.z);
            }
        } else if (path != null && path.length > 0) {
            followPath();
        } else {
            doDefault();
        }
    }

    private function doDefault():Void {
        self.wander();
    }

    public function isEnemy(other:Creature):Bool {
        if (other == null)
            return false;

        if (self.isHero() && other.glyph != "@")
            return true;
        if (self.glyph != "@" && other.isHero())
            return true;

        return false;
    }

    private function nearestVisibleEnemy():Creature {
        if (enemy != null && enemy.isAlive && self.canSee(enemy) && Math.random() < 0.75)
            return enemy;

        if (enemy != null && !enemy.isAlive)
            enemy = null;

        var closest:Creature = null;
        var closestDist = 10000.0;
        var fromPoint = new IntPoint(self.x, self.y, self.z);

        var potentials = self.isHero() ? world.creatures: world.heroParty;

        for (c in potentials) {
            if (self == c || !isEnemy(c) || !self.canSee(c))
                continue;

            if (c.sleepCounter > 0)
                continue;

            var dist = fromPoint.distanceTo(new IntPoint(c.x, c.y, c.z));
            if (dist > closestDist)
                continue;
            closestDist = dist;
            closest = c;
        }
        return closest;
    }

    private function followPath():Void {
        while (path != null && path.length > 0 && path[0].x == self.x && path[0].y == self.y && path[0].z == self.z)
            path.shift();
        
        if (path == null || path.length == 0) {
            self.wander();
            return;
        }
        var next = path.shift();
        var mx = next.x - self.x;
        var my = next.y - self.y;
        var mz = next.z - self.z;
        if (Math.abs(mx) > 1 || Math.abs(my) > 1) {
            path = null;
            self.wander();
        } else if (world.blocksMovement(self.x+mx, self.y+my, self.z+mz)) {
            path = null;
        } else {
            var other = world.getCreature(self.x+mx, self.y+my, self.z+mz);
            if (other == null || isEnemy(other)) {
                self.move(mx, my, mz);
            } else {
                path = null;
                self.wander();
            }
        }
    }

    public function goTo(tx:Int, ty:Int, tz:Int):Void {
        var oldPath = path;
        if (path == null || path.length == 0 || path[path.length-1].x != tx || path[path.length-1].y != ty || path[path.length-1].z != tz) {
            if (self.z == tz) {
                path = AStar.pathTo(new IntPoint(self.x, self.y, self.z), new IntPoint(tx, ty, self.z), function(p:IntPoint):Bool {
                    return world.isWalkable(p.x, p.y, p.z, self.isFlying);
                }, 40);

            } else if (self.z != tz) {
                path = AStar3.pathTo(new IntPoint(self.x, self.y, self.z), new IntPoint(tx, ty, tz), function(p:IntPoint):Array<IntPoint> {
                    while (!self.isFlying && world.isEmptySpace(p.x, p.y, p.z))
                        p = p.plus(new IntPoint(0, 0, 1));
                    var ok = new Array<IntPoint>();
                    for (p2 in p.neighbors8()) {
                        if (world.isWalkable(p2.x, p2.y, p.z, self.isFlying) || world.isEmptySpace(p2.x, p2.y, p2.z))
                            ok.push(p2);
                    }
                    if (world.canGoUp(p.x, p.y, p.z))
                        ok.push(p.plus(new IntPoint(0, 0, -1)));
                    if (world.canGoDown(p.x, p.y, p.z))
                        ok.push(p.plus(new IntPoint(0, 0, 1)));
                    return ok;
                }, 40);
            }
        }

        followPath();
    }

    public function useAbility():Bool {
        for (ability in self.abilities) {
            var data = ability.aiUsage(self);
            if (data == null || data.percent < Math.random())
                continue;
            data.func(self);
            return true;
        }
        return false;
    }
}
