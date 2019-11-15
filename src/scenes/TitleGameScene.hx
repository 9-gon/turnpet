package scenes;

typedef HorridWorkaround = { text:String,textColor:Int };
class TitleGameScene extends GameScene
{
    var currentOption:Int;
    var options:Array<TitleOption>;

    public function new (game:Game) 
    {
        super(game);

        this.currentOption = 0;
        this.options = [];
        this.setOptions();

        for (a in 0...this.options.length)
        {
            var option = this.options[a];
            var i = option.getInteractive();
            i.cursor = hxd.Cursor.Button;
        }
    }
    
    override function sceneRender () :Void
    {
   //     this.removeChildren();
        super.sceneRender();

        this.graphics.beginFill(0xFF6666CC);
        this.graphics.drawRect(0,0,400,400);
        this.graphics.endFill();
        
        for (a in 0...this.options.length)
        {
            var option = this.options[a];
            var tf = new h2d.Text(hxd.res.DefaultFont.get(),this);
            var i = option.getInteractive();
            tf.text = option.getTitle();

            tf.x = 200 - (tf.textWidth / 2);
            tf.y = 200 + ((tf.textHeight + 2) * a);
            tf.textColor = (option.over) ? 0x000000 : 0xFFFFFF;

            i.x = tf.x;
            i.y = tf.y;
            i.width = tf.textWidth;
            i.height = tf.textHeight + 2;
        }
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

    function conTurnpet () :Void this.getGame().changeScene("MAIN");
    function del () :Void 
    {
        if (hxd.File.exists("save.json")) hxd.File.delete("save.json");
        this.getGame().clearSaveData();
        this.setOptions();
    }
    function destroy () :Void hxd.System.exit();
    function newTurnpet () :Void this.getGame().changeScene("NEW");

    function setOptions () :Void
    {
        if (0<this.options.length)
        {
            while (0<this.options.length) this.options.shift();
            this.graphics = new h2d.Graphics(this);
        }

        if (null==this.getGame().getSaveData()) this.options.push(new TitleOption("New Turnpet",newTurnpet,this));
        else 
        {
            this.options.push(new TitleOption("Continue",conTurnpet,this));
            this.options.push(new TitleOption("Delete Save",del,this));
        }
        this.options.push(new TitleOption("Quit",destroy,this));
    }
}

private class TitleOption extends h2d.Object
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
}