package;

import knave.*;

class AimScreen extends Screen {
    private var world:PlayScreen;
    private var player:Creature;
    private var callbackFunction:Int -> Int -> Void;
    private var targetX:Int;
    private var targetY:Int;
    private var maxDistance:Int;
    private var isOk:Bool = true;

    public function new(world:PlayScreen, player:Creature, maxDistance:Int, callbackFunction: Int -> Int -> Void) {
        super();
        this.world = world;
        this.player = player;
        this.maxDistance = maxDistance;
        this.callbackFunction = callbackFunction;
        targetX = player.x;
        targetY = player.y;

        on("left", move, { x:-1, y:0 });
        on("right", move, { x:1, y:0 });
        on("up", move, { x:0, y:-1 });
        on("down", move, { x:0, y:1 });
        on(".", move, { x:0,  y:0 });
        on("escape", exit);
        on("enter", fire);
        on("f", fire);
        on("draw", draw);
    }

    private function move(by: { x:Int, y:Int } ):Void {
        targetX += by.x;
        targetY += by.y;
        rl.trigger("redraw");
    }

    private function fire():Void {
        exit();
        if (isOk)
            callbackFunction(targetX, targetY);
        rl.trigger("redraw");
    }
    
    private function draw(display:AsciiDisplay):Void {
        world.draw(display);

        var fg = new Color(250, 250, 250).toInt();
        var glyph = String.fromCharCode(250);
        var points = Bresenham.line(player.x, player.y, targetX, targetY).points;
        if (points.length > 0)
            points.shift();
        isOk = points.length <= maxDistance;

        if (!isOk)
            fg = new Color(200, 0, 0).toInt();

        for (p in points)
            display.write(glyph, p.x, p.y, fg);

        display.write("x", targetX, targetY, fg);
        display.update();
    }
}
