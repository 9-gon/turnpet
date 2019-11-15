class Game extends hxd.App
{
    var currentScene:scenes.GameScene;
    var saveData:SaveData;
    var scenes:Map<String,scenes.GameScene>;
    var settings:GameSettings;
    var window:hxd.Window;
    
    var tiles:Array<Array<h2d.Tile>> = new Array<Array<h2d.Tile>>();

    override function init () :Void
    {
        hxd.Res.initLocal();
        this.tiles = hxd.Res.loader.load("tile.png").toTile().grid(40);

        this.engine.backgroundColor = 0xFF6666CC;

        this.readSaveData();
        this.settings = this.readSettings();

        // i'd copy over old state manager code from a different project but honestly this thing doesn't need it
            // 12 hours in, maybe it did need it, good lord
        this.scenes =
        [
            "MAIN"=>new scenes.MainGameScene(this),
            "TITLE"=>new scenes.TitleGameScene(this),
            "NEW"=>new scenes.NewGameScene(this),
            "SHOP"=>new scenes.ShopGameScene(this),
            "RPS"=>new scenes.RPSGameScene(this)
        ];
        this.changeScene("TITLE");

        this.window = hxd.Window.getInstance();
        window.resize(800,800);
        window.setFullScreen(this.settings.getVideoSettings().fullscreen);
    }

    override function update (dt:Float) :Void
    {
        super.update(dt);
        this.currentScene.tick(dt);
    }

    public function clearSaveData () :Void this.saveData = null;
    public function readSaveData () :Void
    {
        if (hxd.File.exists("save.json"))
        {
            var s:String;
            hxd.File.load("save.json", function (content:haxe.io.Bytes) s = content.toString(), function (err:String) trace(err));
            this.saveData = haxe.Json.parse(s);
        }
    }

    function readSettings () :GameSettings
    {
        if (hxd.File.exists("settings.json"))
        {
            var s:String;
            hxd.File.load("settings.json", function (content:haxe.io.Bytes) s = content.toString(), function (err:String) trace(err));
            return new GameSettings(s);
        } else return null;
    }

    public function changeScene (key:String) :Void {
        this.currentScene = this.scenes[key];
        this.setScene(this.currentScene);
    }

    public function getSaveData () :Null<SaveData> return this.saveData;
    public function getSettings () :GameSettings return this.settings;
    public function getTiles () :Array<Array<h2d.Tile>> return this.tiles;
    public function getWindow () :hxd.Window return this.window;

    static var inst:Game;
    static function main () :Void inst = new Game();
}

typedef SaveData = { name:String, body:Int, leaf:Int, eyes:Int, color:Int, cash:Int, happy:Float, trumpet:Bool };

typedef AudioSettings = { ui_volume:Int, t_volume:Int };
typedef VideoSettings = { fullscreen:Bool };
class GameSettings
{
    var aSettings:AudioSettings;
    var vSettings:VideoSettings;

    public function new (s:String)
    {
        var json:Dynamic = haxe.Json.parse(s);
        this.aSettings = json.audio;
        this.vSettings = json.video;
    }

    public function getAudioSettings () :AudioSettings return aSettings;
    public function getVideoSettings () :VideoSettings return vSettings;

    public function changeSettings (aSettings:AudioSettings,vSettings:VideoSettings) :Void
    {
        this.aSettings = aSettings;
        this.vSettings = vSettings;
        hxd.File.saveBytes("settings.json",haxe.io.Bytes.ofString(haxe.Json.stringify({audio:aSettings,video:vSettings})));
    }
}