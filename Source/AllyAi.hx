package;

import knave.IntPoint;
import knave.AStar3;
import knave.Bresenham;

class AllyAi extends NpcAi {
    private var strategy:Int;
    public var favoredDistance:Int;
    public var forwardMultiplier:Int;
    public var treasure:{ position:IntPoint, item:Item };

    public var currently:String;

    public function new(self:Creature) {
        super(self);

        favoredDistance = Dice.roll("1d9+1");
        forwardMultiplier = Math.random() < 0.75 ? 1 : -1;
        currently = "idle";
    }

    override public function update():Void {
        world = self.world;

        if (enemy != null && !enemy.isAlive)
            enemy = null;

        if (treasure != null && world.getItem(treasure.position.x, treasure.position.y, treasure.position.z) == null)
            treasure = null;

        if (self.sleepCounter > 0)
            return;

        if (Math.random() < self.greed) {
            var here = world.getItem(self.x, self.y, self.z);
            if (here != null && here.type == "dice") {
                self.pickupItem();
                return;
            }

            treasure = nearestVisibleItem(self.meleeWeapon, self.rangedWeapon, self.armor);
            if (treasure != null) {
                getTreasure();
                return;
            }
        }

        if (Math.random() < self.aggresiveness) {
            enemy = nearestVisibleEnemy();
            if (enemy != null) {
                fight();
                return;
            }
            if (enemy == null && Math.random() < self.helpfulness) {
                for (c in world.heroParty) {
                    if (c.isAlive && c.z == self.z && c.ai.enemy != null) {
                        enemy = c.ai.enemy;
                        self.say("I'll help you with that " + enemy.name + ", " + c.name + "!");
                        break;
                    }
                }
            }
        }

        if (enemy != null && self.fearCounter > 0) {
            self.runFrom(enemy);
            self.say("run away!");
            return;
        }

        if (enemy != null) {
            fight();
        } else if (treasure != null) {
            getTreasure();
        } else if (path != null && path.length > 0) {
            followPath();
        } else {
            stayWithThePlayer();
        }
    }

    private function fight():Void {
        currently = (enemy == null ? "looking for a fight" : "fighting " + enemy.fullName);

        if (enemy == null) {
            stayWithThePlayer();
            return;
        }

        if (useAbility())
            return;

        if (self.rangedWeapon != null && self.distanceTo(enemy) < 12) {
            var clearShot = true;
            for (p in Bresenham.line(self.x, self.y, enemy.x, enemy.y).points) {
                if (world.blocksMovement(p.x, p.y, p.z))
                    clearShot = false;
                var other = world.getCreature(p.x, p.y, self.z);
                if (other != null && other != self && !isEnemy(other))
                    clearShot = false;
                if (!clearShot)
                    break;
            }

            if (clearShot)
                self.rangedAttack(enemy.x, enemy.y);
            else
                goTo(enemy.x, enemy.y, enemy.z);
        } else {
            goTo(enemy.x, enemy.y, enemy.z);
        }
    }

    private function getTreasure():Void {
        currently = (treasure == null ? "looking for treasure" : "getting " + treasure.item.name);

        if (treasure == null)  {
            stayWithThePlayer();
        } else if (world.getItem(treasure.position.x, treasure.position.y, treasure.position.z) == null) {
            treasure = null;
            stayWithThePlayer();
        } else if (self.z == treasure.position.z && self.y == treasure.position.y && self.x == treasure.position.x) {
            self.pickupItem();
            treasure = null;
        } else if (self.z == treasure.position.z)
            goTo(treasure.position.x, treasure.position.y, treasure.position.z);
        else {
            treasure = null;
            stayWithThePlayer();
        }
    }

    private function stayWithThePlayer():Void {
        currently = if (path == null || path.length == 0)
            "trying to find the group";
        else if (path.length < 4)
            "staying with the group";
        else
            'going to ${world.player.fullName}';

        if (!world.player.isVisible()) {
            currently = "looking for " + world.player.fullName;
            self.wander();
            return;
        }
        if (world.player.z == self.z) {
            var targetPoint = new IntPoint(world.player.x, world.player.y, world.player.z);
            var d = 0;
            while (d++ < favoredDistance && world.isWalkable(targetPoint.x + world.player.vx, targetPoint.y + world.player.vy, targetPoint.z)) {
                targetPoint.x += world.player.vx * forwardMultiplier;
                targetPoint.y += world.player.vy * forwardMultiplier;
            }
            goTo(targetPoint.x, targetPoint.y, targetPoint.z);
        } else {
            goTo(world.player.x, world.player.y, world.player.z);
        }
    }

    private function nearestVisibleItem(melee:Item, ranged:Item, armor:Item): { position:IntPoint, item:Item } {
        if (treasure != null && world.getItem(treasure.position.x, treasure.position.y, treasure.position.z) != null)
            return treasure;

        var closest:{ position:IntPoint, item:Item } = null;
        var closestDist = 10000.0;
        var fromPoint = new IntPoint(self.x, self.y, self.z);

        for (i in world.itemsList) {
            if (!world.isWalkable(i.position.x, i.position.y, i.position.z))
                continue;

            switch (i.item.type) {
                case "melee":
                    if (melee != null && melee.getValue() >= i.item.getValue())
                        continue;
                case "ranged":
                    if (ranged != null && ranged.getValue() >= i.item.getValue())
                        continue;
                case "armor":
                    if (armor != null && armor.getValue() >= i.item.getValue())
                        continue;
            }

            if (!self.canSeeTile(i.position.x, i.position.y, i.position.z))
                continue;

            var dist = fromPoint.distanceTo(i.position);
            if (dist > closestDist)
                continue;
            closestDist = dist;
            closest = i;
        }
        return closest;
    }
}
