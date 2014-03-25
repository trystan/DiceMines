package;

import knave.*;

class AimScreen extends Screen {
    private var world:World;
    private var player:Creature;
    private var callbackFunction:Int -> Int -> Void;
    private var targetX:Int;
    private var targetY:Int;
    private var maxDistance:Int;
    private var isOk:Bool = true;
    private var prompt:String;
    private var radius:Int;

    public function new(player:Creature, maxDistance:Int, callbackFunction: Int -> Int -> Void, prompt:String = null, radius:Int = 0) {
        super();
        this.world = player.world;
        this.player = player;
        this.maxDistance = maxDistance;
        this.callbackFunction = callbackFunction;
        this.prompt = prompt;
        this.radius = radius;

        targetX = player.x;
        targetY = player.y;

        on("left", move, { x:-1, y:0 });
        on("right", move, { x:1, y:0 });
        on("up", move, { x:0, y:-1 });
        on("down", move, { x:0, y:1 });
        on("up left", move, { x:-1, y:-1 });
        on("up right", move, { x:1, y:-1 });
        on("down left", move, { x:-1, y:1 });
        on("down right", move, { x:1, y:1 });
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
        if (isOk)
            callbackFunction(targetX, targetY);
        exit();
        rl.trigger("redraw");
    }
    
    private function draw(display:AsciiDisplay):Void {
        world.playScreen.draw(display);
        var fg = new Color(250, 250, 250).toInt();

        var glyph = String.fromCharCode(250);
        var points = Bresenham.line(player.x, player.y, targetX, targetY).points;
        if (points.length > 0)
            points.shift();
        isOk = points.length <= maxDistance;

        if (!isOk)
            fg = new Color(200, 0, 0).toInt();

        var vx = world.playScreen.viewLeft;
        var vy = world.playScreen.viewTop;
        for (p in points)
            display.write(glyph, p.x - vx, p.y - vy, fg);

        if (radius == 0) {
            display.write("x", targetX - vx, targetY - vy, fg);
        } else {
            for (rx in -radius ... radius+1)
            for (ry in -radius ... radius+1) {
                if (rx*rx + ry*ry > radius*radius)
                    continue;
                display.write("x", targetX - vx + rx, targetY - vy + ry, fg);
            }
            display.write("x", targetX - vx, targetY - vy, fg);
        }

        display.update();
    }
}
