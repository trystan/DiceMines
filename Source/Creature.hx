package;

import knave.Shadowcaster;

class Creature {
    public var world:PlayScreen;
    public var x:Int;
    public var y:Int;
    public var z:Int;
    public var glyph:String;

    public var hp:Int = 20;
    public var maxHp:Int = 20;
    public var isAlive:Bool = true;

    public var accuracyStat:String;
    public var damageStat:String;
    public var evasionStat:String;
    public var resistanceStat:String;

    public var light:Shadowcaster;

    public function new(glyph:String, x:Int, y:Int, z:Int) {
        this.glyph = glyph;
        this.x = x;
        this.y = y;
        this.z = z;

        accuracyStat = "2d2+2";
        damageStat = "2d2+2";
        evasionStat = "2d2+2";
        resistanceStat = "2d2+2";
    }

    public function doAi():Void {
        var mx = Math.floor(Math.random() * 3) - 1;
        var my = Math.floor(Math.random() * 3) - 1;

        if (world.isEmptySpace(x+mx, y+my, z))
            return;
        
        move(mx, my, 0);
    }

    public function move(mx:Int, my:Int, mz:Int):Void {
        if (mx==0 && my==0 && mz==0)
            return;

        var other = world.getCreature(x+mx, y+my, z+mz);
        if (other != null)
            attack(other);
        else if (!world.blocksMovement(x + mx, y + my, z)) {
            x += mx;
            y += my;
            
            if (mz == -1 && world.canGoUp(x, y, z)
             || mz == 1 && world.canGoDown(x, y, z))
                z += mz;
        }
    }

    public function attack(other:Creature):Void {
        if (Dice.roll(accuracyStat) < Dice.roll(other.evasionStat))
            return;

        other.hp -= Math.floor(Math.max(0, Dice.roll(damageStat) - Dice.roll(other.resistanceStat)));
        if (other.hp < 1)
            other.isAlive = false;
    }

    public function update():Void {
        while (world.isEmptySpace(x, y, z))
            z++;

        if (light == null)
            return;

        light.update(x, y, 25, function (vx:Int, vy:Int):Bool {
            return world.blocksVision(vx, vy, z);
        });
    }
}
