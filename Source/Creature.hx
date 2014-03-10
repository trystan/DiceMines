package;

import knave.IntPoint;
import knave.Bresenham;
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
    public var offBalanceCounters:Array<Int>;
    public var wounds:Array<{ countdown:Int, stat:String, modifier:String }>;
    public var knockbackPath:Array<IntPoint>;

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

        dice = [0, 0, 0, 0, 0, 0, 0, 0, 0];
        offBalanceCounters = new Array<Int>();
        wounds = new Array<{ countdown:Int, stat:String, modifier:String }>();

        accuracyStat = "3d3+3";
        damageStat = "3d3+3";
        evasionStat = "3d3+3";
        resistanceStat = "3d3+3";
    }

    public function loseBalance(amount:Int):Void {
        offBalanceCounters.push(3);
        accuracyStat = Dice.add(accuracyStat, "-2d2+0");
        damageStat = Dice.add(damageStat, "-2d2+0");
        evasionStat = Dice.add(evasionStat, "-2d2+0");
        resistanceStat = Dice.add(resistanceStat, "-2d2+0");
    }

    public function recoverBalance():Void {
        var newCounters = new Array<Int>();
        for (c in offBalanceCounters) {
            if (c == 0) {
                accuracyStat = Dice.add(accuracyStat, "2d2+0");
                damageStat = Dice.add(damageStat, "2d2+0");
                evasionStat = Dice.add(evasionStat, "2d2+0");
                resistanceStat = Dice.add(resistanceStat, "2d2+0");
            } else {
                newCounters.push(c-1);
            }
        }
        offBalanceCounters = newCounters;
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
            if (evasion > accuracy * 2)
                world.addMessage('$fullName critically evades ${projectile.owner.fullName} by ${evasion - accuracy}');
            else
                world.addMessage('$fullName evades ${projectile.owner.fullName} by ${evasion - accuracy}');
            return;
        }

        var isCriticalHit = accuracy > evasion * 2;
        if (isCriticalHit) takeCriticalHit();
        var hitType = isCriticalHit ? "criticaly hits" : "hits";

        var damage = Dice.roll(projectile.damageStat);

        var effectiveResistanceStat = evasionStat;
        if (meleeWeapon != null) effectiveResistanceStat = Dice.add(effectiveResistanceStat, meleeWeapon.resistanceStat);
        if (armor != null) effectiveResistanceStat = Dice.add(effectiveResistanceStat, armor.resistanceStat);
        var resistance = Dice.roll(effectiveResistanceStat);

        var actualDamage = Math.floor(Math.max(0, damage - resistance));
        if (damage == resistance)
            actualDamage = 1;

        if (actualDamage == 0)
            if (resistance > damage * 2)
                world.addMessage('$fullName critically resisted ${projectile.owner.fullName} by ${resistance - damage}');
            else
                world.addMessage('$fullName resisted ${projectile.owner.fullName} by ${resistance - damage}');
        else if (actualDamage >= hp)
            if (damage > resistance * 2)
                world.addMessage('${projectile.owner.fullName} $hitType $fullName for $actualDamage critical damage and kills');
            else
                world.addMessage('${projectile.owner.fullName} $hitType $fullName for $actualDamage damage and kills');
        else
            if (damage > resistance * 2)
                world.addMessage('${projectile.owner.fullName} $hitType $fullName for $actualDamage critical damage');
            else
                world.addMessage('${projectile.owner.fullName} $hitType $fullName for $actualDamage damage');

        if (damage > resistance * 2)
            knockback(projectile.owner, resistance - damage);

        takeDamage(actualDamage, projectile.owner);
    }

    public function knockback(attacker:Creature, amount:Int):Void {
        amount = Math.floor(Math.abs(amount));

        var dx = x - attacker.x + Math.random() - 0.5;
        var dy = y - attacker.y + Math.random() - 0.5;

        dx *= amount;
        dy *= amount;

        knockbackPath = Bresenham.line(x, y, x + Math.floor(dx), y + Math.floor(dy)).points;
        while (knockbackPath.length > amount)
            knockbackPath.pop();
    }

    public function takeCriticalHit():Void {
        var stats = ["accuracy", "evasion", "damage", "resistance"];
        var modifiers = ["-1d0+0", "-1d0+0", "-0d1+0", "-0d1+0", "-1d1+0"];


        var wound = { countdown: 100, stat: stats[Math.floor(Math.random() * stats.length)], modifier: modifiers[Math.floor(Math.random() * modifiers.length)] };
        switch (wound.stat) {
            case "accuracy": accuracyStat = Dice.add(accuracyStat, wound.modifier);
            case "evasion": evasionStat = Dice.add(evasionStat, wound.modifier);
            case "damage": damageStat = Dice.add(damageStat, wound.modifier);
            case "resistance": resistanceStat = Dice.add(resistanceStat, wound.modifier);
        }
        wounds.push(wound);
    }

    public function recoverFromWounds():Void {
        var newWounds = new Array<{ countdown:Int, stat:String, modifier:String }>();
        for (w in wounds) {
                switch (w.stat) {
                    case "accuracy": accuracyStat = Dice.subtract(accuracyStat, w.modifier);
                    case "evasion": evasionStat = Dice.subtract(evasionStat, w.modifier);
                    case "damage": damageStat = Dice.subtract(damageStat, w.modifier);
                    case "resistance": resistanceStat = Dice.subtract(resistanceStat, w.modifier);
                }
            if (w.countdown == 0) {
            } else {
                w.countdown--;
                newWounds.push(w);
            }
        }
        wounds = newWounds;
    }

    public function takeDamage(amount:Int, attacker:Creature):Void {
        hp -= amount;

        if (hp < 1)
            attacker.gainDice(3);
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
            if (evasion > accuracy * 2) {
                loseBalance(evasion - accuracy);
                world.addMessage('${other.fullName} critically evades $fullName by ${evasion - accuracy}, leaving ${getPronoun()} off balance');
            } else
                world.addMessage('${other.fullName} evades $fullName by ${evasion - accuracy}');
            return;
        }

        var isCriticalHit = accuracy > evasion * 2;
        if (isCriticalHit) takeCriticalHit();
        var hitType = isCriticalHit ? "criticaly hits" : "hits";

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
            if (resistance > damage * 2) {
                world.addMessage('${other.fullName} critically resisted $fullName by ${resistance - damage}, hurting $fullName by that much');
                takeDamage(resistance - damage, other);
            } else
                world.addMessage('${other.fullName} resisted $fullName by ${resistance - damage}');
        else if (actualDamage >= other.hp)
            if (damage > resistance * 2)
                world.addMessage('$fullName $hitType ${other.fullName} for $actualDamage critical damage and kills ${getPronoun()}');
            else
                world.addMessage('$fullName $hitType ${other.fullName} for $actualDamage damage and kills ${getPronoun()}');
        else
            if (damage > resistance * 2)
                world.addMessage('$fullName $hitType ${other.fullName} for $actualDamage critical damage');
            else
                world.addMessage('$fullName $hitType ${other.fullName} for $actualDamage damage');

        if (damage > resistance * 2)
            other.knockback(this, resistance - damage);

        other.takeDamage(actualDamage, this);
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
        recoverBalance();
        recoverFromWounds();

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
