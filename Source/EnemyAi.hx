package;

class EnemyAi extends NpcAi {
    public var homeX:Int;
    public var homeY:Int;
    public var homeZ:Int;

    public function new(self:Creature) {
        super(self);

        this.homeX = self.x;
        this.homeY = self.y;
        this.homeZ = self.z;
    }

    override private function doDefault():Void {
        if (homeZ == self.z && (homeX-self.x)*(homeX-self.x)+(homeY-self.y)*(homeY-self.y) > 7*7) {
            goTo(homeX, homeY, homeZ);
        } else {
            self.wander();
        }
    }
}
