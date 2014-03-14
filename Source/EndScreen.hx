package;

import flash.net.SharedObject;
import knave.Screen;
import knave.AsciiDisplay;
import knave.Color;

class EndScreen extends Screen {
    private var playScreen:PlayScreen;

    public function new(playScreen:PlayScreen){
        super();

        this.playScreen = playScreen;

        on("enter", function():Void { 
            switchTo(new WorldGenScreen());
        });
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
            "buy a horse";
        else if (points > 25)
            "buy a sandwich";
        else
            "buy half a sandwich";

        if (playScreen.player.z < 0)
            display.writeCenter('you escape the mines with enough dice to $outcome. ($points total sides)', 2, fg);
        else
            display.writeCenter('you died in the mines with enough dice to $outcome. ($points total sides)', 2, fg);

        var so = loadScores();
        so.data.scores.push({ points: points, text: "testing" });
        saveScores(so);

        var y = 6;
        for (score in cast(so.data.scores, Array<Dynamic>)) {
            display.writeCenter(score.points + "  " + score.text, y++, fg);
        }

        display.writeCenter("-- press [enter] to restart --", 4, fg);
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
