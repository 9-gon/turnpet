class Turnpet extends h2d.Object
{
    var tName(default,null):String;

    var height(default,null):Int;
    var width(default,null):Int;

    var body(default,null):Int;
    var color(default,null):Int;
    var eyes(default,null):Int;
    var leaf(default,null):Int;

    var bodyAnim(default,null):h2d.Anim;
    var eyesAnim(default,null):h2d.Anim;
    var leafAnim(default,null):h2d.Anim;
    var trumpetAnim(default,null):h2d.Anim;

    var happy:Float;
    var maxHappy:Int = 1000;

    var cash:Int;
    var maxCash:Int = 1000; // divide by 100 when displaying

    var state:TurnpetState;
    var pastState:TurnpetState;
    var texture:h3d.mat.Texture;
    var game:Game;

    var timeStart:Float;
    var timeEnd:Float;
    var ranTicker:Int=0;

    var angle:Float;

    var trumpet:Bool;
    var playing:Bool=false;

    public function new (data:Dynamic /*hehe sloppy*/,g:Game,parent:scenes.GameScene)
    {
        super(parent);
        this.game = g;

        this.changeData(data);

        this.cash = (data.cash < 0 || data.cash > this.maxCash) ? 0 : data.cash;
        this.happy = (data.happy < 0 || data.happy > this.maxHappy) ? 0 : data.happy;

        this.trumpet = data.trumpet;

        this.height = 40;
        this.width = 40;
        this.state = TurnpetState.IDLE;
        this.pastState = this.state;
    }

    public function checkAnims () :Void
    {
        if (this.pastState!=this.state) 
        {


        this.removeChild(this.bodyAnim);
        this.removeChild(this.eyesAnim);
        this.removeChild(this.leafAnim);
        this.removeChild(this.trumpetAnim);

            switch (this.state)
        {
            case IDLE:
                this.bodyAnim = new h2d.Anim(
                    [
                        this.game.getTiles()[0][this.body],
                        this.game.getTiles()[1][this.body]
                    ]
                ,2,this);
                this.eyesAnim = new h2d.Anim(
                    [
                        this.game.getTiles()[7][this.eyes],
                        this.game.getTiles()[8][this.eyes]
                    ]
                ,2,this);
                this.leafAnim = new h2d.Anim(
                    [
                        this.game.getTiles()[14][this.leaf],
                        this.game.getTiles()[15][this.leaf]
                    ]
                ,2,this);
            case WALKING:
                this.bodyAnim = new h2d.Anim(
                    [
                        this.game.getTiles()[2][this.body],
                        this.game.getTiles()[3][this.body]
                    ]
                ,2,this);
                this.eyesAnim = new h2d.Anim(
                    [
                        this.game.getTiles()[9][this.eyes],
                        this.game.getTiles()[10][this.eyes]
                    ]
                ,2,this);
                this.leafAnim = new h2d.Anim(
                    [
                        this.game.getTiles()[16][this.leaf],
                        this.game.getTiles()[17][this.leaf]
                    ]
                ,2,this);
            case TRUMPET:
                this.bodyAnim = new h2d.Anim(
                    [
                        this.game.getTiles()[4][this.body],
                        this.game.getTiles()[5][this.body],
                        this.game.getTiles()[6][this.body],
                        this.game.getTiles()[5][this.body]
                    ]
                ,2,this);
                this.eyesAnim = new h2d.Anim(
                    [
                        this.game.getTiles()[11][this.eyes],
                        this.game.getTiles()[12][this.eyes],
                        this.game.getTiles()[13][this.eyes],
                        this.game.getTiles()[12][this.eyes]
                    ]
                ,2,this);
                this.leafAnim = new h2d.Anim(
                    [
                        this.game.getTiles()[18][this.leaf],
                        this.game.getTiles()[19][this.leaf],
                        this.game.getTiles()[20][this.leaf],
                        this.game.getTiles()[19][this.leaf]
                    ]
                ,2,this);
                this.trumpetAnim = new h2d.Anim(
                    [
                        this.game.getTiles()[21][0],
                        this.game.getTiles()[22][0],
                        this.game.getTiles()[23][0],
                        this.game.getTiles()[22][0]
                    ]
                ,2,this);
            default:
        }}
        
        if (0!=this.color) this.bodyAnim.adjustColor({hue:this.color*Math.PI/6});
    }

    public function changeData (data:Dynamic) :Void
    {
        this.tName = (data.name.length < 0 || data.name.length > 12) ? "Turnpet" : data.name;
        this.body = (data.body < 0 || data.body > 2) ? 0 : data.body;
        this.color = (data.color < 0 || data.color > 11) ? 0 : data.color;
        this.eyes = (data.eyes < 0 || data.eyes > 2) ? 0 : data.eyes;
        this.leaf = (data.leaf < 0 || data.leaf > 2) ? 0 : data.leaf;

        this.removeChild(this.bodyAnim);
        this.removeChild(this.eyesAnim);
        this.removeChild(this.leafAnim);

                this.bodyAnim = new h2d.Anim(
                    [
                        this.game.getTiles()[0][this.body],
                        this.game.getTiles()[1][this.body]
                    ]
                ,2,this);
                this.eyesAnim = new h2d.Anim(
                    [
                        this.game.getTiles()[7][this.eyes],
                        this.game.getTiles()[8][this.eyes]
                    ]
                ,2,this);
                this.leafAnim = new h2d.Anim(
                    [
                        this.game.getTiles()[14][this.leaf],
                        this.game.getTiles()[15][this.leaf]
                    ]
                ,2,this);
        
        if (0!=this.color) this.bodyAnim.adjustColor({hue:this.color*Math.PI/6});
    }

    public function addCash (cash:Int) :Void this.cash = (this.maxCash < cash + this.cash) ? this.maxCash : this.cash + cash;
    public function addHappy (happy:Float) :Void this.happy = (this.maxHappy < happy + this.happy) ? this.maxHappy : this.happy + happy;

    public function decay () :Void this.happy -= 2;

    public function getCash () :Int return this.cash;
    public function getHappiness () :Float return this.happy;
    public function getHeight () :Int return this.height;
    public function getName () :String return this.tName;
    public function getWidth () :Int return this.width;

    function setState (state:TurnpetState) :Void
    {
        this.pastState = this.state;
        this.state = state;
        this.checkAnims();
    }

    public function update () :Void
    {
        if (!this.trumpet)
        {
            // "ai" decision making
            ++this.ranTicker;
            if (9==this.ranTicker)
            {
                this.ranTicker = 0;
                var ran:Float = Math.random() * 5;
                if (1>ran&&TurnpetState.WALKING!=this.state)
                {
                    this.setState(TurnpetState.WALKING);
                    this.angle = Math.random() * Math.PI * 2;

                    this.timeStart = cast(this.parent,scenes.GameScene).getElapsedTime();
                    this.timeEnd = this.timeStart + 3.;
                }
            }

            // ai movement
            if (TurnpetState.WALKING==this.state)
            {
                if (2==this.ranTicker%3) this.angle += Math.random() * Math.PI / 8 * (Math.random() - 0.5);
                this.x += Math.cos(this.angle) * .5;
                this.y += Math.sin(this.angle) * .5;
                
                this.x = (0>this.x) ? 0 : (360<this.x) ? 360 : this.x;
                this.y = (0>this.y) ? 0 : (360<this.y) ? 360 : this.y;
            }

            if (TurnpetState.IDLE!=this.state&&this.timeEnd<cast(this.parent,scenes.GameScene).getElapsedTime()) this.setState(TurnpetState.IDLE);
        }
        else 
        {
            if (!this.playing)
            {
                this.setState(TurnpetState.TRUMPET);
                var subject = new msg.Subject();
                subject.addObserver(new msg.Observer.AudioObserver());
                subject.notify(this,msg.TpetEvent.TRUMPET);
                playing = true;
            }
        }

        if (cast(this.parent,scenes.GameScene).getGame().getSaveData().cash!=this.cash)
        {
            var c = cast(this.parent,scenes.GameScene).getGame().getSaveData().cash;
            var h = cast(this.parent,scenes.GameScene).getGame().getSaveData().happy;
            this.cash = (1000<c) ? 1000 : c;
            this.happy = (1000<h) ? 1000 : h;
            this.trumpet = cast(this.parent,scenes.GameScene).getGame().getSaveData().trumpet;
            hxd.File.saveBytes("save.json",haxe.io.Bytes.ofString(haxe.Json.stringify(
                {
                    body:this.body,
                    eyes:this.eyes,
                    leaf:this.leaf,
                    name:this.tName,
                    color:this.color,
                    cash:this.cash,
                    happy:this.happy,
                    trumpet:this.trumpet
                }
            )));
        }
    }
}

enum TurnpetState
{
    IDLE;
    WALKING;
    TRUMPET;
}