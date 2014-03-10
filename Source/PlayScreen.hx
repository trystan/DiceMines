package;

import StringTools;
import knave.*;

class PlayScreen extends Screen {
    private var heights:Grid3<Float>;
    private var tiles:Grid3<Int>;
    
    private var floorHeight = 0.45;
    private var wallHeight = 0.65;

    private var tile_floor:Int = 250;
    private var tile_wall:Int = 177;
    private var tile_empty:Int = 0;
    private var tile_water:Int = 247;
    private var tile_bridge:Int = 61;
    private var tile_stairs_down:Int = 62;
    private var tile_stairs_up:Int = 60;

    private var player:Creature;
    private var creatures:Array<Creature>;
    private var items:Map<String, Item>;
    private var messages:Array<String>;
    private var projectiles:Array<Projectile>;
    private var isAnimating:Bool = false;
    private var updateAfterAnimating:Bool = false;

    public function new() {
        super();
        messages = new Array<String>();
        projectiles = new Array<Projectile>();
        worldgen(Math.floor(1024 / 12), Math.floor(720/ 12), 20);

        on("<", move, { x:0,  y:0,  z:-1 });
        on(">", move, { x:0,  y:0,  z:1  });
        on("left", move, { x:-1, y:0, z:0 });
        on("right", move, { x:1, y:0, z:0 });
        on("up", move, { x:0, y:-1, z:0 });
        on("down", move, { x:0, y:1, z:0 });
        on(".", move, { x:0,  y:0,  z:0  });
        on("keypress", doAction);
        on("tick", animate);
        on("draw", draw);
    }

    private function move(by: { x:Int, y:Int, z:Int } ):Void {
        if (isAnimating)
            return;

        player.move(by.x, by.y, by.z);
        update();
    }

    private function update():Void {
        for (c in creatures) {
            if (c.isAlive && c != player)
                c.doAi();
        }

        var stillAlive = new Array<Creature>();
        for (c in creatures) {
            c.update();
            if (c.isAlive)
                stillAlive.push(c);
        }
        creatures = stillAlive;

        rl.trigger("redraw");

        if (!player.isAlive) {
            switchTo(new EndScreen());
            rl.trigger("redraw");
        }
    }

    private function doAction(key:String):Void {
        if (isAnimating)
            return;

        if (key == "f" && player.rangedWeapon != null)
            enter(new AimScreen(this, player, function(x:Int,y:Int):Void {
                player.rangedAttack(x, y);
                updateAfterAnimating = true;
            }));
        else if (key == "g")
            player.pickupItem();

        rl.trigger("redraw");
    }

    private function animate():Void {
        var inAir = new Array<Creature>();
        for (c in creatures) {
            if (c.knockbackPath != null && c.knockbackPath.length > 0)
                inAir.push(c);
        }
        if (projectiles.length == 0 && inAir.length == 0) {
            isAnimating = false;
            if (updateAfterAnimating)
                update();
            updateAfterAnimating = false;
            return;
        }

        isAnimating = true;

        for (c in inAir) {
            var p = c.knockbackPath.shift();
            if (blocksMovement(p.x, p.y, c.z)) {
                c.knockbackPath = null;
            } else {
                c.x = p.x;
                c.y = p.y;
            }
        }

        var stillAlive = new Array<Projectile>();
        for (p in projectiles) {
            p.update();
            var c = getCreature(p.x, p.y, p.z);
            if (c != null)
                c.takeRangedAttack(p);
            else if (blocksMovement(p.x, p.y, p.z))
                p.isDone = true;
            else if (!p.isDone)
                stillAlive.push(p);
        }
        projectiles = stillAlive;
        rl.trigger("redraw");
    }
    
    public function draw(display:AsciiDisplay):Void {
        display.clear();

        for (x in 0 ... tiles.width)
        for (y in 0 ... tiles.height) {
            if (player.light.isLit(x, y)) {
                var g = getGraphic(x, y, player.z);

                var item = getItem(x, y, player.z);
                if (item != null)
                    display.write(item.glyph, x, y, item.color.toInt(), g.bg.toInt());
                else
                    display.write(g.glyph, x, y, g.fg.toInt(), g.bg.toInt());
            }
        }

        for (c in creatures) {
            if (c.z != player.z || !player.light.isLit(c.x, c.y))
                continue;

            var g = getGraphic(c.x, c.y, c.z);
            var color = c == player ? Color.hsv(200, 20, 90) : getCreatureColor(c);
            display.write(c.glyph, c.x, c.y, color.toInt(), g.bg.toInt());
        }

        for (p in projectiles) {
            if (p.z != player.z || !player.light.isLit(p.x, p.y))
                continue;

            var g = getGraphic(p.x, p.y, p.z);
            display.write("*", p.x, p.y, new Color(200, 0, 0).toInt(), g.bg.toInt());
        }

        var x = display.widthInCharacters - 16;
        var y = 1;
        var fg = new Color(200, 200, 200).toInt();
        var bg = new Color(0, 0, 0).toInt();
        display.write(player.name + " " + player.hp + "/" + player.maxHp, x, y++, fg, bg);
        display.write(' ' + (player.meleeWeapon == null ? "- no sword -" : player.meleeWeapon.name), x, y++, fg, bg);
        display.write(' ' + (player.rangedWeapon == null ? "- no bow -" : player.rangedWeapon.name), x, y++, fg, bg);
        display.write(' ' + (player.armor == null ? "- no armor -" : player.armor.name), x, y++, fg, bg);


        x = 1;
        y = 1;
        var item = getItem(player.x, player.y, player.z);
        if (item == null)
            y++;
        else
            display.write('[g]et ${item.name}', x, y++, fg, bg);

        if (player.rangedWeapon != null)
            display.write('[f]ire ${player.rangedWeapon.name}', x, y++, fg, bg);

        var y = display.heightInCharacters - messages.length;
        for (message in messages)
            display.writeCenter(message, y++, fg, bg);

        if (!isAnimating) {
            while (messages.length > 3)
                messages.shift();
        }

        display.update();
    }

    private function getCreatureColor(creature:Creature):Color {
        var percent = 1.0 * creature.hp / creature.maxHp;
        return Color.hsv(0, 90, 90).lerp(Color.hsv(90, 90, 90), percent);
    }

    private function getGraphic(x:Int, y:Int, z:Int): { glyph:String, fg:Color, bg:Color } {
        var tile = tiles.get(x, y, z);
        var h = (heights.get(x, y, z) - floorHeight) / 0.2 * 5;
        var glyph = String.fromCharCode(tile);
        var fg = Color.hsv(25 - z, 25, 40 + h);
        var bg = Color.hsv(25 - z, 25, 10 + h);

        if (tile == tile_empty) {
            bg = Color.hsv(220, 50, 5);
        } else if (tile == tile_water) {
            glyph = "=";
            fg = Color.hsv(220, 35 + Math.random() * 10, 25);
            bg = Color.hsv(220, 30 + Math.random() * 10, 20);
        } else if (tile == tile_bridge) {
            fg = Color.hsv(60, 33, 12);
            bg = Color.hsv(60, 33,  8);
        }

        if ((x+y) % 2 == 0) {
            fg = fg.darker();
            bg = bg.darker();
        }

        return { glyph: glyph, fg: fg, bg: bg };
    }

    public function addMessage(text:String):Void {
        messages.push(text);
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
    }

    public function getCreature(x:Int, y:Int, z:Int):Creature {
        for (c in creatures)
            if (c.x == x && c.y == y && c.z == z)
                return c;
        return null;
    }

    public function isEmptySpace(x:Int, y:Int, z:Int):Bool {
        return tiles.get(x, y, z) == tile_empty;
    }

    public function canGoDown(x:Int, y:Int, z:Int):Bool {
        return tiles.get(x, y, z) == tile_stairs_down;
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

    private function worldgen(w:Int, h:Int, d:Int):Void {
        heights = new Grid3<Float>(w, h, d);

        for (x in 0 ... w)
        for (y in 0 ... h)
        for (z in 0 ... d)
            heights.set(x, y, z, Math.random());

        disrupt(Math.floor(heights.width * heights.height * heights.depth / 10));
        smooth();
        normalize();
        carveFloors();

        makeTiles();
        addBridges();
        addStairs();

        creatures = new Array<Creature>();
        items = new Map<String, Item>();

        player = new Creature("@", "player", 20, 20, 0);
        player.damageStat = "5d5+5";
        addCreature(player);
        player.light = new Shadowcaster();
        do {
            player.x = Math.floor(Math.random() * (tiles.width - 20) + 10);
            player.y = Math.floor(Math.random() * (tiles.height - 20) + 10);
        } while(tiles.get(player.x, player.y, player.z) != tile_floor);
        player.update();

        addCreatures();
        addItems();
    }

    private function addCreatures():Void {
        for (z in 0 ... tiles.depth) {
            for (i in 0 ... 15 + z) {
                var creature = Factory.enemy(z);
                addCreature(creature);
                do {
                    creature.x = Math.floor(Math.random() * (tiles.width - 20) + 10);
                    creature.y = Math.floor(Math.random() * (tiles.height - 20) + 10);
                    creature.z = z;
                } while(tiles.get(creature.x, creature.y, creature.z) != tile_floor);
                creature.update();
            }
        }
    }

    private function addItems():Void {
        for (z in 0 ... tiles.depth) {
            for (i in 0 ... 5 + Math.floor(z/2)) {
                var item = Factory.item();
                var x = 0;
                var y = 0;
                do {
                    x = Math.floor(Math.random() * (tiles.width - 20) + 10);
                    y = Math.floor(Math.random() * (tiles.height - 20) + 10);
                } while(tiles.get(x, y, z) != tile_floor);
                addItem(item, x, y, z);
            }
        }
    }

    private function disrupt(amount:Int):Void {
        for(i in 0 ... amount) {
            var cx = Math.floor(Math.random() * heights.width);
            var cy = Math.floor(Math.random() * heights.height);
            var cz = Math.floor(Math.random() * heights.depth);
            var r = Math.floor(Math.random() * 4 + 4);
            var rz = Math.floor(r / 2);
            var mult = Math.random() < 0.5 ? -1 : 1;
            for (x in -r ... r+1)
            for (y in -r ... r+1)
            for (z in -rz ... rz+1) {
                var dist = x*x + y*y + z*z*4;
                if (dist > r*r || !heights.isInBounds(cx+x, cy+y, cz+z))
                    continue;
                var amount = (r - Math.sqrt(dist)) * mult;
                heights.set(cx+x, cy+y, cz+z, heights.get(cx+x,cy+y,cz+z) + amount);
            }
        }
    }

    private function smooth():Void {
        var heights2 = new Grid3<Float>(heights.width, heights.height, heights.depth);
        var r = 2;
        for (x in 0 ... heights.width)
        for (y in 0 ... heights.height)
        for (z in 0 ... heights.depth) {
            var value = heights.get(x, y, z);
            for (ox in -r ... r+1)
            for (oy in -r ... r+1) {
                if (!heights.isInBounds(x+ox, y+oy, z))
                    continue;

                value += heights.get(x+ox, y+oy, z);
            }
            heights2.set(x, y, z, value);
        }
        heights = heights2;
    }

    private function normalize():Void {
        for (z in 0 ... heights.depth) {
            var minHeight = 1000000.0;
            var maxHeight = 0.0;

            for (x in 0 ... heights.width)
            for (y in 0 ... heights.height) {
                var value = heights.get(x, y, z);
                minHeight = Math.min(minHeight, value);
                maxHeight = Math.max(maxHeight, value);
            }

            var range = maxHeight - minHeight;
            for (x in 0 ... heights.width)
            for (y in 0 ... heights.height)
                heights.set(x, y, z, (heights.get(x, y, z) - minHeight) / range);
        }
    }

    private function carveFloors():Void {
        for (x in 0 ... heights.width)
        for (y in 0 ... heights.height)
        for (z in 1 ... heights.depth) {
            var height = heights.get(x, y, z);
            if (height < wallHeight)
                continue;
            var heightAbove = heights.get(x, y, z-1);
            if (heightAbove >= floorHeight)
                continue;
            heights.set(x, y, z, wallHeight - 0.1);
        }
    }

    private function makeTiles():Void {
        tiles = new Grid3<Int>(heights.width, heights.height, heights.depth);

        for (x in 0 ... heights.width)
        for (y in 0 ... heights.height)
        for (z in 0 ... heights.depth) {
            var height = heights.get(x, y, z);
            tiles.set(x, y, z, height < floorHeight ? tile_empty : (height > wallHeight ? tile_wall : tile_floor));
            if (z == heights.depth - 1 && tiles.get(x, y, z) == tile_empty)
                tiles.set(x, y, z, tile_water);
        }
    }

    private function addBridges():Void {
        for (z in 0 ... heights.depth) {
            for (i in 0 ... 15) {
                var cx = Math.floor(Math.random() * (heights.width - 10) + 5);
                var cy = Math.floor(Math.random() * (heights.height - 10) + 5);
                if (tiles.get(cx, cy, z) != tile_empty)
                    continue;

                var x = cx;
                var y = cy;
                tiles.set(x, y, z, tile_bridge);

                if (Math.random() < 0.5) {
                    x = cx;
                    while (tiles.isInBounds(--x, y, z) && tiles.get(x, y, z) == tile_empty)
                        tiles.set(x, y, z, tile_bridge);
                    x = cx;
                    while (tiles.isInBounds(++x, y, z) && tiles.get(x, y, z) == tile_empty)
                        tiles.set(x, y, z, tile_bridge);
                } else {
                    y = cy;
                    while (tiles.isInBounds(x, --y, z) && tiles.get(x, y, z) == tile_empty)
                        tiles.set(x, y, z, tile_bridge);
                    y = cy;
                    while (tiles.isInBounds(x, ++y, z) && tiles.get(x, y, z) == tile_empty)
                        tiles.set(x, y, z, tile_bridge);
                }
            }
        }
    }

    private function addStairs():Void {
        for (z in 0 ... heights.depth-1) {
            var count = 0;
            while (count < 5) {
                var x = Math.floor(Math.random() * heights.width);
                var y = Math.floor(Math.random() * heights.height);

                if (tiles.get(x, y, z) != tile_floor)
                    continue;

                if (tiles.get(x, y, z+1) != tile_floor)
                    continue;

                count++;
                tiles.set(x, y, z, tile_stairs_down);
                tiles.set(x, y, z+1, tile_stairs_up);
            }
        }
    }
}
