package;

import StringTools;
import knave.*;

class PlayScreen extends Screen {
    private var tiles:Grid<Int>;

    private var tile_floor:Int = 250;
    private var tile_wall:Int = 177;

    public function new() {
        super();
        worldgen(Math.floor(1024 / 12), Math.floor(720/ 12));E 
        on("draw", draw);
    }
    
    private function draw(display:AsciiDisplay):Void {
        display.clear();

        for (x in 0 ... tiles.width)
        for (y in 0 ... tiles.height) {
            var glyph = String.fromCharCode(tiles.get(x, y));
            display.write(glyph, x, y);
        }

        display.update();
    }

    private function worldgen(w:Int, h:Int):Void {
        tiles = new Grid<Int>(w, h);

        for (x in 0 ... w)
        for (y in 0 ... h)
            tiles.set(x, y, Math.random() < 0.80 ? tile_floor : tile_wall);
    }
}
