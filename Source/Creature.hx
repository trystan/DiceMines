package;

import knave.Color;
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
    public var ai:NpcAi;

    public var gender:String;
    public var hp:Int = 30;
    public var maxHp:Int = 30;
    public var isAlive:Bool = true;

    public var accuracyStat:String;
    public var damageStat:String;
    public var evasionStat:String;
    public var resistanceStat:String;
    public var pietyStat:String;
    public var isUndead:Bool = false;

    public var wounds:Array<{ countdown:Int, stat:String, modifier:String }>;
    public var abilities:Array<Ability>;
    public var animatePath:Array<IntPoint>;
    public var nextAttackEffects:Array<Creature -> Creature -> Void>;

    public var light:Shadowcaster;
    public var dice:Array<Int>;
    public var invisibleCounter:Int = 0;
    public function isVisible():Bool { return invisibleCounter == 0; }

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

        if (glyph != "@")
            new NpcAi(this);

        nextAttackEffects = new Array<Creature -> Creature -> Void>();
        dice = [3, 4, 5, 4, 3, 2, 1, 0, 0];
        abilities = new Array<Ability>();
        wounds = new Array<{ countdown:Int, stat:String, modifier:String }>();

        accuracyStat = "3d3+0";
        damageStat = "3d3+0";
        evasionStat = "3d3+0";
        resistanceStat = "3d3+0";
        pietyStat = "2d2+0";
    }

    public function getPronoun():String {
        switch (gender) {
            case "m": return "him";
            case "f": return "her";
            default: return "it";
        }
    }

    public function getPosessivePronoun():String {
        switch (gender) {
            case "m": return "his";
            case "f": return "her";
            default: return "it's";
        }
    }

    public function reveal():Void {
        if (isVisible())
            return;
        invisibleCounter = 0;
        world.addMessage('$name is revealed');
    }

    public function canSee(other:Creature):Bool {
        if (other.z != z)
            return false;

        if (light == null) {
            var dist = 0;
            for (p in Bresenham.line(x, y, other.x, other.y).points) { 
                if (dist++ > 15)
                    return false;
                if (world.blocksVision(p.x, p.y, z))
                    return false;
            }
            return true;
        } else {
            return light.isLit(other.x, other.y);
        }
    }

    public function doAi():Void {
        ai.update();
    }

    public function wander():Void {
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
        reveal();
        var distance = Math.floor(Math.sqrt((x-tx)*(x-tx) + (y-ty)*(y-ty)));
        for (i in 0 ... distance) {
            if (Math.random() > 0.25)
                continue;

            if (Math.random() < 0.5)
                tx += Math.floor(Math.random() * 3) - 1;
            else
                ty += Math.floor(Math.random() * 3) - 1;
        }

        var m = Math.abs(tx-x) + Math.abs(ty-y);
        var mx = Math.max(-1, Math.min(Math.round((tx-x) / m * 2), 1));
        var my = Math.max(-1, Math.min(Math.round((ty-y) / m * 2), 1));
        var dot = String.fromCharCode(249);
        var glyph = ["-1,-1" => "\\", "0,-1" => "|", "1,-1" => "/",
                     "-1,0"  => "-", "0,0"  => dot, "1,0" => "-",
                     "-1,1"  => "/", "0,1"  => "|", "1,1" => "\\"];
        var p = new Projectile(x, y, z, tx, ty, this, "arrow", glyph.get(mx + "," + my), Color.hsv(0, 10, 90));
        
        p.accuracyStat = accuracyStat;
        if (rangedWeapon != null) p.accuracyStat = Dice.add(p.accuracyStat, rangedWeapon.accuracyStat);
        if (armor != null) p.accuracyStat = Dice.add(p.accuracyStat, armor.accuracyStat);

        p.damageStat = damageStat;
        if (rangedWeapon != null) p.damageStat = Dice.add(p.damageStat, rangedWeapon.damageStat);
        if (armor != null) p.damageStat = Dice.add(p.damageStat, armor.damageStat);

        world.addProjectile(p);
    }

    private function quantify(amount:Int):String {
        amount = Math.floor(Math.abs(amount));
        if (amount < 3)
            return "just barely";
        else if (amount < 6)
            return "barely";
        else if (amount < 9)
            return "";
        else if (amount < 12)
            return "easily";
        else
            return "very easily";
    }

    public function takeRangedAttack(projectile:Projectile):Void {
        reveal();
        var accuracy = Dice.roll(projectile.accuracyStat);

        var effectiveEvasionStat = evasionStat;
        if (meleeWeapon != null) effectiveEvasionStat = Dice.add(effectiveEvasionStat, meleeWeapon.evasionStat);
        if (armor != null) effectiveEvasionStat = Dice.add(effectiveEvasionStat, armor.evasionStat);
        var evasion = Dice.roll(effectiveEvasionStat);

        if (accuracy < evasion) {
            world.addMessage('$fullName ${quantify(evasion-accuracy)} evades ${projectile.owner.fullName}\'s ${projectile.name}'); //'
            projectile.owner.nextAttackEffects = new Array<Creature -> Creature -> Void>();
            return;
        }

        var damage = Dice.roll(projectile.damageStat);

        var effectiveResistanceStat = evasionStat;
        if (meleeWeapon != null) effectiveResistanceStat = Dice.add(effectiveResistanceStat, meleeWeapon.resistanceStat);
        if (armor != null) effectiveResistanceStat = Dice.add(effectiveResistanceStat, armor.resistanceStat);
        var resistance = Dice.roll(effectiveResistanceStat);

        var actualDamage = Math.floor(Math.max(0, damage - resistance));
        if (damage == resistance)
            actualDamage = 1;

        if (actualDamage == 0)
            world.addMessage('$fullName ${quantify(resistance-damage)} resists ${projectile.owner.fullName}\'s ${projectile.name}'); //'
        else if (actualDamage >= hp)
            world.addMessage('${projectile.owner.fullName} ${quantify(accuracy-evasion+damage-resistance)} hits $fullName for $actualDamage damage, killing ${getPronoun()}');
        else
            world.addMessage('${projectile.owner.fullName} ${quantify(accuracy-evasion+damage-resistance)} hits $fullName for $actualDamage damage');

        takeDamage(actualDamage, projectile.owner);

        var effects = projectile.owner.nextAttackEffects;
        projectile.owner.nextAttackEffects = new Array<Creature -> Creature -> Void>();
        for (func in effects)
            func(projectile.owner, this);
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
        reveal();
        hp -= amount;

        if (hp < 1) {
            isAlive = false;
            if (attacker != null)
                attacker.gainDice(3);
        }
    }

    public function heal(amount:Int):Void {
        hp = Math.floor(Math.min(hp + amount, maxHp));
    }

    public function attack(other:Creature):Void {
        if (glyph != "@" && other.glyph != "@")
            return;
        
        reveal();
        other.reveal();

        var effectiveAccuracyStat = accuracyStat;
        if (meleeWeapon != null) effectiveAccuracyStat = Dice.add(effectiveAccuracyStat, meleeWeapon.accuracyStat);
        if (armor != null) effectiveAccuracyStat = Dice.add(effectiveAccuracyStat, armor.accuracyStat);
        var accuracy = Dice.roll(effectiveAccuracyStat);

        var effectiveEvasionStat = other.evasionStat;
        if (other.meleeWeapon != null) effectiveEvasionStat = Dice.add(effectiveEvasionStat, other.meleeWeapon.evasionStat);
        if (other.armor != null) effectiveEvasionStat = Dice.add(effectiveEvasionStat, other.armor.evasionStat);
        var evasion = Dice.roll(effectiveEvasionStat);

        if (accuracy < evasion) {
            world.addMessage('${other.fullName} ${quantify(evasion-accuracy)} evades $fullName');
            nextAttackEffects = new Array<Creature -> Creature -> Void>();
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
            world.addMessage('${other.fullName} ${quantify(resistance-damage)} resists $fullName');
        else if (actualDamage >= other.hp)
            world.addMessage('$fullName ${quantify(accuracy-evasion+damage-resistance)} hits ${other.fullName} for $actualDamage damage, killing ${other.getPronoun()}');
        else
            world.addMessage('$fullName ${quantify(accuracy-evasion+damage-resistance)} hits ${other.fullName} for $actualDamage damage');

        other.takeDamage(actualDamage, this);

        var effects = nextAttackEffects;
        nextAttackEffects = new Array<Creature -> Creature -> Void>();
        for (func in effects)
            func(this, other);
    }

    public function gainDice(amount:Int):Void {
        var gains = new Array<String>();
        for (i in 0 ... amount) {
            var sides = Dice.roll("1d9+0");
            dice[sides - 1] += 1;
            gains.push('1d$sides');
        }
        if (world != null)
            world.addMessage('$fullName gains ${gains.join(", ")}');
    }

    public function useDice(number:Int, sides:Int):Void {
        dice[sides - 1] -= number;
    }

    public function update():Void {
        if (invisibleCounter == 1)
            reveal();
        else if (invisibleCounter > 0)
            invisibleCounter--;
        recoverFromWounds();

        var fallDistance = 0;
        while (world.isEmptySpace(x, y, z)) {
            z++;
            fallDistance++;
        }

        if (fallDistance > 0) {
            hp -= fallDistance * 2;
            if (hp < 1)
                world.addMessage('$fullName falls $fallDistance ${fallDistance == 1 ? "floor" : "floors"} and dies');
            else
                world.addMessage('$fullName falls $fallDistance ${fallDistance == 1 ? "floor" : "floors"}');
        }

        if (hp < 1)
            isAlive = false;

        updateVision();
    }

    public function updateVision():Void {
        if (light == null)
            return;

        light.update(x, y, 25, function (vx:Int, vy:Int):Bool {
            return world.blocksVision(vx, vy, z);
        });
    }
}
