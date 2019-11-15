package scenes;

class NewGameScene extends GameScene
{
    public var change:Bool=false;

    var data:Dynamic;
    var tpet:Turnpet;

    var input:h2d.TextInput;
    var sliders:Array<MenuSlider>;

    public function new (game:Game)
    {
        super(game);

        this.graphics.beginFill(0xFF6666CC);
        this.graphics.drawRect(0,0,400,400);
        this.graphics.endFill();

        this.data =
        {
            name: "Teepee",
            body: 0,
            eyes: 0,
            leaf: 0,
            color: 0,
            cash: 0,
            happy: 0,
            trumpet: false
        };

        this.sliders = 
        [
            new MenuSlider("BODY",2,this),
            new MenuSlider("EYES",2,this),
            new MenuSlider("LEAF",2,this),
            new MenuSlider("COLOR",11,this)
        ];

        var ready = new NOption("READY!",ready,this);
        var ri = ready.getInteractive();
        ri.cursor = hxd.Cursor.Button;
        var rtf = new h2d.Text(hxd.res.DefaultFont.get(),this);
        rtf.text = ready.getTitle();
        rtf.x = 200 - (rtf.textWidth / 2);
        rtf.y = 300;
        rtf.textColor = (ready.over) ? 0x000000 : 0xFFFFFF;
        ri.x = rtf.x;
        ri.y = rtf.y;
        ri.width = rtf.textWidth;
        ri.height = rtf.textHeight + 2;

        this.input = new h2d.TextInput(hxd.res.DefaultFont.get(),this);
        this.input.backgroundColor = 0x40000000;
        this.input.text = this.data.name;
        this.input.textColor = 0xFFFFFFFF;
        var iSubject = new msg.Subject();
        iSubject.addObserver(new msg.Observer.AudioObserver());
        this.input.onChange = function ()
        {
            if (12<this.input.text.length)
            {
                if (11!=this.input.cursorIndex)
                {
                    this.input.text = this.input.text.substr(0,this.input.cursorIndex-1) + this.input.text.substr(this.input.cursorIndex);
                    --this.input.cursorIndex;
                }
                else this.input.text = this.input.text.substr(0,12);
            }
            iSubject.notify(this.input,msg.TpetEvent.UI_KEY);
            this.change = true;
        }

        this.tpet = new Turnpet(data,this.getGame(),this);
        this.tpet.parent = this.input;
        this.tpet.x = -80;
        this.tpet.y = 80;
    }

    override function sceneRender ()
    {
        super.sceneRender();

        this.input.x = 200 - (this.input.textWidth / 2);
        this.input.y = 60;

        var title = new h2d.Text(hxd.res.DefaultFont.get(),this);
        title.text = "CREATE A TURNPET!";
        title.textColor = 0xFF000000;
        title.x = 200 - (title.textWidth / 2);
        title.y = 24;

        for (s in 0...this.sliders.length)
        {
            this.sliders[s].x = 200;
            this.sliders[s].y = 120 + (s*20);
        }
    }

    override function sceneUpdate (dt:Float)
    {
        super.sceneUpdate(dt);
        if (this.change)
        {
            this.data.name = this.input.text;
            this.data.body = this.sliders[0].getValue();
            this.data.eyes = this.sliders[1].getValue();
            this.data.leaf = this.sliders[2].getValue();
            this.data.color = this.sliders[3].getValue();
            this.tpet.changeData(this.data);

            this.change = false;
        }
    }

    function ready () :Void
    {
        if (!hxd.File.exists("save.json")) hxd.File.saveBytes("save.json",haxe.io.Bytes.ofString(haxe.Json.stringify(this.data)));
        this.getGame().readSaveData();
        this.getGame().changeScene("MAIN");
    }
}

private class MenuSlider extends h2d.Object
{
    var max:Int;
    var title:String;

    var text:h2d.Text;
    var value:Int;
    var lInt:h2d.Interactive;
    var rInt:h2d.Interactive;

    var subject:msg.Subject;

    public function new (title:String,max:Int,?parent:NewGameScene)
    {
        super(parent);

        this.max = max;
        this.title = title;

        this.value = 0;

        this.subject = new msg.Subject();
        this.subject.addObserver(new msg.Observer.AudioObserver());

        this.text = new h2d.Text(hxd.res.DefaultFont.get(),this);
        this.text.text = '${this.title}: ${this.value+1}';
        this.text.textAlign = Center;
        this.text.x = 20;
        this.text.maxWidth = 100;

        this.lInt = new h2d.Interactive(20,20,this);
        this.lInt.x = 0;
        var lT = new h2d.Text(hxd.res.DefaultFont.get(),this.lInt);
        lT.text = "<";
        this.lInt.onOver = function (e:hxd.Event) :Void lT.textColor = 0xFF000000;
        this.lInt.onOut = function (e:hxd.Event) :Void lT.textColor = 0xFFFFFFFF;
        this.lInt.onClick = function (e:hxd.Event) :Void
        {
            this.subject.notify(this,msg.TpetEvent.UI_CLICK,parent.getGame());
            this.value = (0==this.value) ? this.max : this.value - 1;
            this.text.text = '${this.title}: ${this.value+1}';
            parent.change = true;
        }

        this.rInt = new h2d.Interactive(20,20,this);
        this.rInt.x = 140;
        var rT = new h2d.Text(hxd.res.DefaultFont.get(),this.rInt);
        rT.text = ">";
        this.rInt.onOver = function (e:hxd.Event) :Void rT.textColor = 0xFF000000;
        this.rInt.onOut = function (e:hxd.Event) :Void rT.textColor = 0xFFFFFFFF;
        this.rInt.onClick = function (e:hxd.Event) :Void
        {
            this.subject.notify(this,msg.TpetEvent.UI_CLICK,parent.getGame());
            this.value = (this.max==this.value) ? 0 : this.value + 1;
            this.text.text = '${this.title}: ${this.value+1}';
            parent.change = true;
        }
    }

    public function getValue () :Int return this.value;
}

private class NOption extends h2d.Object
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
            this.subject.notify(this,msg.TpetEvent.UI_CLICK);
            this.onSelect();
        }

        this.parent = parent;

        this.onSelect = onSelect;
        this.title = title;
    }

    public function getInteractive () :h2d.Interactive return this.interactive;
    public function getTitle () :String return this.title;
}