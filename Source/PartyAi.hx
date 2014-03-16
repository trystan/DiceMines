package;

import knave.IntPoint;
import knave.Text;

class PartyAi {
    private var party:Array<Creature>;
    private var world:World;
    private var isWorldgen:Bool = true;

    private var explainedTopics:Array<String>;

    public function new(party:Array<Creature>) {
        this.party = party;
        explainedTopics = new Array<String>();
    }

    public function explain(topic:String, lore:Float, text:String):Void {
        if (Lambda.indexOf(explainedTopics, topic) != -1)
            return;

        explainedTopics.push(topic);
        var candidates = new Array<Creature>();
        for (hero in party) {
            if (hero == world.player || !hero.isAlive || hero.z != world.player.z)
                continue;
            if (Math.random() > hero.extroversion)
                continue;
            if (lore > hero.lore)
                continue;
            candidates.push(hero);
        }

        if (candidates.length == 0)
            return;

        candidates[Math.floor(Math.random() * candidates.length)].say(text, true);
    }

    public function helpful(target:Creature, text:String):Void {
        var candidates = new Array<Creature>();
        for (hero in party) {
            if (hero == world.player || !hero.isAlive || hero.z != world.player.z || hero == target)
                continue;
            if (Math.random() > hero.extroversion)
                continue;
            if (Math.random() > hero.helpfulness)
                continue;
            candidates.push(hero);
        }

        if (candidates.length == 0)
            return;

        candidates[Math.floor(Math.random() * candidates.length)].say(text, true);
    }

    public function aggressive(target:Creature, text:String):Void {
        var candidates = new Array<Creature>();
        for (hero in party) {
            if (hero == world.player || !hero.isAlive || hero.z != world.player.z || hero == target)
                continue;
            if (Math.random() > hero.extroversion)
                continue;
            if (Math.random() > hero.aggresiveness)
                continue;
            candidates.push(hero);
        }

        if (candidates.length == 0)
            return;

        candidates[Math.floor(Math.random() * candidates.length)].say(text, true);
    }

    public function greedy(target:Creature, text:String):Void {
        var candidates = new Array<Creature>();
        for (hero in party) {
            if (hero == world.player || !hero.isAlive || hero.z != world.player.z || hero == target)
                continue;
            if (Math.random() > hero.extroversion)
                continue;
            if (Math.random() > hero.greed)
                continue;
            candidates.push(hero);
        }

        if (candidates.length == 0)
            return;

        candidates[Math.floor(Math.random() * candidates.length)].say(text, true);
    }

    public function onUpdate(world:World):Void {
        isWorldgen = false;
        this.world = world;

        if (Math.random() > 0.01)
            return;

        switch(Math.floor(Math.random() * 32)) {
            case 0: explain("save dice", 0.5, "I like to save my dice so I can do really big things with them.");
            case 1: explain("use dice", 0.5, "Why hoard dice? You them when you can.");
            case 2: explain("accuracy", 0.5, "Some say damage is importatnt but I think accuracy is even more important.");
            case 3: explain("damage", 0.5, "Having a high damage stat is the most important thing for a fighter.");
            case 4: explain("evasion", 0.5, "Evasion is where it's at - you can't die if they can't hit you.");
            case 5: explain("resistance", 0.5, "Some day my resistance stat will be so high that I won't even need armor.");
            case 6: explain("piety", 0.5, "Piety isn't often useful, but a lot of holy abilities are based on your piety stat.");
            case 7: explain("orcs", 0.6, "The land's haven't been the same since the orcs started invading.");
            case 8: explain("arachnids", 0.6, "Keep a look out for arachnids. They can jump out when you least expect them.");
            case 9: explain("dice1", 0.7, "Some say the world is running out of dice....");
            case 10: explain("dice2", 0.7, "I thought there would bemore dice down here.");
            case 11: explain("dice3", 0.7, "This used to be the most productive dice mine around.");
            case 12: explain("dice4", 0.7, "What happened to all the dice miners?");
            case 13: explain("motives1", 0.1, "I need to bring back some dice to help my family.");
            case 14: explain("motives2", 0.9, "If I get enough dice, I can forge a magic sword.");
            case 15: explain("motives3", 0.1, "With enough dice, I can retire from dice farming.");
            case 16: explain("motives4", 0.1, "I love adventuring.");
            case 17: explain("motives5", 0.1, "Is anyone else having as much fun as I am?");
            case 18: explain("advice1", 0.75, "My dad always told me to press [v] and watch what my firends are doing.");
            case 19: explain("advice2", 0.75, "My mom always told me to keep an eye on the hp and floor of my party members.");
            case 20: explain("advice3", 0.80, "It's important to travel with a party that has someone with healing skills.");
            case 21: explain("advice4", 0.80, "Groups that don't have a wizzard rarely get far.");
            case 22: explain("advice5", 0.80, "Sometimes choosing people based on their personality is more important than their stats.");
            case 23: explain("advice6", 0.80, "Many parties have failed because everyone was too greedy or aggressive.");
            case 24: explain("advice7", 0.80, "A good leader knows which way to point and where others will go.");
            case 25: explain("advice8", 0.80, "A party of one is still a party. A sad lonely party.");
            case 26: explain("advice9", 0.80, "Light weapons are good for accuracy; heavy are good for damage.");
            case 27: explain("advice10", 0.80, "Light armors are good for evasion; heavy are good for resistance.");
            case 28: explain("advice11", 0.80, "Silver items have decent stats but a high bonus.");
            case 29: explain("advice12", 0.80, "Unholy items are really strong. Just hope no one uses a priestly power.");
            case 30: explain("advice13", 0.80, "You don't want to have unholy equipment when someone uses healing aura....");
            case 31: explain("advice14", 0.80, "Bows shoot far away things but tend to go off course.");
        }
    }

    public function onCreatureDied(other:Creature, attacker:Creature):Void {
        if (isWorldgen) return;

        if (other.isHero())
            explain(other.name, 0.25, "Bye bye " + other.name);
        else
            helpful(attacker, "Good job " + attacker.name + "!");

        if (attacker != null && other.isHero() && attacker.isHero())
            helpful(attacker, "Well that wasn't very nice " + attacker);
    }

    public function onCreatureSpotted(other:Creature):Void {
        if (isWorldgen) return;

        switch (other.glyph) {
            case "a": explain(other.name, 0.25, 'look! a ${other.name}! They can jump long distances and are very accurate.');
            case "g": explain(other.name, 0.25, 'look! a ${other.name}! They can disappear and fly and are very hard to hit.');
            case "o": explain(other.name, 0.25, 'look! a ${other.name}! They shoot bows and travel in groups.');
        }

        if (other.glyph == other.glyph.toUpperCase())
            explain("giants", 0.0, 'Look! a giant! They can knock you back and are stronger than regular sized creatues.');

        aggressive(other, "All right! A " + other.name);
    }

    public function onItemSpotted(item:Item, position:IntPoint):Void {
        if (isWorldgen) return;
        if (item.type == "dice")
            explain("dice", 0.0, 'Look! Dice! We need to gather dice to use our special abilities.');
        else
            helpful(null, 'look! a ${item.name}!');
    }

    public function onItemPickedUp(item:Item, position:IntPoint, other:Creature):Void {
        if (isWorldgen) return;
    }

    public function onItemDropped(item:Item, position:IntPoint, dropper:Creature):Void {
        if (isWorldgen) return;
    }
}
