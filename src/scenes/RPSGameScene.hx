package scenes;

class RPSGameScene extends GameScene
{
    var userSelects:Array<ActionSelect>;
    var compSelect:ActionSelect;

    var back:SButton;

    var set:Bool;
    var won:Int;

    var selMade:Bool;

    var msg:String;

    var leaveTime:Float;

    public function new (game:Game)
    {
        super(game);

        this.set = false;
    }

    override function sceneRender () :Void
    {
        super.sceneRender();

        this.graphics.beginFill(0xFF6666CC);
        this.graphics.drawRect(0,0,400,400);
        this.graphics.endFill();
        
        var compTitle = new h2d.Text(hxd.res.DefaultFont.get(),this);
        compTitle.text = '${this.getGame().getSaveData().name}\'s CHOICE';
        compTitle.textColor = 0xFF000000;
        compTitle.x = 300 - (compTitle.textWidth / 2);
        compTitle.y = 20;

        var plyrTitle = new h2d.Text(hxd.res.DefaultFont.get(),this);
        plyrTitle.text = "YOUR CHOICE";
        plyrTitle.textColor = 0xFF000000;
        plyrTitle.x = 100 - (plyrTitle.textWidth / 2);
        plyrTitle.y = 20;

        var i = back.getInteractive();
        i.cursor = hxd.Cursor.Button;
        var tf = new h2d.Text(hxd.res.DefaultFont.get(),this);
        tf.text = back.getTitle();
        tf.x = 100 - (tf.textWidth / 2);
        tf.y = 340;
        tf.textColor = (back.over) ? 0x000000 : 0xFFFFFF;
        i.x = tf.x;
        i.y = tf.y;
        i.width = tf.textWidth;
        i.height = tf.textHeight + 2;

        var mtf = new h2d.Text(hxd.res.DefaultFont.get(),this);
        mtf.text = this.msg;
        mtf.textColor = 0xFF000000;
        mtf.x = 200 - (mtf.textWidth / 2);
        mtf.y = 60;

        var compBmp:h2d.Bitmap = new h2d.Bitmap(this.getGame().getTiles()[this.compSelect.getAction().getIndex()+21][2],this);
        compBmp.adjustColor({hue:Math.PI,lightness:((this.compSelect.isFaceUp()) ? 0 : -100)});
        compBmp.x = 280;
        compBmp.y = 180;

        for (sel in 0...this.userSelects.length)
        {
            var as = this.userSelects[sel];
            var selBmp:h2d.Bitmap = new h2d.Bitmap(this.getGame().getTiles()[as.getAction().getIndex()+21][2],this);
            if (!as.isFaceUp()) selBmp.adjustColor({lightness:-100});
            selBmp.x = 80;
            selBmp.y = 120 + (as.getAction().getIndex()*60);

            if (!this.selMade)
            {
                var seli = as.getInteractive();
                seli.y = selBmp.y;
            }
        }
    }

    override function sceneUpdate (dt:Float) :Void
    {
        super.sceneUpdate(dt);

        if (!this.set) this.initDraw();
        if (this.won>=0)
        {
            if (this.leaveTime==0.) this.leaveTime = 2.5 + this.getElapsedTime();
            else if (this.getElapsedTime()>=this.leaveTime)
            {
                this.getGame().getSaveData().cash += (0==this.won) ? 20 : (1==this.won) ? 10 : 120;
                this.getGame().getSaveData().happy += (0==this.won) ? 55 : (1==this.won) ? 35 : 85;
                this.goBack();
            }
        }
        
        var i:Int = 0;
        while (i<this.numChildren)
        {
            if ("h2d.Text"==Type.getClassName(Type.getClass(this.getChildAt(i)))||"h2d.Graphics"==Type.getClassName(Type.getClass(this.getChildAt(i)))) this.removeChild(this.getChildAt(i));
            else i++;
        }
    }

    function initDraw () :Void
    {
        this.won = -1;
        this.leaveTime = 0.;
        this.msg = "";

        this.graphics.beginFill(0xFF6666CC);
        this.graphics.drawRect(0,0,400,400);
        this.graphics.endFill();

        this.back = new SButton("< BACK",goBack,this);

        this.setCompSelect();
        this.userSelects = new Array();
        for (x in 0...3) this.userSelects.push(new ActionSelect(Action.createByIndex(x),true,true,this));
    }

    function setCompSelect () :Void
    {
        var x:Int = Math.floor(Math.random() * 3);
        if (3==x) x = 2;
        this.compSelect = new ActionSelect(Action.createByIndex(x),false);
        this.set = true;
    }

    function goBack () :Void
    {
        this.set = false;
        this.getGame().changeScene("MAIN");
    }

    public function makeChoice (sel:Int) :Void
    {
        this.compSelect.setFaceUp(true);
        for (i in 0...this.userSelects.length) if (sel!=i) this.userSelects[i].setFaceUp(false);
        this.selMade = true;

        var c = this.compSelect.getAction().getIndex();
        switch (sel)
        {
            case 1:
                if (c==0) this.won = 2;
                else if (2==c) this.won = 1;
                else this.won = 0;
            case 2:
                if (0==c) this.won = 1;
                else if (1==c) this.won = 2;
                else this.won = 0;
            case 0:
                if (0==c) this.won = 0;
                else if (1==c) this.won = 1;
                else if (2==c) this.won = 2;
        }

        this.msg = (this.won==1) ? "YOU LOSE..." : (this.won==2) ? "YOU WIN!" : "DRAW";
    }
}

private enum Action { ROCK; PAPER; SCISSORS; }
private class ActionSelect
{
    var action:Action;
    var faceUp:Bool;
    var interactive:h2d.Interactive;

    var subject:msg.Subject;

    public function new (a:Action,faceUp:Bool,?int:Bool=false,?parent:GameScene=null)
    {
        this.action = a;
        this.faceUp = faceUp;

        this.subject = new msg.Subject();
        this.subject.addObserver(new msg.Observer.AudioObserver());

        if (int)
        {
            this.interactive = new h2d.Interactive(40,40,parent);
            this.interactive.x = 80;
            this.interactive.cursor = hxd.Cursor.Button;
            this.interactive.onClick = function (e:hxd.Event) :Void
            {
                this.subject.notify(null,msg.TpetEvent.UI_CLICK,parent.getGame());
                cast(parent,RPSGameScene).makeChoice(this.action.getIndex());
            }
        } else this.interactive = null;
    }

    public function getAction () :Action return this.action;
    public function getInteractive () :h2d.Interactive return this.interactive;
    public function getSubject () :msg.Subject return this.subject;
    public function isFaceUp () :Bool return this.faceUp;

    public function setFaceUp (b:Bool) :Void this.faceUp = b;
}

private class SButton extends h2d.Object
{
    public var over:Bool;

    var interactive:h2d.Interactive;
    var onSelect:Void->Void;
    var subject:msg.Subject;
    var title:String;

    public function new (title:String,onSelect:Void->Void,parent:h2d.Object)
    {
        this.interactive = new h2d.Interactive(0,0,parent);
        this.over = false;
        this.subject = new msg.Subject();

        this.subject.addObserver(new msg.Observer.AudioObserver());

        super();

        this.interactive.onOut = function (e:hxd.Event) :Void this.over = false;
        this.interactive.onOver = function (e:hxd.Event) :Void this.over = true;

        this.interactive.onClick = function (e:hxd.Event) :Void
        {
            this.subject.notify(this,msg.TpetEvent.UI_CLICK,cast(parent,GameScene).getGame());
            this.onSelect();
        }

        this.parent = parent;

        this.onSelect = onSelect;
        this.title = title;
    }

    public function getInteractive () :h2d.Interactive return this.interactive;
    public function getTitle () :String return this.title;
    public function notify (e:msg.TpetEvent) :Void this.subject.notify(this,e,cast(parent,GameScene).getGame());
}