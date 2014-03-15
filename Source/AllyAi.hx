package;

import knave.IntPoint;
import knave.AStar3;
import knave.Bresenham;

class AllyAi extends NpcAi {
    private var strategy:Int;
    private var favoredDistance:Int;
    private var forwardMultiplier:Int;

    public function new(self:Creature) {
        super(self);

        favoredDistance = Dice.roll("1d9+1");
        forwardMultiplier = Math.random() < 0.75 ? 1 : -1;
    }

    override public function update():Void {
        world = self.world;

        if (self.sleepCounter > 0)
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
            stayNearPlayer();
        }
    }

    private function stayNearPlayer():Void {
        // trace('${self.name} ${self.x},${self.y},${self.z} $path');
        var targetPoint = new IntPoint(world.player.x, world.player.y, world.player.z);
        var d = 0;
        while (d++ < favoredDistance && world.isWalkable(targetPoint.x + world.player.vx, targetPoint.y + world.player.vy, targetPoint.z)) {
            targetPoint.x += world.player.vx * forwardMultiplier;
            targetPoint.y += world.player.vy * forwardMultiplier;
        }
        goTo(targetPoint.x, targetPoint.y, targetPoint.z);
    }
}
