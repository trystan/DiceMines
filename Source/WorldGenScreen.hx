package;

import knave.*;

class WorldGenScreen extends Screen {
    private var stepId:Int = 0;
    private var fg:Int;

    private var world:World;

    private var steps:Array<{ name:String, func:Dynamic }>;

    public function new() {
        super();

        fg = Color.hsv(240, 10, 90).toInt();

        steps = [
            { name:"-- DiceMiner worldgen --", func:function() { } },
            { name:" initializing definitions", func:Factory.init },
            { name:" initializing world", func:initWorld },
            { name:" initializing world heightmaps", func:initHeights },
            { name:" fluctuating heightmaps", func:addFluctuations },
            { name:" smoothing heightmaps", func:smooth },
            { name:" normalizing heightmaps", func:normalize },
            { name:" adding pillars", func:addPillars },
            { name:" carveing floors", func:carveFloors },
            { name:" adding world tiles", func:makeTiles },
            { name:" adding water", func:addWater },
            { name:" adding lava", func:addLava },
            { name:" adding bridges", func:addBridges },
            { name:" adding corridors", func:addCorridors },
            { name:" removing diagonals", func:removeDiagonals },
            { name:" adding stairs", func:addStairs },
            { name:" adding player", func:addPlayer },
            { name:" adding creatures", func:addCreatures },
            { name:" adding items", func:addItems },
            { name:" adding dice", func:addDice },
            { name:" beginning play", func:function(){ } } ];

        on("tick", step);
        on("draw", draw);
    }

    public function draw(display:AsciiDisplay):Void {
        display.clear();


        var x = 1;
        var y = display.heightInCharacters - stepId - 1;
        for (i in 0 ... stepId)
            display.write(steps[i].name, x, y++, fg);
        display.update();
    }

    private function step():Void {
        if (stepId >= steps.length) {
            switchTo(new PlayScreen(world));
            return;
        }

        steps[stepId++].func();

        rl.trigger("redraw");
    }

    private function initWorld():Void {
        world = new World(201, 201, 10);
    }

    private function initHeights():Void {
        for (x in 0 ... world.heights.width)
        for (y in 0 ... world.heights.height)
        for (z in 0 ... world.heights.depth)
            world.heights.set(x, y, z, Math.random());
    }

    private function addFluctuations():Void {
#if neko
        disrupt(Math.floor(world.heights.width * world.heights.height * world.heights.depth / 100));
#else
        disrupt(Math.floor(world.heights.width * world.heights.height * world.heights.depth / 10));
#end
    }

    private function addPlayer():Void {
        var player = Factory.hero();
        world.player = player;
        world.addCreature(player);
        do {
            player.x = Math.floor(Math.random() * (world.tiles.width - 20) + 10);
            player.y = Math.floor(Math.random() * (world.tiles.height - 20) + 10);
        } while(world.tiles.get(player.x, player.y, player.z) != world.tile_floor);
        player.update();
    }

    private function addCreatures():Void {
        for (z in 0 ... world.tiles.depth) {
            for (i in 0 ... 16 + Math.floor(z/2)) {
                var x = 0;
                var y = 0;
                do {
                    x = Math.floor(Math.random() * (world.tiles.width - 20) + 10);
                    y = Math.floor(Math.random() * (world.tiles.height - 20) + 10);
                } while(world.tiles.get(x, y, z) != world.tile_floor);
                var enemyList = Factory.enemies(z);
                for (creature in enemyList) {
                    world.addCreature(creature);
                    var r = enemyList.length + 1;
                    do {
                        creature.x = x + Math.floor(Math.random() * (r+1)) - r;
                        creature.y = y + Math.floor(Math.random() * (r+1)) - r;
                        creature.z = z;
                    } while(!world.isWalkable(creature.x, creature.y, creature.z));
                    creature.update();
                }
            }
        }
    }

    private function addDice():Void {
        for (z in 0 ... world.tiles.depth) {
            for (i in 0 ... 10 + z) {
                var x = 0;
                var y = 0;
                do {
                    x = Math.floor(Math.random() * (world.tiles.width - 20) + 10);
                    y = Math.floor(Math.random() * (world.tiles.height - 20) + 10);
                } while(world.tiles.get(x, y, z) != world.tile_floor);

                var here = new IntPoint(x, y);
                var nearWallCandidates = new Array<IntPoint>();

                for (n in here.neighbors9()) {
                    if (world.tiles.get(n.x, n.y, z) != world.tile_floor)
                        continue;

                    var isOk = false;
                    for (n2 in n.neighbors8()) {
                        if (world.tiles.get(n2.x, n2.y, z) == world.tile_wall)
                            isOk = true;
                    }
                    if (isOk)
                        nearWallCandidates.push(n);
                }

                for (p in nearWallCandidates)
                    world.addItem(Factory.dice(), p.x, p.y, z);
            }
        }
    }

    private function addItems():Void {
        for (z in 0 ... world.tiles.depth) {
            for (i in 0 ... 10 + Math.floor(z/2)) {
                var item = Factory.item();
                var x = 0;
                var y = 0;
                do {
                    x = Math.floor(Math.random() * (world.tiles.width - 20) + 10);
                    y = Math.floor(Math.random() * (world.tiles.height - 20) + 10);
                } while(world.tiles.get(x, y, z) != world.tile_floor);
                world.addItem(item, x, y, z);
            }
        }
    }

    private function disrupt(amount:Int):Void {
        for(i in 0 ... amount) {
            var cx = Math.floor(Math.random() * world.heights.width);
            var cy = Math.floor(Math.random() * world.heights.height);
            var cz = Math.floor(Math.random() * world.heights.depth);
            var r = Math.floor(Math.random() * 4 + 4);
            var rz = Math.floor(r / 2);
            var mult = Math.random() < 0.5 ? -1 : 1;
            for (x in -r ... r+1)
            for (y in -r ... r+1)
            for (z in -rz ... rz+1) {
                var dist = x*x + y*y + z*z*4;
                if (dist > r*r || !world.heights.isInBounds(cx+x, cy+y, cz+z))
                    continue;
                var amount = (r - Math.sqrt(dist)) * mult;
                world.heights.set(cx+x, cy+y, cz+z, world.heights.get(cx+x,cy+y,cz+z) + amount);
            }
        }
    }

    private function smooth():Void {
        var heights2 = new Grid3<Float>(world.heights.width, world.heights.height, world.heights.depth);
        var r = 2;
        for (x in 0 ... world.heights.width)
        for (y in 0 ... world.heights.height)
        for (z in 0 ... world.heights.depth) {
            var value = world.heights.get(x, y, z);
            for (ox in -r ... r+1)
            for (oy in -r ... r+1) {
                if (!world.heights.isInBounds(x+ox, y+oy, z))
                    continue;

                value += world.heights.get(x+ox, y+oy, z);
            }
            heights2.set(x, y, z, value);
        }
        world.heights = heights2;
    }

    private function normalize():Void {
        for (z in 0 ... world.heights.depth) {
            var minHeight = 1000000.0;
            var maxHeight = 0.0;

            for (x in 0 ... world.heights.width)
            for (y in 0 ... world.heights.height) {
                var value = world.heights.get(x, y, z);
                minHeight = Math.min(minHeight, value);
                maxHeight = Math.max(maxHeight, value);
            }

            var range = maxHeight - minHeight;
            for (x in 0 ... world.heights.width)
            for (y in 0 ... world.heights.height)
                world.heights.set(x, y, z, (world.heights.get(x, y, z) - minHeight) / range);
        }
    }

    private function addPillars():Void {
        for (z in 0 ... world.heights.depth) {
            for (i in 0 ... 20) {
                var cx = Math.floor(Math.random() * (world.heights.width - 6) + 3);
                var cy = Math.floor(Math.random() * (world.heights.height - 6) + 3);
                var cz = z;
                do {
                    world.heights.set(cx, cy, cz, 1);
                    world.heights.set(cx+1, cy, cz, 1);
                    world.heights.set(cx+1, cy+1, cz, 1);
                    world.heights.set(cx, cy+1, cz, 1);
                } while (cz-- > 0 && world.heights.get(cx, cy, cz-1) < world.floorHeight);
            }
        }
    }

    private function carveFloors():Void {
        for (x in 0 ... world.heights.width)
        for (y in 0 ... world.heights.height)
        for (z in 1 ... world.heights.depth) {
            var height = world.heights.get(x, y, z);
            if (height < world.wallHeight)
                continue;
            var heightAbove = world.heights.get(x, y, z-1);
            if (heightAbove >= world.floorHeight)
                continue;
            world.heights.set(x, y, z, world.wallHeight - 0.1);
        }
    }

    private function makeTiles():Void {
        world.tiles = new Grid3<Int>(world.heights.width, world.heights.height, world.heights.depth);

        var cx = world.heights.width / 2;
        var cy = world.heights.height / 2;
        var r2 = cx*cy - 1;
        for (x in 0 ... world.heights.width)
        for (y in 0 ... world.heights.height)
        for (z in 0 ... world.heights.depth) {
            if ((x-cx)*(x-cx)+(y-cy)*(y-cy) > r2) {
                world.tiles.set(x, y, z, world.tile_wall);
                continue;
            }
            var height = world.heights.get(x, y, z);
            world.tiles.set(x, y, z, height < world.floorHeight ? world.tile_empty : (height > world.wallHeight ? world.tile_wall : world.tile_floor));
            if (z == world.heights.depth - 1 && world.tiles.get(x, y, z) == world.tile_empty)
                world.tiles.set(x, y, z, world.tile_lava);
        }
    }

    private function addWater():Void {
        fillEmptySpace(world.tile_water);
    }

    private function addLava():Void {
        fillEmptySpace(world.tile_lava);
    }

    private function fillEmptySpace(tile_type:Int):Void {
        for (z in 0 ... world.heights.depth) {
            var cx = Math.floor(Math.random() * (world.heights.width - 10) + 5);
            var cy = Math.floor(Math.random() * (world.heights.height - 10) + 5);

            if (world.tiles.get(cx, cy, z) != world.tile_empty)
                continue;

            var open = new Array<IntPoint>();
            open.push(new IntPoint(cx, cy));

            var openString = '[$cx,$cy]';

            while (open.length > 0) {
                var p = open.shift();

                world.tiles.set(p.x, p.y, z, tile_type);

                for (p2 in p.neighbors4()) {
                    if (world.tiles.isInBounds(p2.x, p2.y, z) && world.isEmptySpace(p2.x, p2.y, z) && openString.indexOf('[${p2.x},${p2.y}]') == -1) {
                        open.push(p2);
                        openString += '[${p2.x},${p2.y}]';
                    }
                }
            }
        }
    }

    private function addBridges():Void {
        for (z in 0 ... world.heights.depth) {
            for (i in 0 ... 30) {
                var cx = Math.floor(Math.random() * (world.heights.width - 10) + 5);
                var cy = Math.floor(Math.random() * (world.heights.height - 10) + 5);
                if (world.tiles.get(cx, cy, z) != world.tile_empty)
                    continue;

                var x = cx;
                var y = cy;
                world.tiles.set(x, y, z, world.tile_bridge);

                if (Math.random() < 0.5) {
                    x = cx;
                    while (world.tiles.isInBounds(--x, y, z) && world.tiles.get(x, y, z) == world.tile_empty)
                        world.tiles.set(x, y, z, world.tile_bridge);
                    x = cx;
                    while (world.tiles.isInBounds(++x, y, z) && world.tiles.get(x, y, z) == world.tile_empty)
                        world.tiles.set(x, y, z, world.tile_bridge);
                } else {
                    y = cy;
                    while (world.tiles.isInBounds(x, --y, z) && world.tiles.get(x, y, z) == world.tile_empty)
                        world.tiles.set(x, y, z, world.tile_bridge);
                    y = cy;
                    while (world.tiles.isInBounds(x, ++y, z) && world.tiles.get(x, y, z) == world.tile_empty)
                        world.tiles.set(x, y, z, world.tile_bridge);
                }
            }
        }
    }

    private function addCorridors():Void {
        for (z in 0 ... world.heights.depth) {
            for (i in 0 ... 20) {
                var x = Math.floor(Math.random() * world.heights.width);
                var y = Math.floor(Math.random() * world.heights.height);
                var mx = Math.floor(Math.random() * 3) - 1;
                var my = Math.floor(Math.random() * 3) - 1;

                while (world.tiles.isInBounds(x, y, z) && world.tiles.get(x, y, z) == world.tile_wall) {
                    world.heights.set(x, y, z, world.wallHeight - 0.01);
                    world.tiles.set(x, y, z, world.tile_floor);

                    x += mx;
                    y += my;
                }
            }
        }
    }

    private function removeDiagonals():Void {
        for (x in 0 ... world.tiles.width - 1)
        for (y in 0 ... world.tiles.height - 1)
        for (z in 0 ... world.tiles.depth) {
            var ul = world.isWalkable(x, y, z);
            var ur = world.isWalkable(x+1, y, z);
            var ll = world.isWalkable(x, y+1, z);
            var lr = world.isWalkable(x+1, y+1, z);

            if (ul && lr && !ur && !ll) {
                if (Math.random() < 0.5)
                    world.tiles.set(x+1, y, z, world.tile_floor);
                else
                    world.tiles.set(x, y+1, z, world.tile_floor);
            } else if (ll && ur && !ul && !lr) {
                if (Math.random() < 0.5)
                    world.tiles.set(x, y, z, world.tile_floor);
                else
                    world.tiles.set(x+1, y+1, z, world.tile_floor);
            }
        }
    }


    private function addStairs():Void {
        for (z in 0 ... world.heights.depth-1) {
            var count = 0;
            while (count < 20) {
                var x = Math.floor(Math.random() * world.heights.width);
                var y = Math.floor(Math.random() * world.heights.height);

                if (world.tiles.get(x, y, z) != world.tile_floor)
                    continue;

                if (world.tiles.get(x, y, z+1) != world.tile_floor)
                    continue;

                count++;
                world.tiles.set(x, y, z, world.tile_stairs_down);
                world.tiles.set(x, y, z+1, world.tile_stairs_up);
            }
        }
    }
}
