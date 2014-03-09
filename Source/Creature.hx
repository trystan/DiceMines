package;

import knave.Shadowcaster;

class Creature {
    public var world:PlayScreen;
    public var x:Int;
    public var y:Int;
    public var z:Int;
    public var glyph:String;
    public var name:String;

    public var hp:Int = 20;
    public var maxHp:Int = 20;
    public var isAlive:Bool = true;

    public var accuracyStat:String;
    public var damageStat:String;
    public var evasionStat:String;
    public var resistanceStat:String;

    public var light:Shadowcaster;

    public function new(glyph:String, name:String, x:Int, y:Int, z:Int) {
        this.glyph = glyph;
        this.name = name;
        this.x = x;
        this.y = y;
        this.z = z;

        accuracyStat = "3d3+3";
        damageStat = "3d3+3";
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
        if (other.glyph == glyph)
            return;

        var accuracy = Dice.roll(accuracyStat);
        var evasion = Dice.roll(other.evasionStat);

        if (accuracy < evasion) {
            world.addMessage('$name misses ${other.name} ($accuracyStat accuracy vs $evasionStat evasion)');
            return;
        }

        var damage = Dice.roll(damageStat);
        var resistance = Dice.roll(other.resistanceStat);
        var actualDamage = Math.floor(Math.max(0, damage - resistance));

        if (actualDamage == 0)
            world.addMessage('${other.name} deflected $name (${other.resistanceStat} resistance vs $damageStat damage)');
        else if (actualDamage >= other.hp)
            world.addMessage('$name hit ${other.name} for $actualDamage damage and kills it ($damageStat damge vs ${other.resistanceStat} resistance)');
        else
            world.addMessage('$name hit ${other.name} for $actualDamage damage ($damageStat damge vs ${other.resistanceStat} resistance)');

        other.hp -= actualDamage;
    }

    public function update():Void {
        var fallDistance = 0;
        while (world.isEmptySpace(x, y, z)) {
            z++;
            fallDistance++;
        }

        if (fallDistance > 0) {
            world.addMessage('$name falls $fallDistance ${fallDistance == 1 ? "floor" : "floors"}');
            hp -= fallDistance * 2;
        }

        if (hp < 1)
            isAlive = false;

        if (light == null)
            return;

        light.update(x, y, 25, function (vx:Int, vy:Int):Bool {
            return world.blocksVision(vx, vy, z);
        });
    }
}
