package msg;

interface IObserver
{
    public function onNotify (t:h2d.Object,e:TpetEvent,?game:Game) :Void;
}

class AudioObserver implements IObserver
{
    public function new () {}

    public function onNotify (t:h2d.Object,e:TpetEvent,?game:Game=null) :Void
    {
        switch (e)
        {
            case UI_CLICK: click(game);
            case UI_KEY: key(game,Math.ceil(Math.random()*4));
            case TRUMPET: trumpet(game);
            default:
        }
    }

    function click (game:Game) :Void
    {
        if (hxd.res.Sound.supportedFormat(hxd.res.Sound.SoundFormat.Wav))
        {
            var sound:hxd.res.Sound = hxd.Res.click;
            var vol = (null==game) ? 1. : game.getSettings().getAudioSettings().ui_volume / 10;
            sound.play(false,vol);
        }
    }

    function key (game:Game,val:Int) :Void {
        
        if (hxd.res.Sound.supportedFormat(hxd.res.Sound.SoundFormat.Wav))
        {
            var sound:hxd.res.Sound;
            switch (val)
            {
                case 1: sound = hxd.Res.key1;
                case 2: sound = hxd.Res.key2;
                case 3: sound = hxd.Res.key3;
                default: sound = hxd.Res.key4;
            }
            var vol = (null==game) ? 1. : game.getSettings().getAudioSettings().ui_volume / 10;
            sound.play(false,vol);
        }
    }

    function trumpet (game:Game) :Void
    {
        if (hxd.res.Sound.supportedFormat(hxd.res.Sound.SoundFormat.Wav))
        {
            var sound:hxd.res.Sound = hxd.Res.trumpet;
            var vol = (null==game) ? 1. : game.getSettings().getAudioSettings().t_volume / 10;
            sound.play(true,vol);
        }
    }
}