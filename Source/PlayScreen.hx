package;

import StringTools;
import knave.*;

class PlayScreen extends Screen {
    private var heights:Grid3<Float>;
    private var tiles:Grid3<Int>;
    
    private var floorHeight = 0.44;
    private var wallHeight = 0.58;

    private var tile_floor:Int = 250;
    private var tile_wall:Int = 177;
    private var tile_empty:Int = 0;
    private var tile_water:Int = 247;
    private var tile_lava:Int = 249;
    private var tile_bridge:Int = 61;
    private var tile_stairs_down:Int = 62;
    private var tile_stairs_up:Int = 60;

    public var player:Creature;
    private var fireList:Array<String>;
    private var fireMap:Map<String, Bool>;
    public var creatures:Array<Creature>;
    private var items:Map<String, Item>;
    private var messages:Array<String>;
    private var projectiles:Array<Projectile>;
    private var isAnimating:Bool = false;
    private var updateAfterAnimating:Bool = false;
    public var effects:Array<{ countdown:Int, func:Int -> Void }>;

    public function new() {
        super();
        Factory.init();
        messages = new Array<String>();
        projectiles = new Array<Projectile>();
        fireList = new Array<String>();
        fireMap = new Map<String, Bool>();
        effects = new Array<{ countdown:Int, func:Int -> Void }>();

        worldgen(201, 201, 10);

        on("<", move, { x:0,  y:0,  z:-1 });
        on(">", move, { x:0,  y:0,  z:1  });
        on("left", move, { x:-1, y:0, z:0 });
        on("right", move, { x:1, y:0, z:0 });
        on("up", move, { x:0, y:-1, z:0 });
        on("down", move, { x:0, y:1, z:0 });
        on("up left", move, { x:-1, y:-1, z:0 });
        on("up right", move, { x:1, y:-1, z:0 });
        on("down left", move, { x:-1, y:1, z:0 });
        on("down right", move, { x:1, y:1, z:0 });
        on(".", move, { x:0,  y:0,  z:0  });
        on("@", enter, new CharacterInfoScreen(this, player));
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

        rl.trigger("redraw");

        if (!player.isAlive) {
            switchTo(new EndScreen());
            rl.trigger("redraw");
        }
    }

    private function doAction(key:String):Void {
        if (isAnimating)
            return;

        if (key == "f" && player.rangedWeapon != null) {
            enter(new AimScreen(player, 40, function(x:Int,y:Int):Void {
                player.rangedAttack(x, y);
                updateAfterAnimating = true;
            }));
        } else if (key == "g") {
            player.pickupItem();
            update();
        } else {
            for (ability in player.abilities) {
                if (ability.name.charAt(0) == key) {
                    ability.playerUsage(player);
                    updateAfterAnimating = true;
                    break;
                }
            }
        }
    }

    private function animate():Void {
        var inAir = new Array<Creature>();
        for (c in creatures) {
            if (c.animatePath != null && c.animatePath.length > 0)
                inAir.push(c);
        }
        if (projectiles.length == 0 && inAir.length == 0) {
            rl.trigger("redraw");
            isAnimating = false;
            if (updateAfterAnimating)
                update();
            updateAfterAnimating = false;
            return;
        }

        isAnimating = true;

        for (c in inAir) {
            var p = c.animatePath.shift();
            if (blocksMovement(p.x, p.y, c.z)) {
                c.animatePath = null;
            } else {
                var other = getCreature(p.x, p.y, c.z);
                if (other != null) {
                    other.takeDamage(c.animatePath.length + 1, c);
                    if (other.isAlive) {
                        c.attack(other);
                        c.animatePath = null;
                    }
                } else {
                    c.x = p.x;
                    c.y = p.y;
                    c.updateVision();
                }
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

    public var viewLeft:Int;
    public var viewTop:Int;
    public function draw(display:AsciiDisplay):Void {
        display.clear();

        var vx = Math.floor(player.x - display.widthInCharacters / 2);
        var vy  = Math.floor(player.y - display.heightInCharacters / 2);
        viewLeft = vx;
        viewTop = vy;
        for (sx in 0 ... display.widthInCharacters)
        for (sy in 0 ... display.heightInCharacters) {
            var x = sx + vx;
            var y = sy + vy;
            if (player.light.isLit(x, y)) {
                var g = getGraphic(x, y, player.z);

                var item = getItem(x, y, player.z);
                if (item != null)
                    display.write(item.glyph, sx, sy, item.color.toInt(), g.bg.toInt());
                else
                    display.write(g.glyph, sx, sy, g.fg.toInt(), g.bg.toInt());
            }
        }

        for (c in creatures) {
            if (c.z != player.z || !player.light.isLit(c.x, c.y) || (c != player && !c.isVisible()))
                continue;

            var g = getGraphic(c.x, c.y, c.z);
            var color = c.glyph == "@" ? Color.hsv(200, 20, 90) : getCreatureColor(c);
            var bg = g.bg;
            if (c.fearCounter > 0)
                bg = Color.hsv(60, 50, 50);
            if (c.sleepCounter > 0)
                bg = Color.hsv(180, 20, 50);
            display.write(c.glyph, c.x - vx, c.y - vy, color.toInt(), bg.toInt());
        }

        for (p in projectiles) {
            if (p.z != player.z || !player.light.isLit(p.x, p.y))
                continue;

            var g = getGraphic(p.x, p.y, p.z);
            display.write(p.glyph, p.x - vx, p.y - vy, p.color, g.bg.toInt());
        }

        var x = display.widthInCharacters - 16;
        var y = 1;
        var fg = new Color(200, 200, 200).toInt();
        var bg = new Color(0, 0, 0).toInt();
        display.write(player.name + " " + player.hp + "/" + player.maxHp, x, y++, fg, bg);
        var characterMelee = player.meleeWeapon == null ? "- no sword -" : player.meleeWeapon.name;
        display.write(characterMelee, display.widthInCharacters - characterMelee.length - 1, y++, fg, bg);

        var characterRanged = player.rangedWeapon == null ? "-  no bow  -" : player.rangedWeapon.name;
        display.write(characterRanged, display.widthInCharacters - characterRanged.length - 1, y++, fg, bg);

        var characterArmor = player.armor == null ? "- no armor -" : player.armor.name;
        display.write(characterArmor, display.widthInCharacters - characterArmor.length - 1, y++, fg, bg);

        x = 1;
        y = 1;
        display.write('[@] view ${player.name}', x, y++, fg, bg);
        var item = getItem(player.x, player.y, player.z);
        if (item == null)
            y++;
        else
            display.write('[g]et ${item.name}', x, y++, fg, bg);

        if (player.rangedWeapon != null)
            display.write('[f]ire ${player.rangedWeapon.name}', x, y++, fg, bg);

        for (ability in player.abilities)
            display.write("[" + ability.name.charAt(0) + "]" + ability.name.substr(1), x, y++, fg, bg);

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
        if (!tiles.isInBounds(x, y, z))
            return { glyph: " ", fg: new Color(200,200,200), bg: new Color(0,0,0) };

        var tile = tiles.get(x, y, z);
        var h = (heights.get(x, y, z) - floorHeight) / 0.2 * 5;
        var glyph = String.fromCharCode(tile);
        var fg = Color.hsv(25 - z, 25, 40 + h);
        var bg = Color.hsv(25 - z, 25, 10 + h);

        if (tile == tile_empty) {
            bg = Color.hsv(220, 50, 5);
        } else if (tile == tile_lava) {
            glyph = String.fromCharCode(247);
            fg = Color.hsv(Math.random() * 10, 80 + Math.random() * 2, 50);
            bg = Color.hsv(Math.random() *  5, 80 + Math.random() * 2, 40);
        } else if (tile == tile_water) {
            glyph = String.fromCharCode(247);
            fg = Color.hsv(220 + Math.random() * 10, 30 + Math.random() * 2, 20);
            bg = Color.hsv(220 + Math.random() * 10, 25 + Math.random() * 2, 15);
        } else if (tile == tile_bridge) {
            fg = Color.hsv(60, 33, 12);
            bg = Color.hsv(60, 33,  8);
        }

        if (isOnFire(x, y, z)) {
            glyph = "*";
            fg = Color.hsv(Math.random() * 10, 75 + Math.random() * 5, 75 + Math.random() * 5);
            bg = Color.hsv(Math.random() *  5, 75 + Math.random() * 5, 25 + Math.random() * 5);
        }

        if ((x+y) % 2 == 0) {
            fg = fg.darker();
            bg = bg.darker();
        }

        return { glyph: glyph, fg: fg, bg: bg };
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

#if neko
        disrupt(Math.floor(heights.width * heights.height * heights.depth / 100));
#else
        disrupt(Math.floor(heights.width * heights.height * heights.depth / 10));
#end
        smooth();
        normalize();
        addPillars();
        carveFloors();

        makeTiles();
        addWater();
        addLava();
        addBridges();
        addCorridors();
        removeDiagonals();
        addStairs();

        creatures = new Array<Creature>();
        items = new Map<String, Item>();

        player = Factory.hero();
        addCreature(player);
        do {
            player.x = Math.floor(Math.random() * (tiles.width - 20) + 10);
            player.y = Math.floor(Math.random() * (tiles.height - 20) + 10);
        } while(tiles.get(player.x, player.y, player.z) != tile_floor);
        player.update();

        addCreatures();
        addDice();
        addItems();
    }

    private function addCreatures():Void {
        for (z in 0 ... tiles.depth) {
            for (i in 0 ... 16 + Math.floor(z/2)) {
                var x = 0;
                var y = 0;
                do {
                    x = Math.floor(Math.random() * (tiles.width - 20) + 10);
                    y = Math.floor(Math.random() * (tiles.height - 20) + 10);
                } while(tiles.get(x, y, z) != tile_floor);
                var enemyList = Factory.enemies(z);
                for (creature in enemyList) {
                    addCreature(creature);
                    var r = enemyList.length + 1;
                    do {
                        creature.x = x + Math.floor(Math.random() * (r+1)) - r;
                        creature.y = y + Math.floor(Math.random() * (r+1)) - r;
                        creature.z = z;
                    } while(!isWalkable(creature.x, creature.y, creature.z));
                    creature.update();
                }
            }
        }
    }

    private function addDice():Void {
        for (z in 0 ... tiles.depth) {
            for (i in 0 ... 10 + z) {
                var x = 0;
                var y = 0;
                do {
                    x = Math.floor(Math.random() * (tiles.width - 20) + 10);
                    y = Math.floor(Math.random() * (tiles.height - 20) + 10);
                } while(tiles.get(x, y, z) != tile_floor);

                var here = new IntPoint(x, y);
                var nearWallCandidates = new Array<IntPoint>();

                for (n in here.neighbors9()) {
                    if (tiles.get(n.x, n.y, z) != tile_floor)
                        continue;

                    var isOk = false;
                    for (n2 in n.neighbors8()) {
                        if (tiles.get(n2.x, n2.y, z) == tile_wall)
                            isOk = true;
                    }
                    if (isOk)
                        nearWallCandidates.push(n);
                }

                for (p in nearWallCandidates)
                    addItem(Factory.dice(), p.x, p.y, z);
            }
        }
    }

    private function addItems():Void {
        for (z in 0 ... tiles.depth) {
            for (i in 0 ... 10 + Math.floor(z/2)) {
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

    private function addPillars():Void {
        for (z in 0 ... heights.depth) {
            for (i in 0 ... 20) {
                var cx = Math.floor(Math.random() * (heights.width - 6) + 3);
                var cy = Math.floor(Math.random() * (heights.height - 6) + 3);
                var cz = z;
                do {
                    heights.set(cx, cy, cz, 1);
                    heights.set(cx+1, cy, cz, 1);
                    heights.set(cx+1, cy+1, cz, 1);
                    heights.set(cx, cy+1, cz, 1);
                } while (cz-- > 0 && heights.get(cx, cy, cz-1) < floorHeight);
            }
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

        var cx = heights.width / 2;
        var cy = heights.height / 2;
        var r2 = cx*cy - 1;
        for (x in 0 ... heights.width)
        for (y in 0 ... heights.height)
        for (z in 0 ... heights.depth) {
            if ((x-cx)*(x-cx)+(y-cy)*(y-cy) > r2) {
                tiles.set(x, y, z, tile_wall);
                continue;
            }
            var height = heights.get(x, y, z);
            tiles.set(x, y, z, height < floorHeight ? tile_empty : (height > wallHeight ? tile_wall : tile_floor));
            if (z == heights.depth - 1 && tiles.get(x, y, z) == tile_empty)
                tiles.set(x, y, z, tile_lava);
        }
    }

    private function addWater():Void {
        fillEmptySpace(tile_water);
    }

    private function addLava():Void {
        fillEmptySpace(tile_lava);
    }

    private function fillEmptySpace(tile_type:Int):Void {
        for (z in 0 ... heights.depth) {
            var cx = Math.floor(Math.random() * (heights.width - 10) + 5);
            var cy = Math.floor(Math.random() * (heights.height - 10) + 5);

            if (tiles.get(cx, cy, z) != tile_empty)
                continue;

            var open = new Array<IntPoint>();
            open.push(new IntPoint(cx, cy));

            var openString = '[$cx,$cy]';

            while (open.length > 0) {
                var p = open.shift();

                tiles.set(p.x, p.y, z, tile_type);

                for (p2 in p.neighbors4()) {
                    if (tiles.isInBounds(p2.x, p2.y, z) && isEmptySpace(p2.x, p2.y, z) && openString.indexOf('[${p2.x},${p2.y}]') == -1) {
                        open.push(p2);
                        openString += '[${p2.x},${p2.y}]';
                    }
                }
            }
        }
    }

    private function addBridges():Void {
        for (z in 0 ... heights.depth) {
            for (i in 0 ... 30) {
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

    private function addCorridors():Void {
        for (z in 0 ... heights.depth) {
            for (i in 0 ... 20) {
                var x = Math.floor(Math.random() * heights.width);
                var y = Math.floor(Math.random() * heights.height);
                var mx = Math.floor(Math.random() * 3) - 1;
                var my = Math.floor(Math.random() * 3) - 1;

                while (tiles.isInBounds(x, y, z) && tiles.get(x, y, z) == tile_wall) {
                    heights.set(x, y, z, wallHeight - 0.01);
                    tiles.set(x, y, z, tile_floor);

                    x += mx;
                    y += my;
                }
            }
        }
    }

    private function removeDiagonals():Void {
        for (x in 0 ... tiles.width - 1)
        for (y in 0 ... tiles.height - 1)
        for (z in 0 ... tiles.depth) {
            var ul = isWalkable(x, y, z);
            var ur = isWalkable(x+1, y, z);
            var ll = isWalkable(x, y+1, z);
            var lr = isWalkable(x+1, y+1, z);

            if (ul && lr && !ur && !ll) {
                if (Math.random() < 0.5)
                    tiles.set(x+1, y, z, tile_floor);
                else
                    tiles.set(x, y+1, z, tile_floor);
            } else if (ll && ur && !ul && !lr) {
                if (Math.random() < 0.5)
                    tiles.set(x, y, z, tile_floor);
                else
                    tiles.set(x+1, y+1, z, tile_floor);
            }
        }
    }


    private function addStairs():Void {
        for (z in 0 ... heights.depth-1) {
            var count = 0;
            while (count < 20) {
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
