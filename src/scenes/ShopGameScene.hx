package scenes;

class ShopGameScene extends GameScene
{
    public var hoverItem:Item;
    public var selItem:Item;

    var options:Array<SOption>;

    var err:h2d.Text;
    var errText:String="";

    var back:SButton;
    var purch:SButton;

    public function new (g:Game)
    {
        super(g);

        this.graphics.beginFill(0xFF6666CC);
        this.graphics.drawRect(0,0,400,400);
        this.graphics.endFill();

        this.options =
        [
            new SOption(
                {
                    name:"Ground Beef",
                    cost:"1.00",
                    happy:70,
                    hcost:0
                },this
            ),
            new SOption(
                {
                    name:"Burger Patty",
                    cost:"2.50",
                    happy:120,
                    hcost:0
                },this
            ),
            new SOption(
                {
                    name:"Filet Mignon",
                    cost:"4.00",
                    happy:200,
                    hcost:0
                },this
            ),
            new SOption(
                {
                    name:"Trumpet",
                    cost:"8.00",
                    hcost:800,
                    happy:0
                },this
            )
        ];

        this.back = new SButton("< BACK",goBack,this);
        this.purch = new SButton("PURCHASE",purchase,this);

        this.hoverItem = null;
        this.selItem = null;
    }

    override function sceneRender () :Void
    {
        super.sceneRender();

        this.graphics.beginFill(0xFF6666CC);
        this.graphics.drawRect(0,0,400,400);
        this.graphics.endFill();

        for (i in 0...this.options.length)
        {
            var so:SOption = this.options[i];
            so.x = 200;
            so.y = 120 + (40*i);
            var sot = new h2d.Text(hxd.res.DefaultFont.get(),this);
            sot.text = new haxe.Template("::n:: - $::c::").execute({c:so.getItem().cost,n:so.getItem().name});
            if (so.getItem().hcost!=0) sot.text += ' + H${so.getItem().hcost}';
            sot.textColor = (so.over) ? 0xFF000000 : 0xFFFFFFFF;
            sot.x = so.x;
            sot.y = so.y;
            so.getInteractive().x = so.x;
            so.getInteractive().y = so.y;
            so.getInteractive().width = sot.textWidth;
            so.getInteractive().height = sot.textHeight;
        }

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

        var p = purch.getInteractive();
        p.cursor = hxd.Cursor.Button;
        var pt = new h2d.Text(hxd.res.DefaultFont.get(),this);
        pt.text = purch.getTitle();
        pt.x = 300 - (pt.textWidth / 2);
        pt.y = 340;
        pt.textColor = (purch.over) ? 0xFF000000 : 0xFFFFFFFF;
        p.x = pt.x;
        p.y = pt.y;
        p.width = pt.textWidth;
        p.height = pt.textHeight + 2;

        var title = new h2d.Text(hxd.res.DefaultFont.get(),this);
        title.text = "SHOP";
        title.textColor = 0xFFFFFFFF;
        title.x = 200 - (title.textWidth / 2);
        title.y = 40;

        var err = new h2d.Text(hxd.res.DefaultFont.get(),this);
        err.text = this.errText;
        err.textColor = 0xFF000000;
        err.x = 200 - (err.textWidth / 2);
        err.y = 60;

        var selected = new h2d.Text(hxd.res.DefaultFont.get(),this);
        selected.text = (null==this.selItem) ? "No selected item" : 'Selected item: ${this.selItem.name}';
        selected.textColor = 0xFF000000;
        selected.x = 200 - (selected.textWidth / 2);
        selected.y = 300;
    }

    override function sceneUpdate (dt:Float) :Void
    {
        super.sceneUpdate(dt);

        var i:Int = 0;
        while (i<this.numChildren)
        {
            if ("h2d.Text"==Type.getClassName(Type.getClass(this.getChildAt(i)))||"h2d.Graphics"==Type.getClassName(Type.getClass(this.getChildAt(i)))) this.removeChild(this.getChildAt(i));
            else i++;
        }
    }

    function goBack () :Void this.getGame().changeScene("MAIN");
    function purchase () :Void
    {
        if (null!=this.selItem)
        {
            if (100*Std.parseFloat(this.selItem.cost)>this.getGame().getSaveData().cash)
            {
                this.errText = "Not enough cash!";
                return;
            }
            if (this.selItem.hcost>this.getGame().getSaveData().happy)
            {
                this.errText = "Not happy enough!";
                return;
            }
            this.getGame().getSaveData().cash -= cast(100*Std.parseFloat(this.selItem.cost),Int);
            this.getGame().getSaveData().happy += this.selItem.happy;
            if (0<this.selItem.hcost) this.getGame().getSaveData().trumpet = true;
            this.goBack();
        } else this.errText = "No item selected!";
    }
}

typedef Item = {name:String,cost:String,happy:Float,?hcost:Float};
private class SOption extends h2d.Object
{
    var interactive:h2d.Interactive;
    var item:Item;
    var subject:msg.Subject;

    public var over:Bool;

    public function new (item:Item,parent:ShopGameScene)
    {
        super(parent);
        this.over = false;

        this.interactive = new h2d.Interactive(0,0,parent);
        this.interactive.cursor = hxd.Cursor.Button;
        this.interactive.onOver = function (e:hxd.Event) :Void
        {
            parent.hoverItem = this.item;
            this.over = true;
        }
        this.interactive.onOut = function (e:hxd.Event) :Void
        {
            parent.hoverItem = null;
            this.over = false;
        }
        this.interactive.onClick = function (e:hxd.Event) :Void
        {
            parent.selItem = parent.hoverItem;
            this.subject.notify(this,msg.TpetEvent.UI_CLICK,parent.getGame());
        }

        this.item = item;

        this.subject = new msg.Subject();
        this.subject.addObserver(new msg.Observer.AudioObserver());
    }

    public function getInteractive (): h2d.Interactive return this.interactive;
    public function getItem () :Item return this.item;
    public function getSubject () :msg.Subject return this.subject;

    public function isOver (over:Bool) :Void this.over = over;
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