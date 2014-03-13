package;

import StringTools;
import knave.IntPoint;
import knave.Color;
import knave.Bresenham;
import knave.Shadowcaster;

class Factory {
    public static function dice():Item {
        return new Item(String.fromCharCode(254), Color.hsv(220, 75, 90), "dice", "d" + (Math.floor(Math.random() * 9) + 1));
    }

    public static function hero():Creature {
        var c = new Creature("@", "player", 0, 0, 0);
        c.light = new Shadowcaster();

        var bonuses = ["1d0+1", "0d1+0", "0d0+1"];
        var potentialAbilityNames = new Array<String>();
        switch (Math.floor(Math.random() * 5)) {
            case 0: // melee
                c.maxHp += Dice.roll("2d2+2");
                c.accuracyStat = Dice.add(c.accuracyStat, Dice.add(bonuses[Math.floor(Math.random() * bonuses.length)], bonuses[Math.floor(Math.random() * bonuses.length)]));
                c.damageStat = Dice.add(c.damageStat, Dice.add(bonuses[Math.floor(Math.random() * bonuses.length)], bonuses[Math.floor(Math.random() * bonuses.length)]));
                c.meleeWeapon = meleeWeapon();
                if (Math.random() < 0.5)
                    c.armor = armor();
                potentialAbilityNames = ["accuracy boost", "damage boost", "Knock back", "Jump", "disarming attack", "rapid attack", "intimidate"];
            case 1: // ranged
                c.maxHp += Dice.roll("2d2+2");
                c.accuracyStat = Dice.add(c.accuracyStat, Dice.add(bonuses[Math.floor(Math.random() * bonuses.length)], bonuses[Math.floor(Math.random() * bonuses.length)]));
                c.damageStat = Dice.add(c.damageStat, Dice.add(bonuses[Math.floor(Math.random() * bonuses.length)], bonuses[Math.floor(Math.random() * bonuses.length)]));
                c.rangedWeapon = rangedWeapon();
                if (Math.random() < 0.25)
                    c.armor = armor();
                potentialAbilityNames = ["accuracy boost", "damage boost", "Knock back", "Jump", "wounding attack"];
            case 2: // magic
                potentialAbilityNames = ["Jump", "magic missiles", "orb of pain", "explosion"];
                c.pietyStat = Dice.subtract(c.pietyStat, bonuses[Math.floor(Math.random() * bonuses.length)]);
                c.pietyStat = Dice.subtract(c.pietyStat, bonuses[Math.floor(Math.random() * bonuses.length)]);
                c.gainDice(10);
            case 3: // piety
                potentialAbilityNames = ["turn undead", "healing aura", "pious attack", "pious defence", "smite", "soothe"];
                c.pietyStat = Dice.add(c.pietyStat, bonuses[Math.floor(Math.random() * bonuses.length)]);
                c.pietyStat = Dice.add(c.pietyStat, bonuses[Math.floor(Math.random() * bonuses.length)]);
                c.gainDice(5);
            case 4: // stealth
                c.evasionStat = Dice.add(c.evasionStat, Dice.add(bonuses[Math.floor(Math.random() * bonuses.length)], bonuses[Math.floor(Math.random() * bonuses.length)]));
                potentialAbilityNames = ["Jump", "disarming attack", "wounding attack", "sneak", "soothe"];
                c.gainDice(3);
        }

        c.maxHp += Dice.roll("2d6+0") - 2;
        c.accuracyStat = Dice.add(c.accuracyStat, bonuses[Math.floor(Math.random() * bonuses.length)]);
        c.damageStat = Dice.add(c.damageStat, bonuses[Math.floor(Math.random() * bonuses.length)]);
        c.evasionStat = Dice.add(c.evasionStat, bonuses[Math.floor(Math.random() * bonuses.length)]);
        c.resistanceStat = Dice.add(c.resistanceStat, bonuses[Math.floor(Math.random() * bonuses.length)]);
        c.pietyStat = Dice.add(c.pietyStat, bonuses[Math.floor(Math.random() * bonuses.length)]);
        c.gainDice(Dice.roll("1d4+0"));

        if (Math.random() < 0.1)
            c.meleeWeapon = meleeWeapon();
        if (Math.random() < 0.1)
            c.rangedWeapon = rangedWeapon();
        if (Math.random() < 0.1)
            c.armor = armor();

        var amount = 3;
        if (Math.random() < 0.25)
            amount++;
        while (c.abilities.length < amount) {
            var candidate = ability(potentialAbilityNames[Math.floor(Math.random() * potentialAbilityNames.length)]);
            var char = candidate.name.charAt(0);
            var bad = false;
            for (other in c.abilities) {
                if (other.name.charAt(0) == char)
                    bad = true;
            }
            if (bad)
                continue;
            c.abilities.push(candidate);
        }

        c.hp = c.maxHp;

        return c;
    }

    private static function maybeBig(c:Creature, z:Int):Creature {
        var chance = z * 2;
        if (Math.random() * 100 > chance)
            return c;

        c.glyph = c.glyph.toUpperCase();
        c.name = "big " + c.name;
        c.fullName = "the " + c.name;

        c.maxHp += 15;
        c.hp += 15;
        c.accuracyStat = Dice.add(c.accuracyStat, "1d1+2");
        c.evasionStat = Dice.add(c.evasionStat, "1d1+2");
        c.damageStat = Dice.add(c.damageStat, "1d1+2");
        c.resistanceStat = Dice.add(c.resistanceStat, "1d1+2");

        c.abilities.push(ability("Knock back"));

        return c;
    }

    public static function arachnid(z:Int):Creature {
        var c = new Creature("a", "arachnid", 0, 0, 0);
        c.accuracyStat = "5d5+5";
        c.isAnimal = true;
        c.abilities.push(ability("Jump"));
        return maybeBig(c, z);
    }

    public static function bear(z:Int):Creature {
        var c = new Creature("b", "bear", 0, 0, 0);
        c.damageStat = "5d5+5";
        c.isAnimal = true;
        c.abilities.push(ability("wounding attack"));
        c.sleepCounter = 80 + z * 20;
        return maybeBig(c, z);
    }

    public static function ghost(z:Int):Creature {
        var c = new Creature("g", "ghost", 0, 0, 0);
        c.isUndead = true;
        c.evasionStat = "5d5+5";
        c.abilities.push(ability("sneak"));
        return maybeBig(c, z);
    }

    public static function skeleton(z:Int):Creature {
        var c = new Creature("s", "skeleton", 0, 0, 0);
        c.resistanceStat = "5d5+5";
        c.isUndead = true;
        return c;
    }

    public static function fairy(z:Int):Creature {
        var c = new Creature("f", "fairy", 0, 0, 0);
        c.isSentient = true;
        if (Math.random() > z / 10.0)
            c.abilities.push(ability("magic missiles"));
        if (Math.random() > z / 15.0)
            c.abilities.push(ability("explosion"));
        if (Math.random() > z / 20.0)
            c.abilities.push(ability("orb of pain"));
        return c;
    }

    public static function lizardfolk(z:Int):Creature {
        var c:Creature = null;
        if (Math.random() < 0.5)
            c = new Creature("l", "lizardman", 0, 0, 0, "m");
        else
            c = new Creature("l", "lizardwoman", 0, 0, 0, "f");
        c.pietyStat = "5d5+5";
        c.isSentient = true;
        c.abilities.push(ability("pious attack"));
        c.abilities.push(ability("pious defence"));
        c.abilities.push(ability("smite"));
        c.abilities.push(ability("healing aura"));
        return maybeBig(c, z);
    }

    public static function orc(z:Int):Creature {
        var c = new Creature("o", "orc", 0, 0, 0);
        c.rangedWeapon = orcishBow();
        c.isSentient = true;
        return maybeBig(c, z);
    }

    public static function enemy(z:Int):Creature {
        switch (Math.floor(Math.random() * 7)) {
            case 0: return arachnid(z);
            case 1: return bear(z);
            case 2: return ghost(z);
            case 3: return skeleton(z);
            case 4: return lizardfolk(z);
            case 5: return fairy(z);
            default: return orc(z);
        }
    }

    public static function enemies(z:Int):Array<Creature> {
        switch (Math.floor(Math.random() * 7)) {
            case 0: 
                var list = new Array<Creature>();
                var count = Math.floor(2 + Math.random() * 5);
                for (i in 0 ... count)
                    list.push(arachnid(z));
                return list;

            case 1:
                var list = new Array<Creature>();
                var count = Dice.roll("2d2+0");
                for (i in 0 ... count)
                    list.push(bear(z));
                return list;

            case 2: return [ghost(z)];
            case 3:
                var list = new Array<Creature>();
                var count = Dice.roll("2d2+0");
                for (i in 0 ... count)
                    list.push(skeleton(z));
                return list;

            case 4:
                var list = new Array<Creature>();
                var count = Dice.roll("2d2+0");
                for (i in 0 ... count)
                    list.push(lizardfolk(z));
                return list;

            case 5: return [fairy(z)];

            default:
                var list = new Array<Creature>();
                var count = Math.floor(z / 2 + 1);
                for (i in 0 ... count)
                    list.push(orc(z));
                return list;
        }
    }

    public static function orcishBow():Item {
        return new Item(")", Color.hsv(30, 80, 80), "ranged", "orcish bow");
    }

    public static function rangedWeapon():Item {
        var list = [{ name:"crappy bow",    accuracy:"-1d2+0", evasion:"0d0+0", damage:"-1d2+0", resistance:"0d0+0", piety:"0d0+0" },
                    { name:"short bow",     accuracy:"2d2+0", evasion:"0d0+0", damage:"1d1+0", resistance:"0d0+0", piety:"0d0+0" },
                    { name:"medium bow",    accuracy:"1d2+0", evasion:"0d0+0", damage:"1d2+0", resistance:"0d0+0", piety:"0d0+0" },
                    { name:"long bow",      accuracy:"1d1+0", evasion:"0d0+0", damage:"2d2+0", resistance:"0d0+0", piety:"0d0+0" },
                    { name:"silver bow",    accuracy:"1d1+5", evasion:"0d0+0", damage:"1d1+5", resistance:"0d0+0", piety:"0d0+0" },
                    { name:"unholy bow",    accuracy:"2d2+2", evasion:"0d0+0", damage:"2d2+2", resistance:"0d0+0", piety:"-3d3+0" }];

        var def = list[Math.floor(Math.random() * list.length)];
        var i = new Item(")", Color.hsv(30, 80, 80), "ranged", def.name);
        i.accuracyStat = def.accuracy;
        i.evasionStat = def.evasion;
        i.damageStat = def.damage;
        i.resistanceStat = def.resistance;
        i.pietyStat = def.piety;
        return maybeBetter(i);
    }

    public static function meleeWeapon():Item {
        var list = [{ name:"crappy sword",    accuracy:"-1d2+0", evasion:"0d0+0", damage:"-1d2+0", resistance:"0d0+0", piety:"0d0+0" },
                    { name:"short sword",     accuracy:"2d2+0", evasion:"0d0+0", damage:"1d1+0", resistance:"0d0+0", piety:"0d0+0" },
                    { name:"medium sword",    accuracy:"1d2+0", evasion:"0d0+0", damage:"1d2+0", resistance:"0d0+0", piety:"0d0+0" },
                    { name:"long sword",      accuracy:"1d1+0", evasion:"0d0+0", damage:"2d2+0", resistance:"0d0+0", piety:"0d0+0" },
                    { name:"silver sword",    accuracy:"1d1+5", evasion:"0d0+0", damage:"1d1+5", resistance:"0d0+0", piety:"0d0+0" },
                    { name:"unholy sword",    accuracy:"2d2+2", evasion:"0d0+0", damage:"2d2+2", resistance:"0d0+0", piety:"-3d3+0" }];
        
        var def = list[Math.floor(Math.random() * list.length)];
        var i = new Item("|", Color.hsv(180, 20, 80), "melee", def.name);
        i.accuracyStat = def.accuracy;
        i.evasionStat = def.evasion;
        i.damageStat = def.damage;
        i.resistanceStat = def.resistance;
        i.pietyStat = def.piety;
        return maybeBetter(i);
    }

    public static function armor():Item {
        var list = [{ name:"crappy armor",    accuracy:"0d0+0", evasion:"-1d2+0", damage:"0d0+0", resistance:"-1d1+0", piety:"0d0+0" },
                    { name:"light armor",     accuracy:"0d0+0", evasion:"-1d1+0", damage:"0d0+0", resistance:"1d2+0", piety:"0d0+0" },
                    { name:"medium armor",    accuracy:"0d0+0", evasion:"-1d2+0", damage:"0d0+0", resistance:"2d2+0", piety:"0d0+0" },
                    { name:"heavy armor",     accuracy:"0d0+0", evasion:"-2d2+0", damage:"0d0+0", resistance:"2d3+0", piety:"0d0+0" },
                    { name:"silver armor",    accuracy:"0d0+0", evasion:"-1d1+5", damage:"0d0+0", resistance:"1d1+5", piety:"0d0+0" },
                    { name:"unholy armor",      accuracy:"0d0+0", evasion: "1d1+1", damage:"0d0+0", resistance:"1d1+1", piety:"-3d3+0" }];

        var def = list[Math.floor(Math.random() * list.length)];
        var i = new Item("[", Color.hsv(90, 40, 80), "armor", def.name);
        i.accuracyStat = def.accuracy;
        i.evasionStat = def.evasion;
        i.damageStat = def.damage;
        i.resistanceStat = def.resistance;
        i.pietyStat = def.piety;
        return maybeBetter(i);
    }

    public static function maybeBetter(item:Item):Item {
        var item2 = item;
        if (Math.random() < 0.25)
            item2 = addStatBonusToItem(item2);
        if (Math.random() < 0.25)
            item2 = addAbilityBonusToItem(item2);

        if (item2.name.indexOf("holy") > -1 && item2.name.indexOf("unholy") > -1)
            return item;

        if (item2.name.indexOf("smiting") > -1 && item2.name.indexOf("unholy") > -1)
            return item;

        return item2;
    }

    public static function addAbilityBonusToItem(item:Item):Item {
        var modifier = "";
        switch (Math.floor(Math.random() * 6)) {
            case 0: item.onHitAbility = new KnockBackAbility(); modifier = " of knock back";
            case 1: item.onHitAbility = new DisarmingAttackAbility(); modifier = " of disarming";
            case 2: item.onHitAbility = new WoundingAttackAbility(); modifier = " of wounding";
            case 3: item.onHitAbility = new IntimidateAbility(); modifier = " of intimidation";
            case 4: item.onHitAbility = new SmiteAbility(); modifier = " of smiting";
            case 5: item.onHitAbility = new HealingAuraAbility(); modifier = " of healing";
        }
        item.name += modifier;
        return item;
    }

    public static function addStatBonusToItem(item:Item):Item {
        var bonus = "1d1+1";
        var modifier = "";
        switch (Math.floor(Math.random() * 5)) {
            case 0: item.accuracyStat = Dice.add(item.accuracyStat, bonus); modifier = "accurate ";
            case 1: item.damageStat = Dice.add(item.damageStat, bonus); modifier = "damaging ";
            case 2: item.evasionStat = Dice.add(item.evasionStat, bonus); modifier = "evasive ";
            case 3: item.resistanceStat = Dice.add(item.resistanceStat, bonus); modifier = "resistant ";
            case 4: item.pietyStat = Dice.add(item.pietyStat, bonus); modifier = "holy ";
        }
        item.name = modifier + item.name;
        return item;
    }

    public static function item():Item {
        switch (Math.floor(Math.random() * 3)) {
            case 0: return rangedWeapon();
            case 1: return meleeWeapon();
            default: return armor();
        }
    }

    public static function ability(name:String):Ability {
        for (a in abilities) {
            if (a.name == name)
                return a;
        }
        trace("Can't find ability named [" + name + "]");
        return null;
    }

    public static function randomAbility():Ability {
        return abilities[Math.floor(Math.random() * abilities.length)];
    }

    public static var abilities:Array<Ability>;

    public static function init():Void {
        abilities = [ 
            new JumpAbility(),
            new KnockBackAbility(),
            new DisarmingAttackAbility(),
            new WoundingAttackAbility(),
            new RapidAttackAbility(),
            new SneakAbility(),
            new AccuracyBoostAbility(),
            new DamageBoostAbility(),
            new MagicMissilesAbility(),
            new OrbOfPainAbility(),
            new ExplosionAbility(),
            new IntimidateAbility(),
            new SootheAbility(),
            new TurnUndeadAbility(),
            new HealingAuraAbility(),
            new PiousAttackAbility(),
            new PiousDefenceAbility(),
            new SmiteAbility() ];
    }
}

class JumpAbility extends Ability { 
    public function new() { super("Jump", "Move several spaces at once."); }

    override public function aiUsage(self:Creature): { percent:Float, func:Creature -> Void } {
        var here = new IntPoint(self.x, self.y);
        var target = new IntPoint(self.world.player.x, self.world.player.y);
        var dice = self.getDiceToUseForAbility();

        if (dice == null || here.distanceTo(target) < 2)
            return { percent: 0.0, func: function(self):Void { } };

        var roll = Dice.rollExact(dice.number, dice.sides, 0);

        var candidates = new Array<IntPoint>();
        for (n in target.neighbors9()) {
            if (n.distanceTo(here) > roll)
                continue;

            var isBad = false;
            var points = Bresenham.line(self.x, self.y, n.x, n.y).points;
            points.shift();
            for (p in points) {
                var other = self.world.getCreature(p.x, p.y, self.z);
                if (other != null && other.glyph != "@")
                    isBad = true;
            }
            if (isBad)
                continue;

            candidates.push(n);
        }

        if (candidates.length == 0)
            return { percent: 0.0, func: function(self):Void { } };

        var candidate = candidates[Math.floor(Math.random() * candidates.length)];

        return { 
            percent: 0.25,
               func: function(self):Void {
                    doIt(self, dice.number, dice.sides, roll, candidate.x, candidate.y);
               }
        };
    }

    override public function playerUsage(self:Creature):Void {
        self.world.enter(new SelectDiceScreen(self, "What do you want to roll for jump distance?", function(number:Int, sides:Int):Void {
            var roll = Dice.rollExact(number, sides, 0);
            self.world.enter(new AimScreen(self, roll, function(tx:Int, ty:Int):Void {
                doIt(self, number, sides, roll, tx, ty);
            }));
        }));
    }

    private function doIt(self:Creature, number:Int, sides:Int, roll:Int, tx:Int, ty:Int):Void {
        self.useDice(number, sides);
        self.animatePath = Bresenham.line(self.x, self.y, tx, ty).points;
        self.animatePath.shift();
        self.world.addMessage('${self.fullName} uses ${number}d$sides to jump');
    }
}

class KnockBackAbility extends Ability {
    public function new() { super("Knock back", "A successfull hit sends your oppenent back."); }

    override public function itemUsage(item:Item, owner:Creature, other:Creature):Void {
        apply(owner, other, Dice.roll("3d3+0"));
    }

    override public function aiUsage(self:Creature): { percent:Float, func:Creature -> Void } {
        return {
            percent: self.nextAttackEffects.length > 0 || !self.hasDice() ? 0 : 0.25,
               func: function(self):Void {
                    var dice = self.getDiceToUseForAbility();
                    doIt(self, dice.number, dice.sides);
               }
        };
    }

    override public function playerUsage(self:Creature):Void {
        self.world.enter(new SelectDiceScreen(self, "What do you want to roll for knock back distance?", function(number:Int, sides:Int):Void {
            doIt(self, number, sides);
        }));
    }

    private function doIt(self:Creature, number:Int, sides:Int):Void {
        var amount = Dice.rollExact(number, sides, 0);
        self.useDice(number, sides);
        self.world.addMessage('${self.fullName} uses ${number}d$sides to prepare a knock back attack');
        self.nextAttackEffects.push(function (self:Creature, target:Creature){
            apply(self, target, amount);
        });
    }

    private function apply(self:Creature, target:Creature, distance:Int):Void {
        var dx = target.x - self.x + Math.random() - 0.5;
        var dy = target.y - self.y + Math.random() - 0.5;

        dx *= distance;
        dy *= distance;

        target.animatePath = Bresenham.line(target.x, target.y, target.x + Math.floor(dx), target.y + Math.floor(dy)).points;
        
        while (target.animatePath.length > 0 && (target.animatePath[0].equals(self.x, self.y) || target.animatePath[0].equals(target.x, target.y)))
            target.animatePath.shift();
        
        while (target.animatePath.length > distance)
            target.animatePath.pop();
    }
}

class DisarmingAttackAbility extends Ability {
    public function new() { super("disarming attack", "A successfull hit makes your opponent drop their weapon or armor."); } 

    override public function itemUsage(item:Item, self:Creature, target:Creature):Void {
        apply(self, target, "0d0+0");
    }

    override public function aiUsage(self:Creature): { percent:Float, func:Creature -> Void } {
        return {
            percent: self.nextAttackEffects.length > 0 || !self.hasDice() ? 0 : 0.25,
               func: function(self):Void {
                    var dice = self.getDiceToUseForAbility();
                    doIt(self, dice.number, dice.sides);
               }
        };
    }

    override public function playerUsage(self:Creature):Void {
        self.world.enter(new SelectDiceScreen(self, "What do you want to roll? Your roll vs opposing evasion to disarm.", function(number:Int, sides:Int):Void {
            doIt(self, number, sides);
        }));
    }

    private function doIt(self:Creature, number:Int, sides:Int):Void {
        self.world.addMessage('${self.fullName} uses ${number}d$sides to prepare a disarming attack');
        var amount = number + "d" + sides;
        self.useDice(number, sides);
        self.nextAttackEffects.push(function (self:Creature, target:Creature){
            apply(self, target, amount);
        });
    }

    private function apply(self:Creature, target:Creature, amount:String):Void {
        if (Dice.roll(self.accuracyStat) + Dice.roll(amount) < Dice.roll(target.evasionStat)) {
            self.world.addMessage('${target.fullName} evades ${self.fullName}\'s disarming effect'); // '
            return;
        }
        if (target.meleeWeapon != null) {
            self.world.addItem(target.meleeWeapon, target.x, target.y, target.z);
            self.world.addMessage('the ${target.meleeWeapon.name} is knocked out of ${target.fullName}\'s hands'); // '
            target.meleeWeapon = null;
        } else if (target.rangedWeapon != null) {
            self.world.addItem(target.rangedWeapon, target.x, target.y, target.z);
            self.world.addMessage('the ${target.rangedWeapon.name} is knocked out of ${target.fullName}\'s hands'); // '
            target.rangedWeapon = null;
        } else if (target.armor != null) {
            self.world.addItem(target.armor, target.x, target.y, target.z);
            self.world.addMessage('the ${target.armor.name} is knocked off of ${target.fullName}\'s body'); // '
            target.armor = null;
        }
    }
}

class WoundingAttackAbility extends Ability { 
    public function new() { super("wounding attack", "A successfull hit lowers a stat for several turns."); }

    override public function itemUsage(item:Item, self:Creature, target:Creature):Void {
        apply(self, target, Dice.roll("3d3+0") * 2);
    }

    override public function aiUsage(self:Creature): { percent:Float, func:Creature -> Void } {
        return {
            percent: self.nextAttackEffects.length > 0 || !self.hasDice() ? 0 : 0.75,
               func: function(self):Void {
                    var dice = self.getDiceToUseForAbility();
                    doIt(self, dice.number, dice.sides);
               }
        };
    }

    override public function playerUsage(self:Creature):Void {
        self.world.enter(new SelectDiceScreen(self, "What do you want to roll for duration of the wound?", function(number:Int, sides:Int):Void {
            doIt(self, number, sides);
        }));
    }

    private function doIt(self:Creature, number:Int, sides:Int):Void {
        self.world.addMessage('${self.fullName} uses ${number}d$sides to prepare a wounding attack');
        self.useDice(number, sides);
        self.nextAttackEffects.push(function (self:Creature, target:Creature){
            apply(self, target, Dice.rollExact(number, sides, 0) * 2);
        });
    }

    private function apply(self:Creature, target:Creature, duration:Int):Void {
        var stats = ["accuracy", "evasion", "damage", "resistance"];
        var modifiers = ["2d0+1", "0d2+1", "2d2+0", "1d2+1", "2d1+1", "1d1+2"];

        var wound = { countdown: duration, stat: stats[Math.floor(Math.random() * stats.length)], modifier: modifiers[Math.floor(Math.random() * modifiers.length)] };
        switch (wound.stat) {
            case "accuracy": target.accuracyStat = Dice.add(target.accuracyStat, wound.modifier);
            case "evasion": target.evasionStat = Dice.add(target.evasionStat, wound.modifier);
            case "damage": target.damageStat = Dice.add(target.damageStat, wound.modifier);
            case "resistance": target.resistanceStat = Dice.add(target.resistanceStat, wound.modifier);
        }
        self.world.addMessage('${self.fullName} lowers ${target.fullName}\'s ${wound.stat} by ${wound.modifier} for ${wound.countdown} turns'); // '
        target.addWound(wound);
    }
}

class RapidAttackAbility extends Ability {
    public function new() { super("rapid attack", "A successfull hit causes several free melee attacks on adjacent creatures."); }

    override public function aiUsage(self:Creature): { percent:Float, func:Creature -> Void } {
        return {
            percent: self.nextAttackEffects.length > 0 || !self.hasDice() ? 0 : 0.25,
               func: function(self):Void {
                    var dice = self.getDiceToUseForAbility();
                    doIt(self, dice.number, dice.sides);
               }
        };
    }

    override public function playerUsage(self:Creature):Void {
        self.world.enter(new SelectDiceScreen(self, "What do you want to roll for extra melee attacks?", function(number:Int, sides:Int):Void {
            doIt(self, number, sides);
        }));
    }

    private function doIt(self:Creature, number:Int, sides:Int):Void {
        self.useDice(number, sides);
        self.world.addMessage('${self.fullName} uses ${number}d$sides to prepare a rapid attack');
        self.nextAttackEffects.push(function (self:Creature, target:Creature):Void {
            var attacks = Dice.rollExact(number, sides, 0);
            for (i in 0 ... attacks) {
                var candidates = new Array<Creature>();
                for (offsets in [[-1,-1], [-1,0], [-1,1], [0,-1], [0,1], [1,-1], [1,0], [1,1]]) {
                    var other = self.world.getCreature(self.x + offsets[0], self.y + offsets[1], self.z);
                    if (other != null && other.isAlive)
            candidates.push(other);
                }
                if (candidates.length == 0)
            break;
        self.attack(candidates[Math.floor(Math.random() * candidates.length)]);
            }
        });
    }
}

class SneakAbility extends Ability {
    public function new() { super("sneak", "Become invisible for several turns."); }

    override public function aiUsage(self:Creature): { percent:Float, func:Creature -> Void } {
        return {
            percent: self.nextAttackEffects.length > 0 || !self.hasDice() || !self.isVisible() ? 0 : 0.20,
               func: function(self):Void {
                    var dice = self.getDiceToUseForAbility();
                    doIt(self, dice.number, dice.sides);
               }
        };
    }

    override public function playerUsage(self:Creature):Void {
        self.world.enter(new SelectDiceScreen(self, "What do you want to roll for duration of sneaking?", function(number:Int, sides:Int):Void {
            doIt(self, number, sides);
        }));
    }

    private function doIt(self:Creature, number:Int, sides:Int):Void {
        self.invisibleCounter = Dice.rollExact(number, sides, 0);
        self.useDice(number, sides);
        self.world.addMessage('${self.fullName} uses ${number}d$sides to sneak away');
    }
}

class AccuracyBoostAbility extends Ability {
    public function new() { super("accuracy boost", "Add a positive modifier to your accuracy for the next attack."); }

    override public function aiUsage(self:Creature): { percent:Float, func:Creature -> Void } {
        return {
            percent: self.nextAttackEffects.length > 0 || !self.hasDice() ? 0 : 0.1,
               func: function(self):Void {
                    var dice = self.getDiceToUseForAbility();
                    doIt(self, dice.number, dice.sides);
               }
        };
    }

    override public function playerUsage(self:Creature):Void {
        self.world.enter(new SelectDiceScreen(self, "What do you want to add to your accuracy?", function(number:Int, sides:Int):Void {
            doIt(self, number, sides);
        }));
    }

    private function doIt(self:Creature, number:Int, sides:Int):Void {
        var amount = number + "d" + sides + "+0";
        self.useDice(number, sides);
        self.world.addMessage('${self.fullName} uses ${number}d$sides to boost accuracy');
        self.accuracyStat = Dice.add(self.accuracyStat, amount);
        self.nextAttackEffects.push(function (self:Creature, target:Creature){
            self.accuracyStat = Dice.subtract(self.accuracyStat, amount);
        });
    }
}

class DamageBoostAbility extends Ability {
    public function new() { super("damage boost", "Add a positive modifier to your damage for the next attack."); }

    override public function aiUsage(self:Creature): { percent:Float, func:Creature -> Void } {
        return {
            percent: self.nextAttackEffects.length > 0 || !self.hasDice() ? 0 : 0.1,
               func: function(self):Void {
                    var dice = self.getDiceToUseForAbility();
                    doIt(self, dice.number, dice.sides);
               }
        };
    }

    override public function playerUsage(self:Creature):Void {
        self.world.enter(new SelectDiceScreen(self, "What do you want to add to your damage?", function(number:Int, sides:Int):Void {
            doIt(self, number, sides);
        }));
    }

    private function doIt(self:Creature, number:Int, sides:Int):Void {
        var amount = number + "d" + sides + "+0";
        self.useDice(number, sides);
        self.world.addMessage('${self.fullName} uses ${number}d$sides to boost damage');
        self.damageStat = Dice.add(self.damageStat, amount);
        self.nextAttackEffects.push(function (self:Creature, target:Creature){
            self.damageStat = Dice.subtract(self.damageStat, amount);
        });
    }
}

class MagicMissilesAbility extends Ability {
    public function new() { super("magic missiles", "Cast several magical attacks at random enemies."); }

    override public function aiUsage(self:Creature): { percent:Float, func:Creature -> Void } {
        return {
            percent: self.nextAttackEffects.length > 0 || !self.hasDice() ? 0 : 0.2,
               func: function(self):Void {
                    var dice = self.getDiceToUseForAbility();
                    doIt(self, dice.number, dice.sides);
               }
        };
    }

    override public function playerUsage(self:Creature):Void {
        self.world.enter(new SelectDiceScreen(self, "How many missiles do you want to cast?", function(number:Int, sides:Int):Void {
            doIt(self, number, sides);
        }));
    }

    private function doIt(self:Creature, number:Int, sides:Int):Void {
        self.useDice(number, sides);
        var count = Dice.rollExact(number, sides, 0);
        self.world.addMessage('${self.fullName} uses ${number}d$sides to cast $count magic missiles');
        for (i in 0 ... count) {
            var candidates = new Array<Creature>();
            for (c in self.world.creatures) {
                if (self.canSee(c) && self.glyph != c.glyph)
                    candidates.push(c);
            }
            if (candidates.length == 0) {
                break;
            } else {
                var target = candidates[Math.floor(Math.random() * candidates.length)];
                var p = new Projectile(self.x, self.y, self.z, target.x, target.y, self, "magic missile", "*", Color.hsv(180, 90, 90));
                p.accuracyStat = self.accuracyStat;
                p.damageStat = self.damageStat;
                self.world.addProjectile(p);
            }
        }
    }
}

class OrbOfPainAbility extends Ability {
    public function new() { super("orb of pain", "Cast a powerfull projectile with a bost to accuracy and damage."); }

    override public function aiUsage(self:Creature): { percent:Float, func:Creature -> Void } {
        var here = new IntPoint(self.x, self.y);
        var target = new IntPoint(self.world.player.x, self.world.player.y);
        var dice = self.getDiceToUseForAbility();

        if (dice == null || here.distanceTo(target) > 10)
            return { percent: 0.0, func: function(self):Void { } };

        var points = Bresenham.line(self.x, self.y, target.x, target.y).points;
        points.shift();
        for (p in points) {
            var other = self.world.getCreature(p.x, p.y, self.z);
            if (other != null && other.glyph != "@")
                return { percent: 0.0, func: function(self):Void { } };
        }

        return { 
            percent: 0.2,
               func: function(self):Void {
                    doIt(self, dice.number, dice.sides, target.x, target.y);
               }
        };
    }

    override public function playerUsage(self:Creature):Void {
        self.world.enter(new SelectDiceScreen(self, "What do you want to add to accuracy and damage?", function(number:Int, sides:Int):Void {
            self.world.enter(new AimScreen(self, 10, function(tx:Int, ty:Int):Void {
                doIt(self, number, sides, tx, ty);
            }));
        }));
    }

    private function doIt(self:Creature, number:Int, sides:Int, tx:Int, ty:Int):Void {
        self.useDice(number, sides);
        var bonus = number + "d" + sides + "+0";
        self.world.addMessage('${self.fullName} uses ${number}d$sides to cast an orb of pain');
        var p = new Projectile(self.x, self.y, self.z, tx, ty, self, "orb of pain", "*", Color.hsv(300, 90, 90));
        p.accuracyStat = Dice.add(self.accuracyStat, bonus);
        p.damageStat = Dice.add(self.damageStat, bonus);
        self.world.addProjectile(p);
    }
}

class ExplosionAbility extends Ability {
    public function new() { super("explosion", "Cast a firey explosion that affects a wide area."); }

    override public function aiUsage(self:Creature): { percent:Float, func:Creature -> Void } {
        var here = new IntPoint(self.x, self.y);
        var target = new IntPoint(self.world.player.x, self.world.player.y);
        var dice = self.getDiceToUseForAbility();

        if (dice == null || here.distanceTo(target) > 20)
            return { percent: 0.0, func: function(self):Void { } };

        var roll = Dice.rollExact(dice.number, dice.sides, 0);

        if (here.distanceTo(target) < roll)
            return { percent: 0.0, func: function(self):Void { } };

        return { 
            percent: 0.2,
               func: function(self):Void {
                    doIt(self, dice.number, dice.sides, roll, target.x, target.y);
               }
        };
    }

    override public function playerUsage(self:Creature):Void {
        self.world.enter(new SelectDiceScreen(self, "How large of an explosion do you want?", function(number:Int, sides:Int):Void {
            var radius = Dice.rollExact(number, sides, 0);
            self.world.enter(new AimScreen(self, 20, function(tx:Int, ty:Int):Void {
                doIt(self, number, sides, radius, tx, ty);
            }));
        }));
    }

    private function doIt(self:Creature, number:Int, sides:Int, radius:Int, tx:Int, ty:Int):Void {
        self.useDice(number, sides);
        self.world.addMessage('${self.fullName} uses ${number}d$sides to cast an explosion');
        for (ox in -radius ... radius+1)
        for (oy in -radius ... radius+1) {
            if (ox*ox+oy*oy > radius*radius || Math.random() < 0.1)
                continue;
            self.world.addFire(tx+ox, ty+oy, self.z);
        }
    }
}

class IntimidateAbility extends Ability {
    public function new() { super("intimidate", "Freighten all enemies who see you"); } 

    override public function itemUsage(item:Item, owner:Creature, other:Creature):Void {
        apply(owner, Dice.roll("3d3+0"));
    }

    override public function aiUsage(self:Creature): { percent:Float, func:Creature -> Void } {
        return {
            percent: self.nextAttackEffects.length > 0 || !self.hasDice() || self.isSentient ? 0 : 0.10,
               func: function(self):Void {
                    var dice = self.getDiceToUseForAbility();
                    doIt(self, dice.number, dice.sides);
               }
        };
    }

    override public function playerUsage(self:Creature):Void {
        self.world.enter(new SelectDiceScreen(self, "What do you want the duration to be?", function(number:Int, sides:Int):Void {
            doIt(self, number, sides);
        }));
    }

    private function doIt(self:Creature, number:Int, sides:Int):Void {
        self.useDice(number, sides);
        var duration = Dice.rollExact(number, sides, 0);
        self.world.addMessage('${self.fullName} uses ${number}d$sides to intimidate enemies for $duration turns');
        apply(self, duration);
    }

    private function apply(self:Creature, duration:Int):Void {
        for (c in self.world.creatures) {
            if (c.canSee(self) && c.glyph != "@") {
                c.fearCounter = duration;
            }
        }
    }
}

class SootheAbility extends Ability {
    public function new() { super("soothe", "Put all enemies who see you to sleep"); }

    override public function aiUsage(self:Creature): { percent:Float, func:Creature -> Void } {
        return {
            percent: self.nextAttackEffects.length > 0 || !self.hasDice() ? 0 : 0.10,
               func: function(self):Void {
                    var dice = self.getDiceToUseForAbility();
                    doIt(self, dice.number, dice.sides);
               }
        };
    }

    override public function playerUsage(self:Creature):Void {
        self.world.enter(new SelectDiceScreen(self, "What do you want the duration to be?", function(number:Int, sides:Int):Void {
            doIt(self, number, sides);
        }));
    }

    private function doIt(self:Creature, number:Int, sides:Int):Void {
        self.useDice(number, sides);
        var duration = Dice.rollExact(number, sides, 0);
        self.world.addMessage('${self.fullName} uses ${number}d$sides to sooth enemies for $duration turns');
        for (c in self.world.creatures) {
            if (c.canSee(self) && c.glyph != "@") {
                c.sleepCounter = duration;
            }
        }
    }
}

class TurnUndeadAbility extends Ability {
    public function new() { super("turn undead", "Damage all visible ghosts and skeletons"); }

    override public function aiUsage(self:Creature): { percent:Float, func:Creature -> Void } {
        return {
            percent: self.nextAttackEffects.length > 0 || !self.hasDice() || self.isUndead ? 0 : 0.10,
               func: function(self):Void {
                    var dice = self.getDiceToUseForAbility();
                    doIt(self, dice.number, dice.sides);
               }
        };
    }

    override public function playerUsage(self:Creature):Void {
        self.world.enter(new SelectDiceScreen(self, "What do you want the duration to be?", function(number:Int, sides:Int):Void {
            doIt(self, number, sides);
        }));
    }

    private function doIt(self:Creature, number:Int, sides:Int):Void {
        self.useDice(number, sides);
        var duration = Dice.rollExact(number, sides, 0);
        self.world.addMessage('${self.fullName} uses ${number}d$sides to damage ghosts and skeletons for $duration turns');
        self.world.effects.push({
            countdown: duration,
            func: function(turn:Int):Void {
                for (c in self.world.creatures) {
                    if (c.isUndead && self.canSee(c)) {
                        c.takeDamage(Dice.roll(self.pietyStat), self);
                    }
                }
            }
        });
    }
}

class HealingAuraAbility extends Ability {
    public function new() { super("healing aura", "Allies are heald by their piety"); }

    override public function itemUsage(item:Item, owner:Creature, other:Creature):Void {
        apply(owner, 1);
        owner.world.addMessage('${owner.fullName}\'s ${item.name} glows briefly'); // '
    }

    override public function aiUsage(self:Creature): { percent:Float, func:Creature -> Void } {
        var isOk = 1.0 * self.hp / self.maxHp > 0.5;
        return {
            percent: self.nextAttackEffects.length > 0 || !self.hasDice() || isOk ? 0 : 0.25,
               func: function(self):Void {
                    var dice = self.getDiceToUseForAbility();
                    doIt(self, dice.number, dice.sides);
               }
        };
    }

    override public function playerUsage(self:Creature):Void {
        self.world.enter(new SelectDiceScreen(self, "What do you want the duration to be?", function(number:Int, sides:Int):Void {
            doIt(self, number, sides);
        }));
    }

    private function doIt(self:Creature, number:Int, sides:Int):Void {
        self.useDice(number, sides);
        var duration = Dice.rollExact(number, sides, 0);
        self.world.addMessage('${self.fullName} uses ${number}d$sides to heal allies for $duration turns');
        apply(self, duration);
    }

    private function apply(self:Creature, duration:Int):Void {
        self.world.effects.push({
            countdown: duration,
            func: function(turn:Int):Void {
                for (c in self.world.creatures) {
                    if (c.glyph == self.glyph) {
                        c.heal(Dice.roll(c.pietyStat));
                    }
                }
            }
        });
    }
}

class PiousAttackAbility extends Ability {
    public function new() { super("pious attack", "Buff allies accuracy and damage by their piety"); }

    override public function aiUsage(self:Creature): { percent:Float, func:Creature -> Void } {
        return {
            percent: self.nextAttackEffects.length > 0 || !self.hasDice() ? 0 : 0.25,
               func: function(self):Void {
                    var dice = self.getDiceToUseForAbility();
                    doIt(self, dice.number, dice.sides);
               }
        };
    }

    override public function playerUsage(self:Creature):Void {
        self.world.enter(new SelectDiceScreen(self, "What do you want the duration to be?", function(number:Int, sides:Int):Void {
            doIt(self, number, sides);
        }));
    }

    private function doIt(self:Creature, number:Int, sides:Int):Void {
        for (c in self.world.creatures) {
            if (c.glyph == self.glyph) {
                c.accuracyStat = Dice.add(c.accuracyStat, c.pietyStat);
                c.damageStat = Dice.add(c.damageStat, c.pietyStat);
            }
        }
        self.useDice(number, sides);
        var duration = Dice.rollExact(number, sides, 0);
        self.world.addMessage('${self.fullName} uses ${number}d$sides to buff the attack of allies for $duration turns');
        self.world.effects.push({
            countdown: duration,
            func: function(turn:Int):Void {
                if (turn > 0)
                    return;
                for (c in self.world.creatures) {
                    if (c.glyph == self.glyph) {
                        c.accuracyStat = Dice.subtract(c.accuracyStat, c.pietyStat);
                        c.damageStat = Dice.subtract(c.damageStat, c.pietyStat);
                    }
                }
            }
        });
    }
}

class PiousDefenceAbility extends Ability {
    public function new() { super("pious defence", "Buff allies evasion and resistance by their piety"); }

    override public function aiUsage(self:Creature): { percent:Float, func:Creature -> Void } {
        return {
            percent: self.nextAttackEffects.length > 0 || !self.hasDice() ? 0 : 0.25,
               func: function(self):Void {
                    var dice = self.getDiceToUseForAbility();
                    doIt(self, dice.number, dice.sides);
               }
        };
    }

    override public function playerUsage(self:Creature):Void {
        self.world.enter(new SelectDiceScreen(self, "What do you want the duration to be?", function(number:Int, sides:Int):Void {
            doIt(self, number, sides);
        }));
    }

    private function doIt(self:Creature, number:Int, sides:Int):Void {
        for (c in self.world.creatures) {
            if (c.glyph == self.glyph) {
                c.evasionStat = Dice.add(c.evasionStat, c.pietyStat);
                c.resistanceStat = Dice.add(c.resistanceStat, c.pietyStat);
            }
        }
        self.useDice(number, sides);
        var duration = Dice.rollExact(number, sides, 0);
        self.world.addMessage('${self.fullName} uses ${number}d$sides to buff the defences of allies for $duration turns');
        self.world.effects.push({ 
            countdown: duration,
            func: function(turn:Int):Void {
                if (turn > 0)
                    return;
                for (c in self.world.creatures) {
                    if (c.glyph == self.glyph) {
                        c.evasionStat = Dice.subtract(c.evasionStat, c.pietyStat);
                        c.resistanceStat = Dice.subtract(c.resistanceStat, c.pietyStat);
                    }
                }
            }
        });
    }
}

class SmiteAbility extends Ability {
    public function new() { super("smite", "Damage another based on the difference in piety"); }

    override public function itemUsage(item:Item, owner:Creature, other:Creature):Void {
        apply(owner, other, 0, 0);
        owner.world.addMessage('${owner.fullName}\'s ${item.name} glows briefly'); // '
    }

    override public function playerUsage(self:Creature):Void {
        self.world.enter(new SelectDiceScreen(self, "How far from you do you want to smite?", function(number:Int, sides:Int):Void {
            var radius = Dice.rollExact(number, sides, 0);
            self.world.enter(new AimScreen(self, radius, function(tx:Int, ty:Int):Void {
                doIt(self, number, sides, tx, ty);
            }));
        }));
    }

    private function doIt(self:Creature, number:Int, sides:Int, tx:Int, ty:Int):Void {
        self.useDice(number, sides);
        var other = self.world.getCreature(tx, ty, self.z);
        if (other == null) {
            self.world.addMessage('${self.fullName} uses ${number}d$sides to smite nothing in particular');
        } else {
            apply(self, other, number, sides);
        }
    }

    private function apply(self:Creature, other:Creature, number:Int, sides:Int):Void {
        var diff = Dice.roll(self.pietyStat) - Dice.roll(other.pietyStat);
        if (diff > 0) {
            if (number > 0)
                self.world.addMessage('${self.fullName} uses ${number}d$sides to smite ${other.fullName} for ${diff} damage');
            other.takeDamage(diff, self);
        } else if (number > 0) {
            self.world.addMessage('${self.fullName} uses ${number}d$sides to fail to smite ${other.fullName} by ${diff}'); 
        }
    }
}
