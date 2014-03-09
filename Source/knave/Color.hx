package knave;

class Color {
    public var r:Int;
    public var g:Int;
    public var b:Int;

    public function new(r:Int, g:Int, b:Int) {
        this.r = r;
        this.g = g;
        this.b = b;
    }

    public static function hsv(h:Float, s:Float, v:Float):Color {
        var r:Float, g:Float, b:Float, i:Float, f:Float, p:Float, q:Float, t:Float;
        h %= 360;
        if (v == 0) 
            return new Color(0, 0, 0);

        s /= 100;
        v /= 100;
        h /= 60;
        i = Math.floor(h);
        f = h - i;
        p = v * (1 - s);
        q = v * (1 - (s * f));
        t = v * (1 - (s * (1 - f)));

        switch (i)
        {
            case 0: r = v; g = t; b = p;
            case 1: r = q; g = v; b = p;
            case 2: r = p; g = v; b = t;
            case 3: r = p; g = q; b = v;
            case 4: r = t; g = p; b = v;
            default: r = v; g = p; b = q;
        }

        return new Color(Math.floor(r*255), Math.floor(g*255), Math.floor(b*255));
    }

    public function toInt():Int {
        return 0xff000000 | (r << 16) | (g << 8) | b;
    }

    public function darker(amount:Int = 4):Color {
        return new Color(Math.floor(Math.max(0, r - amount)), Math.floor(Math.max(0, g - amount)), Math.floor(Math.max(0, b - amount)));
    }

    public function lighter(amount:Int = 4):Color {
        return new Color(Math.floor(Math.min(255, r + amount)), Math.floor(Math.min(255, g + amount)), Math.floor(Math.min(255, b + amount)));
    }

    public function lerp(other:Color, percent:Float):Color {
        return new Color(lerp1(r, other.r, percent), lerp1(g, other.g, percent), lerp1(b, other.b, percent));
    }

    private function lerp1(a:Int, b:Int, p:Float):Int {
        if (p == 0)
            return a;
        else if (p == 1)
            return b;
        else
            return Math.floor(a + (b - a) * p);
    }
}

