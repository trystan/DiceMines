package;

import StringTools;
import knave.*;

class PlayScreen extends Screen {
    private var heights:Grid3<Float>;
    private var tiles:Grid3<Int>;

    private var tile_floor:Int = 250;
    private var tile_wall:Int = 177;
    private var tile_empty:Int = 0;

    private var pz:Int = 0;

    public function new() {
        super();
        worldgen(Math.floor(1024 / 12), Math.floor(720/ 12), 20);

        on("<", move, { x:0,  y:0,  z:-1 });
        on(">", move, { x:0,  y:0,  z:1  });
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
            var glyph = String.fromCharCode(tiles.get(x, y, pz));
            display.write(glyph, x, y);
        }

        display.update();
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

        makeTiles();
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

    private function makeTiles():Void {
        tiles = new Grid3<Int>(heights.width, heights.height, heights.depth);
        var floorHeight = 0.45;
        var wallHeight = 0.65;

        for (x in 0 ... heights.width)
        for (y in 0 ... heights.height)
        for (z in 0 ... heights.depth) {
            var height = heights.get(x, y, z);
            tiles.set(x, y, z, height < floorHeight ? tile_empty : (height > wallHeight ? tile_wall : tile_floor));
        }
    }
}
