package scenes;

class GameScene extends h2d.Scene
{
    var elapsedTime(default,null):Float;
    var game(default,null):Game;
    var graphics(default,null):h2d.Graphics;

    public function new (game:Game)
    {
        super();
        this.elapsedTime = 0;
        this.game = game;
        this.graphics = new h2d.Graphics(this);

        this.scaleMode = ScaleMode.LetterBox(400,400,true);
    }

    public function getElapsedTime () :Float return this.elapsedTime;
    public function getGame () :Game return this.game;
    public function getGraphics () :h2d.Graphics return this.graphics;

    public function sceneRender () :Void this.graphics = new h2d.Graphics(this);
    public function sceneUpdate (dt:Float) :Void this.elapsedTime += dt;
    public function tick (dt:Float) :Void
    {
        this.sceneUpdate(dt);
        this.sceneRender();
    }
}