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

    public var gender:String;
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
    public var meleeWeapon:Item;
    public var armor:Item;

    public function new(glyph:String, name:String, x:Int, y:Int, z:Int, gender:String = null) {
        this.glyph = glyph;
        this.name = name;
        this.fullName = glyph == "@" ? name : ("the " + name);
        this.gender = gender == null ? (Math.random() < 0.5 ? "m" : "f") : gender;
        this.x = x;
        this.y = y;
        this.z = z;

        this.dice = [0, 0, 0, 0, 0, 0, 0, 0, 0];

        accuracyStat = "3d3+3";
        damageStat = "3d3+3";
        evasionStat = "3d3+3";
        resistanceStat = "3d3+3";
    }

    public function getPronoun():String {
        switch (gender) {
            case "m": return "him";
            case "f": return "her";
            default: return "it";
        }
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
                if (rangedWeapon != null)
                    world.addItem(rangedWeapon, x, y, z);
                rangedWeapon = item;
                world.addMessage('$name weilds a ${item.describe()}');
            } else if (item.type == "melee") {
                if (meleeWeapon != null)
                    world.addItem(meleeWeapon, x, y, z);
                meleeWeapon = item;
                world.addMessage('$name weilds a ${item.describe()}');
            } else if (item.type == "armor") {
                if (armor != null)
                    world.addItem(armor, x, y, z);
                armor = item;
                world.addMessage('$name wears a ${item.describe()}');
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
        
        p.accuracyStat = accuracyStat;
        if (rangedWeapon != null) p.accuracyStat = Dice.add(p.accuracyStat, rangedWeapon.accuracyStat);
        if (armor != null) p.accuracyStat = Dice.add(p.accuracyStat, armor.accuracyStat);

        p.damageStat = damageStat;
        if (rangedWeapon != null) p.damageStat = Dice.add(p.damageStat, rangedWeapon.damageStat);
        if (armor != null) p.damageStat = Dice.add(p.damageStat, armor.damageStat);

        world.addProjectile(p);
    }

    public function takeRangedAttack(projectile:Projectile):Void {
        var accuracy = Dice.roll(projectile.accuracyStat);

        var effectiveEvasionStat = evasionStat;
        if (meleeWeapon != null) effectiveEvasionStat = Dice.add(effectiveEvasionStat, meleeWeapon.evasionStat);
        if (armor != null) effectiveEvasionStat = Dice.add(effectiveEvasionStat, armor.evasionStat);
        var evasion = Dice.roll(effectiveEvasionStat);

        if (accuracy < evasion) {
            world.addMessage('${projectile.owner.fullName} misses ${fullName} by ${evasion - accuracy} (${projectile.accuracyStat} accuracy vs $effectiveEvasionStat evasion)');
            return;
        }

        var damage = Dice.roll(projectile.damageStat);

        var effectiveResistanceStat = evasionStat;
        if (meleeWeapon != null) effectiveResistanceStat = Dice.add(effectiveResistanceStat, meleeWeapon.resistanceStat);
        if (armor != null) effectiveResistanceStat = Dice.add(effectiveResistanceStat, armor.resistanceStat);
        var resistance = Dice.roll(effectiveResistanceStat);

        var actualDamage = Math.floor(Math.max(0, damage - resistance));

        if (actualDamage == 0)
            world.addMessage('${fullName} deflected ${projectile.owner.fullName} by ${resistance - damage} ($effectiveResistanceStat resistance vs ${projectile.damageStat} damage)');
        else if (actualDamage >= hp)
            world.addMessage('${projectile.owner.fullName} hit $fullName for $actualDamage damage and kills ${getPronoun()} (${projectile.damageStat} damge vs $effectiveResistanceStat resistance)');
        else
            world.addMessage('${projectile.owner.fullName} hit $fullName for $actualDamage damage (${projectile.damageStat} damge vs $effectiveResistanceStat resistance)');

        hp -= actualDamage;

        if (hp < 1)
            projectile.owner.gainDice(3);
    }

    public function attack(other:Creature):Void {
        if (glyph != "@" && other.glyph != "@")
            return;

        var effectiveAccuracyStat = accuracyStat;
        if (meleeWeapon != null) effectiveAccuracyStat = Dice.add(effectiveAccuracyStat, meleeWeapon.accuracyStat);
        if (armor != null) effectiveAccuracyStat = Dice.add(effectiveAccuracyStat, armor.accuracyStat);
        var accuracy = Dice.roll(effectiveAccuracyStat);

        var effectiveEvasionStat = other.evasionStat;
        if (other.meleeWeapon != null) effectiveEvasionStat = Dice.add(effectiveEvasionStat, other.meleeWeapon.evasionStat);
        if (other.armor != null) effectiveEvasionStat = Dice.add(effectiveEvasionStat, other.armor.evasionStat);
        var evasion = Dice.roll(effectiveEvasionStat);

        if (accuracy < evasion) {
            world.addMessage('$fullName misses ${other.fullName} by ${evasion - accuracy} ($effectiveAccuracyStat accuracy vs ${effectiveEvasionStat} evasion)');
            return;
        }

        var effectiveDamageStat = damageStat;
        if (meleeWeapon != null) effectiveDamageStat = Dice.add(effectiveDamageStat, meleeWeapon.damageStat);
        if (armor != null) effectiveDamageStat = Dice.add(effectiveDamageStat, armor.damageStat);
        var damage = Dice.roll(effectiveDamageStat);

        var effectiveResistanceStat = other.resistanceStat;
        if (other.meleeWeapon != null) effectiveResistanceStat = Dice.add(effectiveResistanceStat, other.meleeWeapon.resistanceStat);
        if (other.armor != null) effectiveResistanceStat = Dice.add(effectiveResistanceStat, other.armor.resistanceStat);
        var resistance = Dice.roll(effectiveResistanceStat);

        var actualDamage = Math.floor(Math.max(0, damage - resistance));
        if (damage == resistance)
            actualDamage = 1;

        if (actualDamage == 0)
            world.addMessage('${other.fullName} deflected $fullName by ${resistance - damage} ($effectiveResistanceStat resistance vs $effectiveDamageStat damage)');
        else if (actualDamage >= other.hp)
            world.addMessage('$fullName hit ${other.fullName} for $actualDamage damage and kills ${getPronoun()} ($effectiveDamageStat damge vs $effectiveResistanceStat resistance)');
        else
            world.addMessage('$fullName hit ${other.fullName} for $actualDamage damage ($effectiveDamageStat damge vs $effectiveResistanceStat resistance)');

        other.hp -= actualDamage;

        if (other.hp < 1)
            gainDice(3);
    }

    public function gainDice(amount:Int):Void {
        var gains = new Array<String>();
        for (i in 0 ... amount) {
            var sides = Math.floor(Math.min(Dice.roll("1d9+0"), Dice.roll("1d9+0")));
            dice[sides - 1] += 1;
            gains.push('1d$sides');
        }
        world.addMessage('$fullName gains ${gains.join(", ")}');
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
