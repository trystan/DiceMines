package;

import knave.Shadowcaster;

class Creature {
    public var world:PlayScreen;
    public var x:Int;
    public var y:Int;
    public var z:Int;
    public var glyph:String;
    public var name:String;
    public var fullName:String;

    public var hp:Int = 20;
    public var maxHp:Int = 20;
    public var isAlive:Bool = true;

    public var accuracyStat:String;
    public var damageStat:String;
    public var evasionStat:String;
    public var resistanceStat:String;

    public var light:Shadowcaster;
    public var dice:Array<Int>;

    public var rangedWeapon:Item;

    public function new(glyph:String, name:String, x:Int, y:Int, z:Int) {
        this.glyph = glyph;
        this.name = name;
        this.fullName = glyph == "@" ? name : ("the " + name);
        this.x = x;
        this.y = y;
        this.z = z;

        this.dice = [0, 0, 0, 0, 0, 0, 0, 0, 0];

        accuracyStat = "3d3+3";
        damageStat = "3d3+3";
        evasionStat = "3d3+3";
        resistanceStat = "3d3+3";
    }

    public function doAi():Void {
        var mx = Math.floor(Math.random() * 3) - 1;
        var my = Math.floor(Math.random() * 3) - 1;

        if (world.isEmptySpace(x+mx, y+my, z))
            return;
        
        move(mx, my, 0);
    }

    public function pickupItem():Void {
        var item = world.removeItem(x, y, z);
        if (item == null) {
            world.addMessage('$name grabs at the ground');
        } else {
            if (item.type == "ranged") {
                if (rangedWeapon == null) {
                    world.addMessage('$name grabs a ${item.name} off the ground');
                } else {
                    world.addItem(rangedWeapon, x, y, z);
                    world.addMessage('$name swaps his ${rangedWeapon.name} for the ${item.name} on the ground');
                }
                rangedWeapon = item;
            }
        }
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

    public function rangedAttack(tx:Int, ty:Int):Void {
        var p = new Projectile(x, y, z, tx, ty, this);
        world.addProjectile(p);
    }

    public function takeRangedAttack(projectile:Projectile):Void {
        var accuracy = Dice.roll(projectile.accuracyStat);
        var evasion = Dice.roll(evasionStat);

        if (accuracy < evasion) {
            world.addMessage('${projectile.owner.fullName} misses ${fullName} (${projectile.accuracyStat} accuracy vs $evasionStat evasion)');
            return;
        }

        var damage = Dice.roll(projectile.damageStat);
        var resistance = Dice.roll(resistanceStat);
        var actualDamage = Math.floor(Math.max(0, damage - resistance));

        if (actualDamage == 0)
            world.addMessage('${fullName} deflected ${projectile.owner.fullName} (${resistanceStat} resistance vs ${projectile.damageStat} damage)');
        else if (actualDamage >= hp)
            world.addMessage('${projectile.owner.fullName} hit $fullName for $actualDamage damage and kills it (${projectile.damageStat} damge vs $resistanceStat resistance)');
        else
            world.addMessage('${projectile.owner.fullName} hit $fullName for $actualDamage damage (${projectile.damageStat} damge vs $resistanceStat resistance)');

        hp -= actualDamage;

        if (hp < 1)
            projectile.owner.gainDice(3);
    }

    public function attack(other:Creature):Void {
        if (glyph != "@" && other.glyph != "@")
            return;

        var accuracy = Dice.roll(accuracyStat);
        var evasion = Dice.roll(other.evasionStat);

        if (accuracy < evasion) {
            world.addMessage('$fullName misses ${other.fullName} ($accuracyStat accuracy vs ${other.evasionStat} evasion)');
            return;
        }

        var damage = Dice.roll(damageStat);
        var resistance = Dice.roll(other.resistanceStat);
        var actualDamage = Math.floor(Math.max(0, damage - resistance));

        if (actualDamage == 0)
            world.addMessage('${other.fullName} deflected $fullName (${other.resistanceStat} resistance vs $damageStat damage)');
        else if (actualDamage >= other.hp)
            world.addMessage('$fullName hit ${other.fullName} for $actualDamage damage and kills it ($damageStat damge vs ${other.resistanceStat} resistance)');
        else
            world.addMessage('$fullName hit ${other.fullName} for $actualDamage damage ($damageStat damge vs ${other.resistanceStat} resistance)');

        other.hp -= actualDamage;

        if (other.hp < 1)
            gainDice(3);
    }

    public function gainDice(amount:Int):Void {
        for (i in 0 ... amount) {
            var sides = Math.floor(Math.min(Dice.roll("1d9+0"), Dice.roll("1d9+0")));
            world.addMessage('$fullName gains a d$sides');
            dice[sides - 1] += 1;
        }
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
