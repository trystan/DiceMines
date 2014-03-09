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
    private var tile_bridge:Int = 240;

    private var pz:Int = 0;

    public function new() {
        super();
        worldgen(Math.floor(1024 / 12), Math.floor(720/ 12), 20);

        on("<", move, { x:0,  y:0,  z:-1 });
        on(">", move, { x:0,  y:0,  z:1  });
        on(".", move, { x:0,  y:0,  z:0  });
        on("draw", draw);
    }

    private function move(by: { x:Int, y:Int, z:Int } ):Void {
        pz += by.z;
        rl.trigger("redraw");
    }
    
    private function draw(display:AsciiDisplay):Void {
        display.clear();

        for (x in 0 ... tiles.width)
        for (y in 0 ... tiles.height) {
            var g = getGraphic(x, y, pz);
            display.write(g.glyph, x, y, g.fg.toInt(), g.bg.toInt());
        }

        display.update();
    }

    private function getGraphic(x:Int, y:Int, z:Int): { glyph:String, fg:Color, bg:Color } {
        var tile = tiles.get(x, y, z);
        var h = (heights.get(x, y, z) - floorHeight) / 0.2 * 10;
        var glyph = String.fromCharCode(tile);
        var fg = Color.hsv(25 - z, 25, 50 + h);
        var bg = Color.hsv(25 - z, 25,  5 + h);

        if (tile == tile_empty) {
            if (z == tiles.depth - 1) {
                glyph = "=";
                fg = Color.hsv(220, 35 + Math.random() * 10, 25);
                bg = Color.hsv(220, 30 + Math.random() * 10, 20);
            } else {
                bg = Color.hsv(220, 50, 5);
            }
        } else if (tile == tile_bridge) {
            fg = Color.hsv(45, 25, 12);
            bg = Color.hsv(45, 25,  8);
        }

        if ((x+y) % 2 == 0) {
            fg = fg.darker();
            bg = bg.darker();
        }

        return { glyph: glyph, fg: fg, bg: bg };
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
                var amount = r - Math.sqrt(dist) * mult;
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
            var count = 1;
            for (ox in -r ... r+1)
            for (oy in -r ... r+1) {
                if (!heights.isInBounds(x+ox, y+oy, z))
                    continue;
                value += heights.get(x+ox, y+oy, z);
                count += 1;
            }
            heights2.set(x, y, z, value / count);
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
        }
    }

    private function addBridges():Void {
        for (z in 0 ... heights.depth) {
            for (i in 0 ... 10) {
                var cx = Math.floor(Math.random() * heights.width);
                var cy = Math.floor(Math.random() * heights.height);
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
}
