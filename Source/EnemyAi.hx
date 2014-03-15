package;

class EnemyAi extends NpcAi {
    public var homeX:Int;
    public var homeY:Int;
    public var homeZ:Int;

    public function new(self:Creature) {
        super(self);
    }

    override private function doDefault():Void {
        if (homeX == 0 && self.x != 0) {
            this.homeX = self.x;
            this.homeY = self.y;
            this.homeZ = self.z;
        }

        if (homeZ == self.z && (homeX-self.x)*(homeX-self.x)+(homeY-self.y)*(homeY-self.y) > 7*7) {
            goTo(homeX, homeY, homeZ);
        } else {
            self.wander();
        }
    }
}
