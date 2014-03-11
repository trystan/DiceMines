package;

import StringTools;
import knave.Color;
import knave.Bresenham;

class Factory {

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

        return c;
    }

    public static function spider(z:Int):Creature {
        var c = new Creature("s", "spider", 0, 0, 0);
        c.accuracyStat = "5d5+5";
        c.abilities.push(ability("jump"));
        return maybeBig(c, z);
    }

    public static function bear(z:Int):Creature {
        var c = new Creature("b", "bear", 0, 0, 0);
        c.damageStat = "5d5+5";
        c.abilities.push(ability("rapid attack"));
        return maybeBig(c, z);
    }

    public static function ghost(z:Int):Creature {
        var c = new Creature("g", "ghost", 0, 0, 0);
        c.evasionStat = "5d5+5";
        c.abilities.push(ability("sneak"));
        return maybeBig(c, z);
    }

    public static function elemental(z:Int):Creature {
        var c = new Creature("e", "earth elemental", 0, 0, 0, "n");
        c.resistanceStat = "5d5+5";
        c.abilities.push(ability("knock back"));
        return maybeBig(c, z);
    }

    public static function orc(z:Int):Creature {
        var c = new Creature("o", "orc", 0, 0, 0);
        c.rangedWeapon = orcishBow();
        return maybeBig(c, z);
    }

    public static function enemy(z:Int):Creature {
        switch (Math.floor(Math.random() * 5)) {
            case 0: return spider(z);
            case 1: return bear(z);
            case 2: return ghost(z);
            case 3: return elemental(z);
            default: return orc(z);
        }
    }

    public static function enemies(z:Int):Array<Creature> {
        switch (Math.floor(Math.random() * 5)) {
            case 0: 
                var list = new Array<Creature>();
                var count = Math.floor(2 + Math.random() * 5);
                for (i in 0 ... count)
                    list.push(spider(z));
                return list;

            case 1:
                var list = new Array<Creature>();
                var count = Dice.roll("2d2");
                for (i in 0 ... count)
                    list.push(bear(z));
                return list;

            case 2: return [ghost(z)];
            case 3: return [elemental(z)];

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
        var list = [{ name:"crappy bow",    accuracy:"-1d2+0", evasion:"0d0+0", damage:"-1d2+0", resistance:"0d0+0"},
                    { name:"short bow",     accuracy:"2d2+0", evasion:"0d0+0", damage:"1d1+0", resistance:"0d0+0"},
                    { name:"medium bow",    accuracy:"1d2+0", evasion:"0d0+0", damage:"1d2+0", resistance:"0d0+0"},
                    { name:"long bow",      accuracy:"1d1+0", evasion:"0d0+0", damage:"2d2+0", resistance:"0d0+0"},
                    { name:"silver bow",    accuracy:"1d1+5", evasion:"0d0+0", damage:"1d1+5", resistance:"0d0+0"},
                    { name:"heroic bow",    accuracy:"1d1+1", evasion:"0d0+1", damage:"1d1+1", resistance:"0d0+1"}];

        var def = list[Math.floor(Math.random() * list.length)];
        var i = new Item(")", Color.hsv(30, 80, 80), "ranged", def.name);
        i.accuracyStat = def.accuracy;
        i.evasionStat = def.evasion;
        i.damageStat = def.damage;
        i.resistanceStat = def.resistance;
        return i;
    }

    public static function meleeWeapon():Item {
        var list = [{ name:"crappy sword",    accuracy:"-1d2+0", evasion:"0d0+0", damage:"-1d2+0", resistance:"0d0+0"},
                    { name:"short sword",     accuracy:"2d2+0", evasion:"0d0+0", damage:"1d1+0", resistance:"0d0+0"},
                    { name:"medium sword",    accuracy:"1d2+0", evasion:"0d0+0", damage:"1d2+0", resistance:"0d0+0"},
                    { name:"long sword",      accuracy:"1d1+0", evasion:"0d0+0", damage:"2d2+0", resistance:"0d0+0"},
                    { name:"silver sword",    accuracy:"1d1+5", evasion:"0d0+0", damage:"1d1+5", resistance:"0d0+0"},
                    { name:"heroic sword",    accuracy:"1d1+1", evasion:"0d0+1", damage:"1d1+1", resistance:"0d0+1"}];
        
        var def = list[Math.floor(Math.random() * list.length)];
        var i = new Item("|", Color.hsv(180, 20, 80), "melee", def.name);
        i.accuracyStat = def.accuracy;
        i.evasionStat = def.evasion;
        i.damageStat = def.damage;
        i.resistanceStat = def.resistance;
        return i;
    }

    public static function armor():Item {
        var list = [{ name:"crappy armor",    accuracy:"0d0+0", evasion:"-1d2+0", damage:"0d0+0", resistance:"-1d1+0"},
                    { name:"light armor",     accuracy:"0d0+0", evasion:"-1d1+0", damage:"0d0+0", resistance:"1d2+0"},
                    { name:"medium armor",    accuracy:"0d0+0", evasion:"-1d2+0", damage:"0d0+0", resistance:"2d2+0"},
                    { name:"heavy armor",     accuracy:"0d0+0", evasion:"-2d2+0", damage:"0d0+0", resistance:"2d3+0"},
                    { name:"silver armor",    accuracy:"0d0+0", evasion:"-1d1+5", damage:"0d0+0", resistance:"1d1+5"},
                    { name:"heroic armor",    accuracy:"0d0+1", evasion:"-1d1+1", damage:"0d0+1", resistance:"0d0+1"}];

        var def = list[Math.floor(Math.random() * list.length)];
        var i = new Item("[", Color.hsv(90, 40, 80), "armor", def.name);
        i.accuracyStat = def.accuracy;
        i.evasionStat = def.evasion;
        i.damageStat = def.damage;
        i.resistanceStat = def.resistance;
        return i;
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
        return null;
    }

    public static function randomAbility():Ability {
        return abilities[Math.floor(Math.random() * abilities.length)];
    }

    public static var abilities:Array<Ability>;

    public static function init():Void {
        abilities = [
            new Ability("Jump", "Move several spaces at once.", function(world:PlayScreen, self:Creature):Void {
            world.enter(new SelectDiceScreen(world, self, "What do you want to roll for jump distance?", function(number:Int, sides:Int):Void {
                world.enter(new AimScreen(world, self, Dice.rollExact(number, sides, 0), function(tx:Int, ty:Int):Void {
                    self.useDice(number, sides);
                    self.animatePath = Bresenham.line(self.x, self.y, tx, ty).points;
                    self.animatePath.shift();
                    world.addMessage('${self.fullName} jumps');
                }));
            }));
        }),
        new Ability("Knockback", "A successfull hit sends your oppenent back.", function(world:PlayScreen, self:Creature):Void {
            world.enter(new SelectDiceScreen(world, self, "What do you want to roll for knockback distance?", function(number:Int, sides:Int):Void {
                var amount = Dice.rollExact(number, sides, 0);
                self.useDice(number, sides);
                world.addMessage('${self.fullName} prepares a knockback attack');
                world.update();
                self.nextAttackEffects.push(function (self:Creature, target:Creature){
                    var dx = target.x - self.x + Math.random() - 0.5;
                    var dy = target.y - self.y + Math.random() - 0.5;

                    dx *= amount;
                    dy *= amount;

                    target.animatePath = Bresenham.line(target.x, target.y, target.x + Math.floor(dx), target.y + Math.floor(dy)).points;
                    while (target.animatePath.length > amount)
                        target.animatePath.pop();
                });
            }));
        }),
        new Ability("Disarming attack", "A successfull hit makes your opponent drop their weapon or armor.", function(world:PlayScreen, self:Creature):Void {
            world.enter(new SelectDiceScreen(world, self, "What do you want to roll? Your roll vs opposing evasion to disarm.", function(number:Int, sides:Int):Void {
                world.addMessage('${self.fullName} prepares to disarm someone');
                world.update();
                var amount = number + "d" + sides;
                self.useDice(number, sides);
                self.nextAttackEffects.push(function (self:Creature, target:Creature){
                    if (Dice.roll(self.accuracyStat) + Dice.roll(amount) < Dice.roll(target.evasionStat)) {
                        world.addMessage('${target.fullName} evades ${self.fullName}\'s disarming effect'); // '
                        return;
                    }
                    if (target.meleeWeapon != null) {
                        world.addItem(target.meleeWeapon, target.x, target.y, target.z);
                        world.addMessage('the ${target.meleeWeapon.name} is knocked out of ${target.fullName}\'s hands'); // '
                        target.meleeWeapon = null;
                    } else if (target.rangedWeapon != null) {
                        world.addItem(target.rangedWeapon, target.x, target.y, target.z);
                        world.addMessage('the ${target.rangedWeapon.name} is knocked out of ${target.fullName}\'s hands'); // '
                        target.rangedWeapon = null;
                    } else if (target.armor != null) {
                        world.addItem(target.armor, target.x, target.y, target.z);
                        world.addMessage('the ${target.armor.name} is knocked off of ${target.fullName}\'s body'); // '
                        target.armor = null;
                    }
                });
            }));
        }),
        new Ability("wounding attack", "A successfull hit drains a stat for several turns.", function(world:PlayScreen, self:Creature):Void {
            world.enter(new SelectDiceScreen(world, self, "What do you want to roll for duration of the wound?", function(number:Int, sides:Int):Void {
                world.addMessage('${self.fullName} prepares a wounding attack');
                world.update();
                self.useDice(number, sides);
                self.nextAttackEffects.push(function (self:Creature, target:Creature){
                    var stats = ["accuracy", "evasion", "damage", "resistance"];
                    var modifiers = ["-1d0+0", "-2d0+0", "-0d1+0", "-0d2+0", "-1d1+0", "-2d2+0"];

                    var wound = { countdown: Dice.rollExact(number, sides, 0), stat: stats[Math.floor(Math.random() * stats.length)], modifier: modifiers[Math.floor(Math.random() * modifiers.length)] };
                    switch (wound.stat) {
                        case "accuracy": target.accuracyStat = Dice.add(target.accuracyStat, wound.modifier);
                        case "evasion": target.evasionStat = Dice.add(target.evasionStat, wound.modifier);
                        case "damage": target.damageStat = Dice.add(target.damageStat, wound.modifier);
                        case "resistance": target.resistanceStat = Dice.add(target.resistanceStat, wound.modifier);
                    }
                    world.addMessage('${self.fullName} wounds ${target.fullName}\'s ${wound.stat} by ${wound.modifier} for ${wound.countdown} turns'); // '
                    target.wounds.push(wound);
                });
            }));
        }),
        new Ability("rapid attack", "A successfull hit causes several free melee attacks on adjacent creatures.", function(world:PlayScreen, self:Creature):Void {
            world.enter(new SelectDiceScreen(world, self, "What do you want to roll for extra melee attacks?", function(number:Int, sides:Int):Void {
                self.useDice(number, sides);
                world.addMessage('${self.fullName} prepares for a rapid attack');
                world.update();
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
            }));
        }),
        new Ability("sneak", "Become invisible for several turns.", function(world:PlayScreen, self:Creature):Void {
            world.enter(new SelectDiceScreen(world, self, "What do you want to roll for duration of sneaking?", function(number:Int, sides:Int):Void {
                self.invisibleCounter = Dice.rollExact(number, sides, 0);
                self.useDice(number, sides);
                world.addMessage('${self.fullName} sneaks away');
                world.update();
            }));
        }),
        new Ability("accuracy boost", "Add a positive modifier to your accuracy for the next attack.", function(world:PlayScreen, self:Creature):Void {
            world.enter(new SelectDiceScreen(world, self, "What do you want to add to your accuracy?", function(number:Int, sides:Int):Void {
                var amount = number + "d" + sides + "+0";
                self.useDice(number, sides);
                world.addMessage('${self.fullName} focuses on accuracy');
                world.update();
                self.accuracyStat = Dice.add(self.accuracyStat, amount);
                self.nextAttackEffects.push(function (self:Creature, target:Creature){
                    self.accuracyStat = Dice.subtract(self.accuracyStat, amount);
                });
            }));
        }), 
        new Ability("damage boost", "Add a positive modifier to your damage for the next attack.", function(world:PlayScreen, self:Creature):Void {
            world.enter(new SelectDiceScreen(world, self, "What do you want to add to your damage?", function(number:Int, sides:Int):Void {
                var amount = number + "d" + sides + "+0";
                self.useDice(number, sides);
                world.addMessage('${self.fullName} focuses on damage');
                world.update();
                self.damageStat = Dice.add(self.damageStat, amount);
                self.nextAttackEffects.push(function (self:Creature, target:Creature){
                    self.damageStat = Dice.subtract(self.damageStat, amount);
                });
            }));
        }),
        new Ability("magic missiles", "Cast several magical attacks at random enemies.", function(world:PlayScreen, self:Creature):Void {
            world.enter(new SelectDiceScreen(world, self, "How many missiles do you want to cast?", function(number:Int, sides:Int):Void {
                self.useDice(number, sides);
                var count = Dice.rollExact(number, sides, 0);
                for (i in 0 ... count) {
                    var candidates = new Array<Creature>();
                    for (c in world.creatures) {
                        if (self.canSee(c) && self.glyph != c.glyph)
                            candidates.push(c);
                    }
                    if (candidates.length == 0)
                        break;
                    else {
                        var target = candidates[Math.floor(Math.random() * candidates.length)];
                        var p = new Projectile(self.x, self.y, self.z, target.x, target.y, self, "*", Color.hsv(180, 90, 90));
                        p.accuracyStat = self.accuracyStat;
                        p.damageStat = self.damageStat;
                        self.world.addProjectile(p);
                    }
                }
                world.update();
            }));
        }),
        new Ability("pain orb", "Cast a powerfull projectile with a bost to accuracy and damage.", function(world:PlayScreen, self:Creature):Void {
            world.enter(new SelectDiceScreen(world, self, "What do you want to add to accuracy and damage?", function(number:Int, sides:Int):Void {
                world.enter(new AimScreen(world, self, 10, function(tx:Int, ty:Int):Void {
                    self.useDice(number, sides);
                    var bonus = number + "d" + sides + "+0";
                    var p = new Projectile(self.x, self.y, self.z, tx, ty, self, "*", Color.hsv(300, 90, 90));
                    p.accuracyStat = Dice.add(self.accuracyStat, bonus);
                    p.damageStat = Dice.add(self.damageStat, bonus);
                    self.world.addProjectile(p);
                }));
            }));
        }),
        new Ability("explosion", "Cast a firey explosion that affects a wide area.", function(world:PlayScreen, self:Creature):Void {
            world.enter(new SelectDiceScreen(world, self, "How large of an explosion do you want?", function(number:Int, sides:Int):Void {
                world.enter(new AimScreen(world, self, 20, function(tx:Int, ty:Int):Void {
                    self.useDice(number, sides);
                    var radius = Dice.rollExact(number, sides, 0);
                    for (ox in -radius ... radius+1)
                    for (oy in -radius ... radius+1) {
                        if (ox*ox+oy*oy > radius*radius || Math.random() < 0.1)
                            continue;
                        self.world.addFire(tx+ox, ty+oy, self.z);
                    }
                }));
            }));
        })];
    }
}
