package;

import StringTools;
import knave.*;

class PlayScreen extends Screen {
    public var world:World;
    public var player:Creature;
    private var isAnimating:Bool = false;
    private var updateAfterAnimating:Bool = false;

    public function new(world:World) {
        super();

        this.world = world;
        this.player = world.player;

        world.playScreen = this;

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
        on("v", enter, new CharacterInfoScreen(this, world.heroParty));
        on("keypress", doAction);
        on("tick", animate);
        on("draw", draw);
    }

    private function move(by: { x:Int, y:Int, z:Int } ):Void {
        if (isAnimating)
            return;

        player.move(by.x, by.y, by.z);

        if (player.z < 0)
            switchTo(new EndScreen(this));
        else
            update();
    }

    public function update():Void {
        world.update();

        if (!player.isAlive)
            switchTo(new EndScreen(this));
        else
            rl.trigger("redraw");
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
        for (c in world.creatures) {
            if (c.animatePath != null && c.animatePath.length > 0)
                inAir.push(c);
        }
        if (world.projectiles.length == 0 && inAir.length == 0) {
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
            if (world.blocksMovement(p.x, p.y, c.z)) {
                c.animatePath = null;
            } else {
                var other = world.getCreature(p.x, p.y, c.z);
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
        for (p in world.projectiles) {
            p.update();
            var c = world.getCreature(p.x, p.y, p.z);
            if (c != null)
                c.takeRangedAttack(p);
            else if (world.blocksMovement(p.x, p.y, p.z))
                p.isDone = true;
            else if (!p.isDone)
                stillAlive.push(p);
        }
        world.projectiles = stillAlive;
        rl.trigger("redraw");
    }

    public var viewLeft:Int;
    public var viewTop:Int;
    public function draw(display:AsciiDisplay):Void {
        display.clear();

        var playerColor = world.player.color.lerp(new Color(250,250,250), 0.5);

        var vx = Math.floor(player.x - display.widthInCharacters / 2);
        var vy  = Math.floor(player.y - display.heightInCharacters / 2);
        viewLeft = vx;
        viewTop = vy;
        for (sx in 0 ... display.widthInCharacters)
        for (sy in 0 ... display.heightInCharacters) {
            var x = sx + vx;
            var y = sy + vy;
            if (isVisible(x, y, player.z)) {
                var g = getGraphic(x, y, player.z);

                var item = world.getItem(x, y, player.z);
                if (item != null)
                    display.write(item.glyph, sx, sy, item.color.toInt(), g.bg.toInt());
                else
                    display.write(g.glyph, sx, sy, g.fg.toInt(), g.bg.toInt());
            }
        }

        for (c in world.creatures) {
            if (c.z != player.z || !isVisible(c.x, c.y, c.z) || (c != player && !c.isVisible()))
                continue;

            var g = getGraphic(c.x, c.y, c.z);
            var fg = getCreatureColor(c);
            if (c.isHero())
                fg = c.color;
            if (c == world.player)
                fg = playerColor;
            var bg = g.bg;
            if (c.fearCounter > 0)
                bg = Color.hsv(60, 50, 50);
            if (c.sleepCounter > 0)
                bg = Color.hsv(180, 20, 50);
            display.write(c.glyph, c.x - vx, c.y - vy, fg.toInt(), bg.toInt());
        }

        for (p in world.projectiles) {
            if (p.z != player.z || !player.light.isLit(p.x, p.y))
                continue;

            var g = getGraphic(p.x, p.y, p.z);
            display.write(p.glyph, p.x - vx, p.y - vy, p.color, g.bg.toInt());
        }

        var y = 1;
        var fg = new Color(200, 200, 200).toInt();
        var bg = new Color(0, 0, 0).toInt();

        for (c in world.heroParty) {
            if (!c.isAlive && c != player)
                continue;

            var labelColor = c == world.player ? playerColor.toInt() : c.color.toInt();
            var label = '${c.fullName} ${c.hp}/${c.maxHp} (lvl ${c.z})';
            display.write(label, display.widthInCharacters - label.length - 1, y++, labelColor, bg);
            var characterMelee = c.meleeWeapon == null ? "no sword" : c.meleeWeapon.name;
            display.write(characterMelee, display.widthInCharacters - characterMelee.length - 1, y++, fg, bg);

            var characterRanged = c.rangedWeapon == null ? "no bow" : c.rangedWeapon.name;
            display.write(characterRanged, display.widthInCharacters - characterRanged.length - 1, y++, fg, bg);

            var characterArmor = c.armor == null ? "no armor" : c.armor.name;
            display.write(characterArmor, display.widthInCharacters - characterArmor.length - 1, y++, fg, bg);
            y++;
        }

        var x = 1;
        y = 1;
        display.write('[v]iew party', x, y++, fg, bg);
        var item = world.getItem(player.x, player.y, player.z);
        if (item == null)
            y++;
        else
            display.write('[g]et ${item.name}', x, y++, fg, bg);

        if (player.rangedWeapon != null)
            display.write('[f]ire ${player.rangedWeapon.name}', x, y++, fg, bg);

        for (ability in player.abilities)
            display.write("[" + ability.name.charAt(0) + "]" + ability.name.substr(1), x, y++, fg, bg);

        var y = display.heightInCharacters - world.messages.length;
        for (message in world.messages)
            display.writeCenter(message, y++, fg, bg);

        if (!isAnimating) {
            while (world.messages.length > 3)
                world.messages.shift();
        }

        display.update();
    }

    private function isVisible(x:Int, y:Int, z:Int):Bool {
        for (c in world.heroParty) {
            if ((c.isAlive || c == player) && c.z == player.z && c.light.isLit(x, y))
                return true;
        }
        return false;
    }

    private function getCreatureColor(creature:Creature):Color {
        var percent = 1.0 * creature.hp / creature.maxHp;
        return Color.hsv(0, 90, 90).lerp(Color.hsv(90, 90, 90), percent);
    }

    private function getGraphic(x:Int, y:Int, z:Int): { glyph:String, fg:Color, bg:Color } {
        if (!world.tiles.isInBounds(x, y, z))
            return { glyph: " ", fg: new Color(200,200,200), bg: new Color(0,0,0) };

        var tile = world.tiles.get(x, y, z);
        var h = (world.heights.get(x, y, z) - world.floorHeight) / 0.2 * 5;
        var glyph = String.fromCharCode(tile);
        var fg = Color.hsv(25 - z, 25, 40 + h);
        var bg = Color.hsv(25 - z, 25, 10 + h);

        if (tile == world.tile_empty) {
            bg = Color.hsv(220, 50, 5);
        } else if (tile == world.tile_lava) {
            glyph = String.fromCharCode(247);
            fg = Color.hsv(Math.random() * 10, 80 + Math.random() * 2, 50);
            bg = Color.hsv(Math.random() *  5, 80 + Math.random() * 2, 40);
        } else if (tile == world.tile_water) {
            glyph = String.fromCharCode(247);
            fg = Color.hsv(220 + Math.random() * 10, 30 + Math.random() * 2, 20);
            bg = Color.hsv(220 + Math.random() * 10, 25 + Math.random() * 2, 15);
        } else if (tile == world.tile_bridge) {
            fg = Color.hsv(60, 33, 12);
            bg = Color.hsv(60, 33,  8);
        }

        if (world.isOnFire(x, y, z)) {
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
}
