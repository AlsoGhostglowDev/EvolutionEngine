package funkin.game.objects;

class HUD extends FlxSpriteGroup implements IBeatListener {
    public function beatHit(curBeat:Int):Void {}
    public function stepHit(curStep:Int):Void {}
    public function measureHit(curMeasure:Int):Void {}
}