package;

import knave.*;

class Creature {
    public var world:World;
    public var x:Int;
    public var y:Int;
    public var z:Int;
    public var vx:Int = 0;
    public var vy:Int = 0;
    public var glyph:String;
    public var name:String;
    public var fullName:String;
    public var color:Color;
    public var ai:NpcAi;

    public var extroversion:Float;
    public var greed:Float;
    public var helpfulness:Float;
    public var aggresiveness:Float;
    public var lore:Float;

    public var about:String;
    public function addHistory(line:String):Void { about += " " + Text.sentence(line); }

    public function isHero():Bool { return glyph == "@"; }

    public var gender:String;
    public var hp:Int = 30;
    public var maxHp:Int = 30;
    public var isAlive:Bool = true;

    public var accuracyStat:String;
    public var damageStat:String;
    public var evasionStat:String;
    public var resistanceStat:String;
    public var pietyStat:String;
    public var isFlying:Bool = false;
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
        this.name = name.split(" ")[0];
        this.fullName = isHero() ? name : ("the " + name);
        this.gender = gender == null ? (Math.random() < 0.5 ? "m" : "f") : gender;
        this.x = x;
        this.y = y;
        this.z = z;
        this.about = "";

        extroversion = Math.random();
        greed = Math.random();
        helpfulness = Math.random();
        aggresiveness = Math.random();
        lore = Math.random();

        if (isHero())
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

    public function getSubjectPronoun():String {
        switch (gender) {
            case "m": return "he";
            case "f": return "she";
            default: return "it";
        }
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

    public function distanceTo(other:Creature):Int {
        return Math.floor(Math.max(Math.abs(x-other.x), Math.abs(y-other.y)) + Math.abs(z-other.z));
    }

    public function canSee(other:Creature):Bool {
        if (sleepCounter > 0 || other.z != z || !other.isAlive || !other.isVisible())
            return false;

        return canSeeTile(other.x, other.y, other.z);
    }

    public function canSeeTile(tx:Int, ty:Int, tz:Int):Bool {
        if (tz != z)
            return false;

        if (light == null) {
            var dist = 0;
            for (p in Bresenham.line(x, y, tx, ty).points) { 
                if (dist++ > 15)
                    return false;
                if (world.blocksVision(p.x, p.y, z))
                    return false;
            }
            return true;
        } else {
            return light.isLit(tx, ty);
        }
    }

    public function doAi():Void {
        ai.update();
    }

    public function say(text:String, force:Bool = false) {
        if (force || isHero() && isAlive && this != world.player && Math.random() < extroversion)
            world.addMessage(name + ' says "${Text.sentence(text)}"');
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

    public function you(message:String):Void {
        if (this == world.player)
            world.addMessage("You " + message);
    }

    public function pickupItem():Void {
        var item = world.removeItem(x, y, z);
        if (item != null) {
            if (item.type == "dice") {
                var sides = Std.parseInt(item.name.substr(1));
                dice[sides-1]++;
            } else if (item.type == "ranged") {
                if (rangedWeapon != null)
                    dropItem(rangedWeapon, x, y, z);
                rangedWeapon = item;
                you(' weild a ${item.describe()}');
            } else if (item.type == "melee") {
                if (meleeWeapon != null)
                   dropItem(meleeWeapon, x, y, z);
                meleeWeapon = item;
                you(' weilds a ${item.describe()}');
            } else if (item.type == "armor") {
                if (armor != null)
                    dropItem(armor, x, y, z);
                armor = item;
                you(' wears a ${item.describe()}');
            }
            world.partyAi.onItemPickedUp(item, new IntPoint(x,y,z), this);
        }
    }

    public function move(mx:Int, my:Int, mz:Int):Void {
        if (mx==0 && my==0 && mz==0)
            return;

        if (mz > 0 && world.canGoDown(x, y, z)) {
            z += 1;
            return;

        } else if (mz < 0 && world.canGoUp(x, y, z)) {
            z -= 1;
            return;
        }

        mx = Math.floor(Math.max(-1, Math.min(mx, 1)));
        my = Math.floor(Math.max(-1, Math.min(my, 1)));

        var other = world.getCreature(x+mx, y+my, z);
        if (other != null) {
            if (ai.isEnemy(other)) {
                attack(other);
            } else if (other != this && other.isHero() && this == world.player) {
                var ox = other.x;
                var oy = other.y;
                other.x = x;
                other.y = y;
                x = ox;
                y = oy;
            }
        } else if (!world.blocksMovement(x + mx, y + my, z)) {
            x += mx;
            y += my;
            vx = mx;
            vy = my;
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
            you(' ${quantify(evasion-accuracy)} evade ${other.fullName}\'s ${projectile.name}'); //'
            if (evasion > accuracy * 2)
                say('${other.fullName} can\'t hit me!'); //'
            projectile.owner.nextAttackEffects = new Array<Creature -> Creature -> Void>();
            return;
        }

        var damage = Dice.roll(projectile.damageStat);
        var resistance = Dice.roll(effectiveResistanceStat("ranged"));

        var actualDamage = Math.floor(Math.max(0, damage - resistance));
        if (damage == resistance)
            actualDamage = 1;

        if (actualDamage == 0)
            you(' ${quantify(resistance-damage)} resist ${other.fullName}\'s ${projectile.name}'); //'
        else { 
            you(' are ${quantify(accuracy-evasion+damage-resistance)} hit by $fullName for $actualDamage damage');
            if (damage > resistance * 2) {
                say('Ouch! ${other.name}\'s really hurt!'); //'
                fearCounter += 5;
            }
        }
        
        if (armor != null)
            armor.onHit(this, other);

        if (other.rangedWeapon!= null)
            other.rangedWeapon.onHit(other, this);

        takeDamage(actualDamage, projectile.owner);

        var effects = other.nextAttackEffects;
        other.nextAttackEffects = new Array<Creature -> Creature -> Void>();
        for (func in effects)
            func(other, this);

        if (isHero() && other.isHero())
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
        world.partyAi.onItemDropped(item, new IntPoint(ix,iy,iz), this);
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

        if (isHero())
            world.addCreature(Factory.ghost(z, this));

        world.partyAi.onCreatureDied(this, attacker);
    }

    public function attack(other:Creature):Void {
        if (!ai.isEnemy(other))
            return;
        
        reveal();
        other.reveal();

        var accuracy = Dice.roll(effectiveAccuracyStat("melee"));
        var evasion = Dice.roll(other.effectiveEvasionStat("melee"));

        if (accuracy < evasion) {
            you(' ${quantify(evasion-accuracy)} evade ${other.fullName}');
            nextAttackEffects = new Array<Creature -> Creature -> Void>();
            return;
        }

        var damage = Dice.roll(effectiveDamageStat("melee"));
        var resistance = Dice.roll(other.effectiveResistanceStat("melee"));

        var actualDamage = Math.floor(Math.max(0, damage - resistance));
        if (damage == resistance)
            actualDamage = 1;

        if (actualDamage == 0)
            you('r attack is ${quantify(resistance-damage)} resisted by ${other.fullName}');
        else if (actualDamage >= other.hp)
            you(' ${quantify(accuracy-evasion+damage-resistance)} hit ${other.fullName} for $actualDamage damage, killing ${other.getPronoun()}');
        else
            you(' ${quantify(accuracy-evasion+damage-resistance)} hit ${other.fullName} for $actualDamage damage');

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
            you(' gain ${gains.join(", ")}');
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
        while (world.isEmptySpace(x, y, z) && !isFlying) {
            z++;
            fallDistance++;
        }

        if (fallDistance > 0) {
            hp -= fallDistance * 2;
            if (hp < 1)
                you(' fall $fallDistance ${fallDistance == 1 ? "floor" : "floors"} and die');
            else
                you(' fall $fallDistance ${fallDistance == 1 ? "floor" : "floors"}');
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
