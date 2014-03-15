package;

import knave.IntPoint;
import knave.AStar3;
import knave.Bresenham;

class AllyAi extends NpcAi {
    private var strategy:Int;
    private var favoredDistance:Int;

    private static var STAY_BACK:Int = 0;
    private static var STAY_FORWARD:Int = 1;
    private static var STAY_WHEREVER:Int = 2;
    private static var STAY_LEFT:Int = 3;
    private static var STAY_RIGHT:Int = 4;

    public function new(self:Creature) {
        super(self);

        favoredDistance = 4;
        strategy = Math.floor(Math.random() * 5);
    }

    override public function update():Void {
        world = self.world;

        if (self.sleepCounter > 0)
            return;

        trace('${self.name} ${self.x},${self.y},${self.z} $path');
        goTo(world.player.x, world.player.y, world.player.z);
        return;

        if (self.z != world.player.z) {
            //if (path == null || path.length == 0 || Math.random() < 0.1)
                goTo(world.player.x, world.player.y, world.player.z);
            //else
            //    followPath();

        } else if (stayInGroup()) {
            return;
        }

        self.wander();
        return;

        enemy = nearestVisibleEnemy();

        if (enemy == null) {
            for (c in world.heroParty) {
                if (c.isAlive && c.z == self.z && c.ai.enemy != null) {
                    enemy = c.ai.enemy;
                    self.say("I'll help you with that " + enemy.name + ", " + c.name + "!");
                    break;
                }
            }
        }

        if (enemy != null && self.fearCounter > 0) {
            self.runFrom(enemy);
            self.say("run away!");
            return;
        }

        if (enemy != null) {
            if (useAbility())
                return;

            if (self.rangedWeapon != null) {
                var clearShot = false;
                for (p in Bresenham.line(self.x, self.y, enemy.x, enemy.y).points) {
                    var other = world.getCreature(p.x, p.y, self.z);
                    if (other != null && other != self && !isEnemy(other))
                        clearShot = false;
                }

                if (clearShot)
                    self.rangedAttack(enemy.x, enemy.y);
                else
                    goTo(enemy.x, enemy.y, enemy.z);
            } else {
                goTo(enemy.x, enemy.y, enemy.z);
            }
        } else if (path != null && path.length > 0) {
            followPath();
        } else {
            moveInFormation();
        }
    }

    private function moveInFormation():Void {
        var mx = world.player.vx;
        var my = world.player.vy;

        if (Math.random() < 0.33)
            mx = Math.floor(Math.random() * 0 - 1);
        if (Math.random() < 0.33)
            my = Math.floor(Math.random() * 0 - 1);

        if (world.isWalkable(self.x+mx, self.y+my, self.z)) {
            self.move(mx, my, 0);
            return;
        }

        var tx = world.player.x + world.player.vx * 2;
        var ty = world.player.y + world.player.vy * 2;

        if (Math.random() < 0.5)
            tx += Math.floor(Math.random() * 5 - 2);
        if (Math.random() < 0.5)
            ty += Math.floor(Math.random() * 5 - 2);

        goTo(tx, ty, world.player.z);
    }

    private function stayInGroup():Bool {
        var dist = Math.max(Math.abs(self.x-world.player.x), Math.abs(self.y-world.player.y));
        
        if (dist < favoredDistance - 1) {
            self.runFrom(world.player);
            return true;
         } else if (dist > favoredDistance + 1) {
             goTo(world.player.x, world.player.y, world.player.z);
             return true;
         } else { 
            return false;
         }

        if (dist < favoredDistance + 1 && dist > favoredDistance - 1)
            return false;

        var tx = world.player.x;
        var ty = world.player.y;
        var i = 0;

        switch (strategy) {
            case 0: // STAY_BACK:
                while (i++ < favoredDistance && world.isWalkable(tx+world.player.vx, ty+world.player.vy, world.player.z)) {
                    tx -= world.player.vx;
                    ty -= world.player.vy;
                }
                goTo(tx, ty, world.player.z);
                trace("stay back");
                return true;

            case 1: // STAY_FORWARD:
                while (i++ < favoredDistance && world.isWalkable(tx+world.player.vx, ty+world.player.vy, world.player.z)) {
                    tx += world.player.vx;
                    ty += world.player.vy;
                }
                goTo(tx, ty, world.player.z);
                trace("stay forward");
                return true;

            case 2: // STAY_WHEREVER:
                if (dist > favoredDistance + 2)
                    goTo(tx, ty, world.player.z);
                else if (dist < favoredDistance - 2)
                    self.runFrom(world.player);
                else
                    self.wander();

                trace("stay near");
                return true;

            case 3: // STAY_LEFT:
                while (i++ < favoredDistance && world.isWalkable(tx+world.player.vx, ty+world.player.vy, world.player.z)) {
                    tx += world.player.vy;
                    ty += world.player.vx;
                }
                goTo(tx, ty, world.player.z);
                trace("stay left");
                return true;

            case 4: // STAY_RIGHT:
                while (i++ < favoredDistance && world.isWalkable(tx+world.player.vx, ty+world.player.vy, world.player.z)) {
                    tx += world.player.vy;
                    ty += world.player.vx;
                }
                goTo(tx, ty, world.player.z);
                trace("stay right");
                return true;

            default:
                trace("default?");
        }
        return true;
    }
}
