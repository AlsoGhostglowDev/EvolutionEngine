package funkin.backend.scripting.events;

class CancellableEvent {
    public var cancelled:Bool = false;
    public var data:Map<String, Dynamic> = [];

    public function new() {}

    public function cancel()
        cancelled = true;

    public function destroy()
        data = [];
}