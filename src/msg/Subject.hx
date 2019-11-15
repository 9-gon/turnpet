package msg;

class Subject
{
    var observers:Array<Observer.IObserver> = new Array<Observer.IObserver>();

    public function new () {}

    public function addObserver (observer:Observer.IObserver) :Void this.observers.push(observer);
    public function removeObserver (observer:Observer.IObserver) :Void this.observers.remove(observer);

    public function notify (t:h2d.Object,e:TpetEvent,?g:Game=null) :Void for (o in this.observers) o.onNotify(t,e,g);
}