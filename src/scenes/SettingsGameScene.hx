package scenes;

class SettingsGameScene extends GameScene
{
    var aSliders:Array<MenuSlider>;
    var vSliders:Array<MenuSlider>;
    
    public var change:Bool=false;

    public function new (game:Game)
    {
        super(game);

        this.aSliders =
        [
            new MenuSlider("UI VOLUME",10,game.getSettings().getAudioSettings().ui_volume,this),
            new MenuSlider("TRUMPET VOLUME",10,game.getSettings().getAudioSettings().t_volume,this)
        ];
        this.vSliders = 
        [
            new MenuSlider("FULLSCREEN",1,0,this)
        ];
    }

    override function sceneRender () :Void
    {
        super.sceneRender();
        for (s in 0...this.aSliders.length)
        {
            this.aSliders[s].x = 120;
            this.aSliders[s].y = 60 + (s*20);
        }
    }

    override function sceneUpdate (dt:Float)
    {
        super.sceneUpdate(dt);
        if (this.change)
        {
            var aSettings:Dynamic =
            {
                ui_volume: this.aSliders[0].getValue(),
                t_volume: this.aSliders[1].getValue()
            };
            var vSettings:Dynamic =
            {
                fullscreen: (this.vSliders[0].getValue()==1) ? true : false
            };
            this.game.getSettings().changeSettings(aSettings,vSettings);
            this.change = false;
        }
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

    public function new (title:String,max:Int,?currVal:Int=0,?parent:SettingsGameScene)
    {
        super(parent);

        this.max = max;
        this.title = title;

        this.value = currVal;

        this.subject = new msg.Subject();
        this.subject.addObserver(new msg.Observer.AudioObserver());

        this.text = new h2d.Text(hxd.res.DefaultFont.get(),this);
        this.text.text = '${this.title}: ${(this.value==10) ? 0 : this.value}';
        this.text.textAlign = Center;
        this.text.x = 20;
        this.text.maxWidth = 120;

        this.lInt = new h2d.Interactive(20,20,this);
        this.lInt.x = 0;
        var lT = new h2d.Text(hxd.res.DefaultFont.get(),this.lInt);
        lT.text = "<";
        this.lInt.onOver = function (e:hxd.Event) :Void lT.textColor = 0xFF000000;
        this.lInt.onOut = function (e:hxd.Event) :Void lT.textColor = 0xFFFFFFFF;
        this.lInt.onClick = function (e:hxd.Event) :Void
        {
            this.value = (0==this.value) ? this.max : this.value - 1;
            this.subject.notify(this,msg.TpetEvent.UI_CLICK,parent.getGame());
            this.text.text = '${this.title}: ${(this.value==10) ? 0 : this.value + 1}';
            parent.change = true;
        }

        this.rInt = new h2d.Interactive(20,20,this);
        this.rInt.x = 160;
        var rT = new h2d.Text(hxd.res.DefaultFont.get(),this.rInt);
        rT.text = ">";
        this.rInt.onOver = function (e:hxd.Event) :Void rT.textColor = 0xFF000000;
        this.rInt.onOut = function (e:hxd.Event) :Void rT.textColor = 0xFFFFFFFF;
        this.rInt.onClick = function (e:hxd.Event) :Void
        {
            if ((this.max==this.value)) trace('${this.max} ${this.value}');
            this.value = (this.max==this.value) ? 0 : this.value + 1;
            trace(this.value);
            this.subject.notify(this,msg.TpetEvent.UI_CLICK,parent.getGame());
            this.text.text = '${this.title}: ${(this.value==10) ? 0 : this.value - 1}';
            parent.change = true;
        }
    }

    public function getValue () :Int return this.value;
    public function setValue (val:Int) :Void this.value = val;
}