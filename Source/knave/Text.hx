package knave;

import StringTools;

class Text {
    public static function sentence(text:String):String {
        text = StringTools.trim(text);
        
        while (text.indexOf("  ") > -1)
            text = StringTools.replace(text, "  ", " ");
        
        text = text.charAt(0).toUpperCase() + text.substr(1);

        for (vowel in ["a", "e", "i", "o", "u"]) {
            text = StringTools.replace(text, " a " + vowel, " an " + vowel);
            text = StringTools.replace(text, "A " + vowel, "An " + vowel);
        }

        var last = text.charAt(text.length -1);
        if (last != "." && last != "!" && last != "?")
            text += ".";

        return text;
    }

    public static function wordWrap(text:String, max:Int):Array<String> {
        var lines = [];
        while (text.length > 0) {
            if (text.length <= max) {
                lines.push(text);
                text = "";
            }
            var cutPoint = max;
            while (cutPoint > 0 && text.charAt(cutPoint) != " ")
                cutPoint--;
            lines.push(text.substr(0, cutPoint));
            text = text.substr(cutPoint);
            while (text.length > 0 && text.charAt(0) == " ")
                text = text.substr(1);
        }
        return lines;
    }

    public static function andList(parts:Array<String>):String {
        if (parts.length == 0)
            return "";
        else if (parts.length == 1)
            return parts[0];
        else if (parts.length == 2)
            return parts.join(" and ");
        else {
            var str = "";
            for (i in 0 ... parts.length) {
                if (i == parts.length - 1)
                    str += "and " + parts[i];
                else
                    str += parts[i] + ", ";
            }
            return str;
        }
    }
}
