package;

import flash.net.SharedObject;
import knave.*;

class EndScreen extends Screen {
    private var playScreen:PlayScreen;

    public function new(playScreen:PlayScreen){
        super();

        this.playScreen = playScreen;

        on("enter", switchTo, new SelectPartyScreen());
        on("draw", draw);
    }

    private function draw(display:AsciiDisplay):Void {
        display.clear();
        playScreen.draw(display);

        var fg = Color.hsv(60, 90, 90).toInt();
        var bg = new Color(0,0,0);

        var points = 0;
        for (i in 0 ... playScreen.player.dice.length)
            points += playScreen.player.dice[i] * i;

        var outcome = if (points > 1000)
            "help rebuild civilization";
        else if (points > 800)
            "help rebuild your hometown";
        else if (points > 600)
            "help rebuild your home";
        else if (points > 400)
            "start an adventurers guild";
        else if (points > 200)
            "write a book about your travels";
        else if (points > 100)
            "buy better equipment";
        else if (points > 50)
            "buy a nice meal";
        else if (points > 25)
            "buy a sandwich";
        else
            "buy half a sandwich";

        var partyName = if (playScreen.world.heroParty.length == 1)
            "just " + playScreen.player.name;
        else
            playScreen.player.name + " and " + playScreen.player.world.heroParty.length + " others";

        partyName = Text.sentence(partyName);

        if (playScreen.player.z < 0)
            display.writeCenter(Text.sentence('you escaped with enough dice to $outcome. ($points total sides)'), 2, fg);
        else
            display.writeCenter(Text.sentence('you died with enough dice to $outcome. ($points total sides)'), 2, fg);

        var entry = { points: points, text: '${Date.now().toString()} - $partyName' };
        var so = loadScores();
        var insertAt = -0;
        for (i in 0 ... so.data.scores.length) {
            if (so.data.scores[i].points < points) {
                insertAt = i;
                break;
            }
        }
        if (insertAt == -1)
            so.data.scores.push(entry);
        else
            so.data.scores.insert(insertAt, entry);
        saveScores(so);

        var x = 15;
        var y = 6;
        var listed = 0;
        for (score in cast(so.data.scores, Array<Dynamic>)) {
            display.write(score.text, x, y, fg);
            display.write(StringTools.lpad(score.points, ' ', 5) + ' sides', x + 55, y, fg);
            y++;
            if (++listed == 10)
                break;
        }

        y++;
        display.writeCenter("-- press [enter] to restart --", y++, fg);
        display.update();
    }

    private function loadScores():SharedObject {
        var so = SharedObject.getLocal("highscores");
        if (so.data.scores == null)
            so.data.scores = new Array<{ points:Int, text:String }>();
        return so;
    }

    private function saveScores(so:SharedObject):Void {
        try
        {
            so.flush();
        }
        catch (e: Dynamic) {
            trace("Couldn't save highscores");
        }
    }
} 
