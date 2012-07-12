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

public class Training : GLib.Object {

    public signal void on_finish();

    private InstructionWindow   instruction;
    private SmileWindow         smile;
    private BindingManager      bindings = null;
    private MenuManager         menu = null;
    
    private bool ready = false;
    private int stage = 0;
    private int page = 0;
    
    private ulong cancel_handler = 0;
    private ulong select_handler = 0;
    
    private const int REPETITIONS = 1;
    
    private delegate void next();
    
    Gee.ArrayList<int> trainings;

    public void init() {
        instruction = new InstructionWindow();
        smile = new SmileWindow();
        trainings = new Gee.ArrayList<int>();
        
        
        trainings.add(1);
        trainings.add(2);
        trainings.add(3);
        
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
                training_trace();
                break;
            case 2:
                training_coral();
                break;
            case 3:
                training_linear();
                break;
            case 4:
                next_page_finish();
                break;
        }

        ++page;
    }
    
    private void next_page_introduction() {
        switch (page) {
            case 0: 
                instruction.set_text(heading("Willkommen") + 
                                     "zum ultimativen <b>Piemenü-Training</b>! \n" +
                                     "Bitte wähle die gewünschten Einträge konzentriert aus - "+
                                     "falls du eine Auswahl abbrichst, wird das als Fehlversuch gewertet! "+
                                     "Mach es dir bequem, diesmal beginnen mit dem..."+
                                     hint("Weiter mit Leertaste..."));
                int index = GLib.Random.int_range(0, trainings.size);
                set_stage(trainings.get(index));
                trainings.remove_at(index); 
                
                Logger.write("##START_OF_TRAINING## " + Logger.get_time());
                
                break;
        }
        
        ready = true;
    }
    
    private void next_page_finish() {
        switch (page) {
            case 0: 
                instruction.set_text(heading("Ach nee..") + 
                                     "Du bist ja schon durch jedes Menü durch! "+
                                     "Dann hab herzlichen Dank und bis zum bächsten mal!" + 
                                     hint("Beenden mit Leertaste!"));
                break;
            default:
                on_finish();
                break;
        }
        
        ready = true;
    }
   
    
    private void training_trace() {
        int repetitions = 0;
        var targets = new Gee.ArrayList<string?>();
        string target = "";
        
        Logger.write("#TRACE_TRAINING# ");

        next request_next = () => {
            if (repetitions == REPETITIONS && targets.size == 0) {
                instruction.set_text(heading("Trace-Menu-Training") + 
                                     "Sehr gut! Du wirst immer besser! "+
                                     "Wir machen weiter mit dem..."+
                                     hint("Weiter mit Leertaste..."));
                
                if (trainings.size > 0) {
                    int index = GLib.Random.int_range(0, trainings.size);
                    set_stage(trainings.get(index));
                    trainings.remove_at(index); 
                } else {
                    set_stage(4);
                }               
                
                disconnect_handlers();
                
                ready = true;
            } else {
            
                if (targets.size == 0) {
                    targets.add("Datei|Speichern als|Sound-Datei");
                    targets.add("Datei|Drucken...");
                    targets.add("Bearbeiten|Kopieren");
                    ++repetitions;
                } 
                
                target = targets.get(GLib.Random.int_range(0, targets.size));          
                instruction.set_text(heading("Trace-Menu-Training") +     
                                     "Wähle den Eintrag <b>"+ target +"</b>");
                                     
                targets.remove(target);
            }
        };
        
        request_next();
        
        if (menu == null) menu = new MenuManager();
        menu.init("trace", "real");
        
        disconnect_handlers();
        
        select_handler = menu.on_select.connect((item, time) => {
            if (item == target) {
                Logger.write("%s: %u".printf(target, time));
                smile.notify(true);
            } else {
                Logger.write("%s: -1".printf(target));
                smile.notify(false);
            }

            request_next();
        });
        
        cancel_handler = menu.on_cancel.connect(() => {
            Logger.write("%s: -1".printf(target));
            smile.notify(false);
            
            request_next();
        });
    }
    
    
    
    
    private void training_coral() {
        int repetitions = 0;
        var targets = new Gee.ArrayList<string?>();
        string target = "";
        
        Logger.write("#CORAL_TRAINING# ");

        next request_next = () => {
            if (repetitions == REPETITIONS && targets.size == 0) {
                instruction.set_text(heading("Coral-Menu-Training") + 
                                     "Sehr gut! Du wirst immer besser! "+
                                     "Wir machen weiter mit dem..."+
                                     hint("Weiter mit Leertaste..."));
                
                if (trainings.size > 0) {
                    int index = GLib.Random.int_range(0, trainings.size);
                    set_stage(trainings.get(index));
                    trainings.remove_at(index); 
                } else {
                    set_stage(4);
                }  
                
                disconnect_handlers();
                
                ready = true;
            } else {
            
                if (targets.size == 0) {
                    targets.add("Datei|Speichern als|Sound-Datei");
                    targets.add("Datei|Drucken...");
                    targets.add("Bearbeiten|Kopieren");
                    ++repetitions;
                } 
                
                target = targets.get(GLib.Random.int_range(0, targets.size));          
                instruction.set_text(heading("Coral-Menu-Training") +     
                                     "Wähle den Eintrag <b>"+ target +"</b>");
                                     
                targets.remove(target);
            }
        };
        
        request_next();
        
        if (menu == null) menu = new MenuManager();
        menu.init("coral", "real");
        
        disconnect_handlers();
        
        select_handler = menu.on_select.connect((item, time) => {
            if (item == target) {
                Logger.write("%s: %u".printf(target, time));
                smile.notify(true);
            } else {
                Logger.write("%s: -1".printf(target));
                smile.notify(false);
            }

            request_next();
        });
        
        cancel_handler = menu.on_cancel.connect(() => {
            Logger.write("%s: -1".printf(target));
            smile.notify(false);
            
            request_next();
        });
    }
    
    
    
    
    private void training_linear() {
        int repetitions = 0;
        var targets = new Gee.ArrayList<string?>();
        string target = "";
        
        Logger.write("#LINEAR_TRAINING# ");

        next request_next = () => {
            if (repetitions == REPETITIONS && targets.size == 0) {
                instruction.set_text(heading("Linear-Menu-Training") + 
                                     "Sehr gut! Du wirst immer besser! "+
                                     "Wir machen weiter mit dem..."+
                                     hint("Weiter mit Leertaste..."));
                
                if (trainings.size > 0) {
                    int index = GLib.Random.int_range(0, trainings.size);
                    set_stage(trainings.get(index));
                    trainings.remove_at(index); 
                } else {
                    set_stage(4);
                }               
                
                disconnect_handlers();
                
                ready = true;
            } else {
            
                if (targets.size == 0) {
                    targets.add("Datei|Speichern als|Sound-Datei");
                    targets.add("Datei|Drucken...");
                    targets.add("Bearbeiten|Kopieren");
                    ++repetitions;
                } 
                
                target = targets.get(GLib.Random.int_range(0, targets.size));          
                instruction.set_text(heading("Linear-Menu-Training") +     
                                     "Wähle den Eintrag <b>"+ target +"</b>");
                                     
                targets.remove(target);
            }
        };
        
        request_next();
        
        if (menu == null) menu = new MenuManager();
        menu.init("linear", "real");
        
        disconnect_handlers();
        
       select_handler = menu.on_select.connect((item, time) => {
            if (item == target) {
                Logger.write("%s: %u".printf(target, time));
                smile.notify(true);
            } else {
                Logger.write("%s: -1".printf(target));
                smile.notify(false);
            }

            request_next();
        });
        
        cancel_handler = menu.on_cancel.connect(() => {
            Logger.write("%s: -1".printf(target));
            smile.notify(false);
            
            request_next();
        });
    }
    

    
    private void disconnect_handlers() {
        if (cancel_handler > 0)
            menu.disconnect(cancel_handler);
            
        if (select_handler > 0)
            menu.disconnect(select_handler);
        
        cancel_handler = 0;
        select_handler = 0;
    }
    
    private string heading(string text) {
        return "<span size='25000'><b>" + text + "</b></span>\n\n";
    }
    
    private string hint(string text) {
        return "\n\n<span size='15000' style='italic'>" + text + "</span>";
    }

}