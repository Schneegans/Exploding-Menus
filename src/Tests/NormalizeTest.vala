/* 
Copyright (c) 2011-2012 by Simon Schneegans

This program is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option)
any later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
this program.  If not, see <http://www.gnu.org/licenses/>. 
*/

public class NormalizeTest : GLib.Object {

    public signal void on_finish();

    private InstructionWindow   instruction;
    private SmileWindow         smile;
    private BindingManager      bindings = null;
    
    private bool ready = false;
    private int stage = 0;
    private int page = 0;
    
    private delegate void next();

    public void init() {
        instruction = new InstructionWindow();
        smile = new SmileWindow(false);

        bindings = new BindingManager();
        bindings.bind(new Trigger.from_string("space"), "next");
        
        bindings.on_press.connect((id) => {
            if (ready && id=="next") {
                ready = false;
                next_page();
            } 
        });
        
        instruction.open();
        smile.open();

        set_stage(0);
        next_page();
    }
    
    private void set_stage(int in_stage) {
        stage = in_stage;
        page = 0; 
    }
    
    private void next_page() {
        switch (stage) {
            case 0:
                next_page_introduction();
                break;
             case 1:
                training();
                break;
            case 2:
                next_page_finish();
                break;
        }

        ++page;
    }
    
    private void next_page_introduction() {
        switch (page) {
            case 0: 
                instruction.set_text(heading("Willkommen") + 
                                     "zum ultimativen <b>Piemenü-Test</b>! \n" +
                                     "Mach es dir gemütlich; diese Textmeldungen werden"+
                                     " dich Stück für Stück durch den gesamten Test führen."+ 
                                     hint("Weiter mit Leertaste..."));
                break;
                
            case 1: 
                instruction.set_text(heading("Einführungstest") + 
                                     "Zunächst eine einfache Einführungsaufgabe. "+
                                     "Du wirst gleich gelbe <b>Smilies</b> auf dem"+
                                     " Bildschirm erscheinen sehen. \n\n"+
                                     "Sobald du eins siehst, <b>klicke mit der Maus"+
                                     " so schnell wie möglich darauf</b>! Aber Achtung: Solange kein Smile"+
                                     " sichtbar ist, kannst du deine Maus nicht bewegen!"+ 
                                     hint("Beginnen mit Leertaste!"));
                
                set_stage(1);

                Logger.write("##START_OF_NORMALIZATION## " + Logger.get_time());
                
                break;
        }
        
        ready = true;
    }
    
    private void next_page_finish() {
        switch (page) {
            case 0: 
                instruction.set_text(heading("Sehr gut!") + 
                                     "Soviel zur Einführung. Beginnen wir mit dem spannenden Teil..." + 
                                     hint("Weiter mit Leertaste..."));
                break;
            default:
                on_finish();
                break;
        }
        
        ready = true;
    }

    private void training() {
        var targets = new Gee.ArrayList<Vector?>();
        Vector target = null;
        
        instruction.set_text("");
        
        targets.add(new Vector(1, 0));
        targets.add(new Vector(-1, 0));
        targets.add(new Vector(1, 1));
        targets.add(new Vector(1, -1));
        targets.add(new Vector(-1, 1));
        targets.add(new Vector(-1, -1));
        targets.add(new Vector(0, 1));
        targets.add(new Vector(0, -1));
        targets.add(new Vector(1, 0));
        targets.add(new Vector(-1, 0));
        targets.add(new Vector(1, 1));
        targets.add(new Vector(1, -1));
        targets.add(new Vector(-1, 1));
        targets.add(new Vector(-1, -1));
        targets.add(new Vector(0, 1));
        targets.add(new Vector(0, -1));
        
        uint show_time = 0;

        next request_next = () => {
            if (targets.size == 0) {

                set_stage(2);
                next_page();

            } else {
                
                center_mouse();
                
                GLib.Timeout.add(2000, () => {
                    int index = GLib.Random.int_range(0, targets.size);
                    target = targets.get(index);
                    targets.remove_at(index); 
                    
                    var pos = target.copy();
                    pos.set_length(300);  
                            
                    smile.set_smile_position(Vector.sum(new Vector(smile.width()/2, smile.height()/2), pos));
                    smile.show_smile(true);
                    
                    show_time = Time.get_now();
                    
                    return false;
                });
            }
        };
        
        request_next();
        
        smile.on_mouse_moved.connect(()=>{
            if (target == null && stage == 1) {
                center_mouse();
            }
        });
        
        smile.on_smile_clicked.connect(()=>{
            smile.show_smile(false);
            
            Logger.write("%i|%i|%u".printf((int)target.x, (int)target.y, Time.get_now() - show_time));

            target = null;
            request_next();
        });
    }
    
    private string heading(string text) {
        return "<span size='25000'><b>" + text + "</b></span>\n\n";
    }
    
    private string hint(string text) {
        return "\n\n<span size='15000' style='italic'>" + text + "</span>";
    }
    
    private void center_mouse() {
        var display = Gdk.Display.get_default();
        var manager = display.get_device_manager();
        var screen = Gdk.Screen.get_default();

        unowned GLib.List<weak Gdk.Device?> list = manager.list_devices(Gdk.DeviceType.MASTER);

        foreach(var device in list) {
            if (device.input_source == Gdk.InputSource.MOUSE) 
                device.warp(screen, smile.width()/2, smile.height()/2);
        }  
    }

}
