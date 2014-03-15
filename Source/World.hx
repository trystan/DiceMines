package;

import knave.Grid3;

class World {
    public var playScreen:PlayScreen;
    public var floorHeight = 0.44;
    public var wallHeight = 0.58;
    
    public var heights:Grid3<Float>;
    public var tiles:Grid3<Int>;

    public var tile_floor:Int = 250;
    public var tile_wall:Int = 177;
    public var tile_empty:Int = 0;
    public var tile_water:Int = 247;
    public var tile_lava:Int = 249;
    public var tile_bridge:Int = 61;
    public var tile_stairs_down:Int = 62;
    public var tile_stairs_up:Int = 60;

    public var fireList:Array<String>;
    public var fireMap:Map<String, Bool>;
    public var creatures:Array<Creature>;
    public var heroParty:Array<Creature>;
    public var items:Map<String, Item>;
    public var messages:Array<String>;
    public var projectiles:Array<Projectile>;
    public var effects:Array<{ countdown:Int, func:Int -> Void }>;

    public var player:Creature;

    public function new(w:Int, h:Int, d:Int) {
        heights = new Grid3<Float>(w, h, d);
        tiles = new Grid3<Int>(w, h, d);
        messages = new Array<String>();
        projectiles = new Array<Projectile>();
        fireList = new Array<String>();
        fireMap = new Map<String, Bool>();
        effects = new Array<{ countdown:Int, func:Int -> Void }>();
        creatures = new Array<Creature>();
        heroParty = new Array<Creature>();
        items = new Map<String, Item>();
    }

    public function update():Void {
        var newEffects = new Array<{ countdown:Int, func:Int -> Void }>();
        for (e in effects) {
            if (--e.countdown > 0)
                newEffects.push(e);
            e.func(e.countdown);
        }
        effects = newEffects;

        var newFireList = new Array<String>();
        for (p in fireList) {
            if (Math.random() < 0.75)
                newFireList.push(p);
            else
                fireMap.remove(p);
        }
        fireList = newFireList;

        for (c in creatures) {
            if (c.isAlive && c != player)
                c.doAi();
        }

        var stillAlive = new Array<Creature>();
        for (c in creatures) {
            if (isOnFire(c.x, c.y, c.z))
                c.takeDamage(5, null);
            if (isLava(c.x, c.y, c.z))
                c.takeDamage(10, null);

            if (c.isAlive)
                c.update();
            if (c.isAlive)
                stillAlive.push(c);
        }
        creatures = stillAlive;
    }

    public function addMessage(text:String):Void {
        while (text.indexOf("  ") > -1)
            text = StringTools.replace(text, "  ", " ");
        messages.push(text);
    }

    public function isOnFire(x:Int, y:Int, z:Int):Bool {
        return fireMap.get('$x,$y,$z') == true;
    }

    public function addFire(x:Int, y:Int, z:Int):Void {
        if (blocksMovement(x, y, z) || isEmptySpace(x, y, z) || isLava(x, y, z) || isWater(x, y, z))
            return;

        fireMap.set('$x,$y,$z', true);
        fireList.push('$x,$y,$z');
    }

    public function addItem(item:Item, x:Int, y:Int, z:Int):Void {
        items.set('$x,$y,$z', item);
    }

    public function getItem(x:Int, y:Int, z:Int):Item {
        return items.get('$x,$y,$z');
    }

    public function removeItem(x:Int, y:Int, z:Int):Item {
        var item = items.get('$x,$y,$z');
        items.remove('$x,$y,$z');
        return item;
    }

    public function addProjectile(projectile:Projectile):Void {
        projectiles.push(projectile);
    }

    public function addCreature(creature:Creature):Void {
        creature.world = this;
        creatures.push(creature);
        if (creature.isHero()) {
            heroParty.push(creature); 
            if (player == null)
                player = creature;
        }
    }

    public function getCreature(x:Int, y:Int, z:Int):Creature {
        for (c in creatures)
            if (c.x == x && c.y == y && c.z == z && c.isAlive)
                return c;
        return null;
    }

    public function isWalkable(x:Int, y:Int, z:Int):Bool {
        return !blocksMovement(x, y, z) && !isEmptySpace(x, y, z) && !isLava(x, y, z);
    }

    public function isEmptySpace(x:Int, y:Int, z:Int):Bool {
        return tiles.get(x, y, z) == tile_empty;
    }

    public function isWater(x:Int, y:Int, z:Int):Bool {
        return tiles.get(x, y, z) == tile_water;
    }

    public function isLava(x:Int, y:Int, z:Int):Bool {
        return tiles.get(x, y, z) == tile_lava;
    }

    public function canGoDown(x:Int, y:Int, z:Int):Bool {
        return tiles.get(x, y, z) == tile_stairs_down || isEmptySpace(x, y, z);
    }

    public function canGoUp(x:Int, y:Int, z:Int):Bool {
        return tiles.get(x, y, z) == tile_stairs_up;
    }

    public function blocksMovement(x:Int, y:Int, z:Int):Bool {
        return !tiles.isInBounds(x, y, z) || tiles.get(x, y, z) == tile_wall;
    }

    public function blocksVision(x:Int, y:Int, z:Int):Bool {
        return !tiles.isInBounds(x, y, z) || tiles.get(x, y, z) == tile_wall;
    }
}
