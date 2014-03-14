package;

import knave.Color;
import knave.IntPoint;
import knave.Bresenham;
import knave.Shadowcaster;

class Creature {
    public var world:World;
    public var x:Int;
    public var y:Int;
    public var z:Int;
    public var vx:Int;
    public var vy:Int;
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
    public var isAnimal:Bool = false;
    public var isSentient:Bool = false;
    public var sleepCounter:Int = 0;
    public var fearCounter:Int = 0;

    public function effectiveAccuracyStat(scenario:String):String {
        var s = accuracyStat;
        if (armor != null) s = Dice.add(s, armor.accuracyStat);
        if (scenario != "melee" && rangedWeapon != null) s = Dice.add(s, rangedWeapon.accuracyStat);
        if (scenario != "ranged" && meleeWeapon != null) s = Dice.add(s, meleeWeapon.accuracyStat);
        return s;
    }

    public function effectiveDamageStat(scenario:String):String {
        var s = damageStat;
        if (armor != null) s = Dice.add(s, armor.damageStat);
        if (scenario != "melee" && rangedWeapon != null) s = Dice.add(s, rangedWeapon.damageStat);
        if (scenario != "ranged" && meleeWeapon != null) s = Dice.add(s, meleeWeapon.damageStat);
        return s;
    }

    public function effectiveEvasionStat(scenario:String):String {
        var s = evasionStat;
        if (armor != null) s = Dice.add(s, armor.evasionStat);
        if (scenario != "melee" && rangedWeapon != null) s = Dice.add(s, rangedWeapon.evasionStat);
        if (scenario != "ranged" && meleeWeapon != null) s = Dice.add(s, meleeWeapon.evasionStat);
        return s;
    }

    public function effectiveResistanceStat(scenario:String):String {
        var s = resistanceStat;
        if (armor != null) s = Dice.add(s, armor.resistanceStat);
        if (scenario != "melee" && rangedWeapon != null) s = Dice.add(s, rangedWeapon.resistanceStat);
        if (scenario != "ranged" && meleeWeapon != null) s = Dice.add(s, meleeWeapon.resistanceStat);
        return s;
    }

    public function effectivePietyStat(scenario:String):String {
        var s = pietyStat;
        if (armor != null) s = Dice.add(s, armor.pietyStat);
        if (scenario != "melee" && rangedWeapon != null) s = Dice.add(s, rangedWeapon.pietyStat);
        if (scenario != "ranged" && meleeWeapon != null) s = Dice.add(s, meleeWeapon.pietyStat);
        return s;
    }



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

        if (glyph == "@")
            new AllyAi(this);
        else
            new EnemyAi(this);

        nextAttackEffects = new Array<Creature -> Creature -> Void>();
        dice = [0, 0, 0, 0, 0, 0, 0, 0, 0];
        abilities = new Array<Ability>();
        wounds = new Array<{ countdown:Int, stat:String, modifier:String }>();

        accuracyStat = "3d3+0";
        damageStat = "3d3+0";
        evasionStat = "3d3+0";
        resistanceStat = "3d3+0";
        pietyStat = "2d2+0";

        gainDice(Dice.roll("1d4+1"));
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
        if (sleepCounter > 0 || other.z != z)
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

    public function say(text:String) {
        if (glyph == "@" && isAlive && this != world.player)
            world.addMessage(name + ' says "$text"');
    }

    public function runFrom(other:Creature):Void {
        var here = new IntPoint(x, y);
        var there = new IntPoint(other.x, other.y);
        var dist = here.distanceTo(there);
        var candidates = new Array<IntPoint>();

        for (candidate in here.neighbors8()) {
            if (world.blocksMovement(candidate.x, candidate.y, z))
                continue;

            if (candidate.distanceTo(there) < dist && Math.random() < 0.90)
                continue;

            if (world.isEmptySpace(candidate.x, candidate.y, z) && Math.random() < 0.80)
                continue;

            if (world.isLava(candidate.x, candidate.y, z) && Math.random() < 0.90)
                continue;

            candidates.push(candidate);
        }

        if (candidates.length == 0) {
            wander();
            return;
        }

        var candidate = candidates[Math.floor(Math.random() * candidates.length)];
        
        move(candidate.x-x, candidate.y-y, 0);
    }

    public function wander():Void {
        var mx = Math.floor(Math.random() * 3) - 1;
        var my = Math.floor(Math.random() * 3) - 1;

        if (world.isEmptySpace(x+mx, y+my, z) || world.isLava(x+mx, y+my, z))
            return;
        
        move(mx, my, 0);
    }

    public function pickupItem():Void {
        var item = world.removeItem(x, y, z);
        if (item != null) {
            if (item.type == "dice") {
                var sides = Std.parseInt(item.name.substr(1));
                dice[sides-1]++;
            } else if (item.type == "ranged") {
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
        else if (!world.blocksMovement(x + mx, y + my, z + mz)) {
            x += mx;
            y += my;

            vx = mx;
            vy = my;
            
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
        
        p.accuracyStat = effectiveAccuracyStat("ranged");
        p.damageStat = effectiveDamageStat("ranged");

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
        var other = projectile.owner;
        var accuracy = Dice.roll(projectile.accuracyStat);
        var evasion = Dice.roll(effectiveEvasionStat("ranged"));

        if (accuracy < evasion) {
            world.addMessage('$fullName ${quantify(evasion-accuracy)} evades ${other.fullName}\'s ${projectile.name}'); //'
            projectile.owner.nextAttackEffects = new Array<Creature -> Creature -> Void>();
            return;
        }

        var damage = Dice.roll(projectile.damageStat);
        var resistance = Dice.roll(effectiveResistanceStat("ranged"));

        var actualDamage = Math.floor(Math.max(0, damage - resistance));
        if (damage == resistance)
            actualDamage = 1;

        if (actualDamage == 0)
            world.addMessage('$fullName ${quantify(resistance-damage)} resists ${other.fullName}\'s ${projectile.name}'); //'
        else if (actualDamage >= hp)
            world.addMessage('${other.fullName} ${quantify(accuracy-evasion+damage-resistance)} hits $fullName for $actualDamage damage, killing ${getPronoun()}');
        else
            world.addMessage('${other.fullName} ${quantify(accuracy-evasion+damage-resistance)} hits $fullName for $actualDamage damage');
        
        if (armor != null)
            armor.onHit(this, other);

        if (other.rangedWeapon!= null)
            other.rangedWeapon.onHit(other, this);

        takeDamage(actualDamage, projectile.owner);

        var effects = other.nextAttackEffects;
        other.nextAttackEffects = new Array<Creature -> Creature -> Void>();
        for (func in effects)
            func(other, this);

        if (glyph == "@" && other.glyph == "@")
            say('Careful ${other.name}!');
    }

    public function addWound(wound:{ countdown:Int, stat:String, modifier:String }):Void {
        switch (wound.stat) {
            case "accuracy": accuracyStat = Dice.subtract(accuracyStat, wound.modifier);
            case "evasion": evasionStat = Dice.subtract(evasionStat, wound.modifier);
            case "damage": damageStat = Dice.subtract(damageStat, wound.modifier);
            case "resistance": resistanceStat = Dice.subtract(resistanceStat, wound.modifier);
        }
        wounds.push(wound);
    }

    public function recoverFromWounds():Void {
        var newWounds = new Array<{ countdown:Int, stat:String, modifier:String }>();
        for (w in wounds) {
            if (w.countdown == 0) {
                switch (w.stat) {
                    case "accuracy": accuracyStat = Dice.add(accuracyStat, w.modifier);
                    case "evasion": evasionStat = Dice.add(evasionStat, w.modifier);
                    case "damage": damageStat = Dice.add(damageStat, w.modifier);
                    case "resistance": resistanceStat = Dice.add(resistanceStat, w.modifier);
                }
            } else {
                w.countdown--;
                newWounds.push(w);
            }
        }
        wounds = newWounds;
    }

    public function takeDamage(amount:Int, attacker:Creature):Void {
        reveal();
        sleepCounter = 0;
        hp -= amount;
        checkHealth(attacker);
    }

    public function heal(amount:Int):Void {
        reveal();
        sleepCounter = 0;
        hp += amount;
        checkHealth(null);
    }

    private function checkHealth(attacker:Creature):Void {
        if (hp > maxHp)
            hp = maxHp;
        if (hp < 1)
            die(attacker);
    }

    private function dropItem(item:Item, ix:Int, iy:Int, iz:Int):Void {
        while (world.isEmptySpace(ix, iy, iz))
            iz++;
        world.addItem(item, ix, iy, iz);
    }

    private function die(attacker:Creature):Void {
        isAlive = false;

        say("Aghhhhh");

        var adjacentSpots = new Array<IntPoint>();
        for (p in new IntPoint(x,y).neighbors9()) {
            if (!world.blocksMovement(p.x, p.y, z))
                adjacentSpots.push(p);
        }

        for (i in 0 ... dice.length) {
            if (dice[i] == 0 || adjacentSpots.length == 0)
                continue;
            var p = adjacentSpots[Math.floor(Math.random() * adjacentSpots.length)];
            adjacentSpots.remove(p);
            dropItem(Factory.dice(i+1), p.x, p.y, z);
        }

        if (meleeWeapon != null && adjacentSpots.length > 0) {
            var p = adjacentSpots[Math.floor(Math.random() * adjacentSpots.length)];
            adjacentSpots.remove(p);
            dropItem(meleeWeapon, p.x, p.y, z);
        }

        if (rangedWeapon != null && adjacentSpots.length > 0) {
            var p = adjacentSpots[Math.floor(Math.random() * adjacentSpots.length)];
            adjacentSpots.remove(p);
            dropItem(rangedWeapon, p.x, p.y, z);
        }

        if (armor != null && adjacentSpots.length > 0) {
            var p = adjacentSpots[Math.floor(Math.random() * adjacentSpots.length)];
            adjacentSpots.remove(p);
            dropItem(armor, p.x, p.y, z);
        }

        if (attacker != null && glyph != "@") {
            for (c in world.creatures) {
                if (!c.ai.isEnemy(this) && c.canSee(this))
                    c.fearCounter += Math.floor(Math.random() * 11) + 3;
            }
        }
    }

    public function attack(other:Creature):Void {
        if (!ai.isEnemy(other))
            return;
        
        reveal();
        other.reveal();

        var accuracy = Dice.roll(effectiveAccuracyStat("melee"));
        var evasion = Dice.roll(other.effectiveEvasionStat("melee"));

        if (accuracy < evasion) {
            world.addMessage('${other.fullName} ${quantify(evasion-accuracy)} evades $fullName');
            nextAttackEffects = new Array<Creature -> Creature -> Void>();
            return;
        }

        var damage = Dice.roll(effectiveDamageStat("melee"));
        var resistance = Dice.roll(other.effectiveResistanceStat("melee"));

        var actualDamage = Math.floor(Math.max(0, damage - resistance));
        if (damage == resistance)
            actualDamage = 1;

        if (actualDamage == 0)
            world.addMessage('${other.fullName} ${quantify(resistance-damage)} resists $fullName');
        else if (actualDamage >= other.hp)
            world.addMessage('$fullName ${quantify(accuracy-evasion+damage-resistance)} hits ${other.fullName} for $actualDamage damage, killing ${other.getPronoun()}');
        else
            world.addMessage('$fullName ${quantify(accuracy-evasion+damage-resistance)} hits ${other.fullName} for $actualDamage damage');

        if (other.armor != null)
            other.armor.onHit(other, this);

        if (meleeWeapon != null)
            meleeWeapon.onHit(this, other);

        other.takeDamage(actualDamage, this);

        var effects = nextAttackEffects;
        nextAttackEffects = new Array<Creature -> Creature -> Void>();
        for (func in effects)
            func(this, other);
    }

    public function hasDice():Bool {
        for (i in 0 ... dice.length) {
            if (dice[i] > 0)
                return true;
        }
        return false;
    }

    public function getDiceToUseForAbility(): { number:Int, sides:Int } {
        var candidates = new Array<{ number:Int, sides:Int }>();
        for (i in 0 ... dice.length) {
            if (dice[i] > 0)
                candidates.push({ number: dice[i], sides: i+1 });
        }
        if (candidates.length == 0)
            return { number: 0, sides: 0 };
        return candidates[Math.floor(Math.random() * candidates.length)];
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
        if (number < 1 || sides < 1)
            return;
        dice[sides - 1] -= number;
    }

    public function update():Void {
        if (fearCounter > 0)
            fearCounter--;
        if (sleepCounter > 0)
            sleepCounter--;

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
            die(null);

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
