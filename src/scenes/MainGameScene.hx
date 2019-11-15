package scenes;

import haxe.Template;

class MainGameScene extends GameScene
{
    var set:Bool=false;
    var tiles:Array<Array<Int>>;
    var tpet:Turnpet;

    var textHappy:h2d.Text;
    var textCash:h2d.Text;

    public function new (game:Game) 
    {
        super(game);

        this.getGame().engine.backgroundColor = 0xFF000000;
    }

    override function sceneRender () :Void
    {
        super.sceneRender();

        var th = Std.string(this.tpet.getHappiness()/10);
        if (this.tpet.getHappiness()%10!=0) if (th.split(".")[1].length>1) th = '${th.split(".")[0]}.${th.split(".")[1].substr(0,1)}';
        this.textHappy.text = 'Happiness: ${th}%';

        var tc = Std.string(this.tpet.getCash()/100);
        if (this.tpet.getCash()%100!=0) if (tc.split(".")[1].length<2) for (x in 0...2-tc.split(".")[1].length) tc += "0";
        this.textCash.text = new haxe.Template("Cash: $::c::").execute({c:tc});

        this.set = true;
    }

    override function sceneUpdate (dt:Float) :Void
    {
        super.sceneUpdate(dt);

        if (null==this.getGame().getSaveData()) this.getGame().readSaveData();
        else if (null!=this.getGame().getSaveData()&&false==this.set) this.setAll();

        if (null!=this.tpet) this.tpet.update();
    }

    function setAll ()
    {
        var t = 0;        
        for (x in 0...10) for (y in 0...10)
        {
            var tile = new h2d.Bitmap(this.getGame().getTiles()[21 + t][1],this);
            if (null!=this.getGame().getSaveData()) if (0!=this.getGame().getSaveData().color) tile.adjustColor({hue:this.getGame().getSaveData().color*Math.PI/6}); // change grass color so turnpet never blends in
            tile.x = x * 40;
            tile.y = y * 40;
            t = (t==2) ? 0 : t + 1;
        }

        this.tpet = new Turnpet(this.getGame().getSaveData(),this.getGame(),this);
        this.tpet.x = 180;
        this.tpet.y = 180;

        var name = new h2d.Text(hxd.res.DefaultFont.get(),this);
        name.text = this.tpet.getName();
        name.textColor = 0xFF000000;
        name.x = 200 - (name.textWidth / 2);
        name.y = 0;

        var quit = new MButton("QUIT GAME",hxd.System.exit,this);
        var qi = quit.getInteractive();
        qi.cursor = hxd.Cursor.Button;
        var qtf = new h2d.Text(hxd.res.DefaultFont.get(),this);
        qtf.text = quit.getTitle();
        qtf.x = 0;
        qtf.y = 380;
        qtf.textColor = 0xFF000000;
        qi.x = qtf.x;
        qi.y = qtf.y;
        qi.width = qtf.textWidth;
        qi.height = qtf.textHeight + 2;

        var gbut = new MButton("PLAY R/P/S",rps,this);
        var gi = gbut.getInteractive();
        gi.cursor = hxd.Cursor.Button;
        var gtf = new h2d.Text(hxd.res.DefaultFont.get(),this);
        gtf.text = gbut.getTitle();
        gtf.x = 398 - gtf.textWidth;
        gtf.y = 0;
        gtf.textColor = 0xFF000000;
        gi.x = gtf.x;
        gi.y = gtf.y;
        gi.width = gtf.textWidth;
        gi.height = gtf.textHeight + 2;

        var shop = new MButton("GO TO SHOP",shop,this);
        var si = shop.getInteractive();
        si.cursor = hxd.Cursor.Button;
        var stf = new h2d.Text(hxd.res.DefaultFont.get(),this);
        stf.text = shop.getTitle();
        stf.x = 398 - stf.textWidth;
        stf.y = 380;
        stf.textColor = 0xFF000000;
        si.x = stf.x;
        si.y = stf.y;
        si.width = stf.textWidth;
        si.height = stf.textHeight + 2;

        this.textHappy = new h2d.Text(hxd.res.DefaultFont.get(),this);
        this.textHappy.textColor = 0xFF000000;
        this.textHappy.x = 0;
        this.textHappy.y = 0;
        
        this.textCash = new h2d.Text(hxd.res.DefaultFont.get(),this);
        this.textCash.textColor = 0xFF000000;
        this.textCash.x = 0;
        this.textCash.y = 16;
    }

    function rps () :Void this.getGame().changeScene("RPS");
    function shop () :Void this.getGame().changeScene("SHOP");
}

private class MButton extends h2d.Object
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