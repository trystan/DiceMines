package knave;

import flash.events.KeyboardEvent;

class InputTranslator {

    public var last_keyboard_event:String;

    public function new() {
    }

    public function handleKeyboard(event:KeyboardEvent):Void {
        last_keyboard_event = null;

        var key:String = "";

        // see http://www.dakmm.com/?p=272
        switch (cast(event.keyCode, UInt))
        {
            case 13: key += "enter";
            case 37: key += "left";
            case 38: key += "up";
            case 39: key += "right";
            case 40: key += "down";
            case 32: key += "space";
            case 8: key += "backspace";
            case 9: key += "tab";
            case 27: key += "escape";
            case 16: return; // shift
            case 96: key += "numpad 0";
            case 97: key += "numpad 1";
            case 98: key += "numpad 2";
            case 99: key += "numpad 3";
            case 100: key += "numpad 4";
            case 101: key += "numpad 5";
            case 102: key += "numpad 6";
            case 103: key += "numpad 7";
            case 104: key += "numpad 8";
            case 105: key += "numpad 9";
            default: key += String.fromCharCode(event.charCode);
        }

        if (key.length == 0)
            return;

        last_keyboard_event = key;
    }
}
