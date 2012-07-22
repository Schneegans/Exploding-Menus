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

public class G2_Final : GLib.Object {

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
    private ulong open_handler = 0;
    
    private const int REPETITIONS = 5;
    
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
                training("trace", "Trace-Menu");
                break;
            case 2:
                training("coral", "Coral-Menu");
                break;
            case 3:
                training("linear", "Linear-Menu");
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
                                     "zum abschließenden Test! Diesmal wirst du wieder"+
                                     " Items wählen müssen. Allerdings sind es diesmal andere!\n\n"+
                                     "Anschließend gibt es noch einen Fragebogen. <b>Und Cookies</b>!"+
                                     hint("Zum Beginnen Leertaste... wie immer..."));
                int index = GLib.Random.int_range(0, trainings.size);
                set_stage(trainings.get(index));
                trainings.remove_at(index); 
                
                Logger.write("##START_OF_INTERFERENCE_TEST## " + Logger.get_time());
                
                break;
        }
        
        ready = true;
    }
    
    private void next_page_finish() {
        switch (page) {
            case 0: 
                instruction.set_text(heading("Ach nee..") + 
                                     "Du bist ja schon durch jedes Menü durch! "+
                                     "Dann hab herzlichen Dank! Und viel Spaß beim Ausfüllen des Fragebogens!" + 
                                     hint("Beenden mit Leertaste!"));
                break;
            default:
                on_finish();
                break;
        }
        
        ready = true;
    }

    private void training(string type, string name) {
        int repetitions = 0;
        var targets = new Gee.ArrayList<string?>();
        string target = "";
        
        Logger.write("#%s_INTERFERENCE_TEST# ".printf(type.up()));
        
        smile.set_smile_position(new Vector(smile.width()/2, smile.height()/2));
        smile.show_smile(true);

        next request_next = () => {
            if (repetitions == REPETITIONS && targets.size == 0) {
                instruction.set_text(heading("%s-Training".printf(name)) + 
                                     "Sehr gut! Du wirst immer besser! "+
                                     "Wir machen weiter mit dem..."+
                                     hint("Weiter mit Leertaste..."));
                
                smile.show_smile(false);
                menu.enable(false);
                
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
                    if (type == "trace") {
                        targets.add("Avocados|Verwenden als|Antipasti");
                        targets.add("Zitronen|Raspeln");
                        targets.add("Einkaufen gehen");
                    } else if (type == "coral") {
                        targets.add("Wellensittich|Futter geben|Mais");
                        targets.add("Hund|Von Zecken befreien");
                        targets.add("Mehlwürmer kaufen");
                    } else if (type == "linear") {
                        targets.add("Lastkraftwagen|Verkaufen bei|Ebay");
                        targets.add("Personenkraftwagen|Versteuern");
                        targets.add("Moped fahren");
                    }
                    
                    ++repetitions;
                } 
                
                target = targets.get(GLib.Random.int_range(0, targets.size));          
                instruction.set_text(heading("%s-Training".printf(name)) + 
                                     "Wähle den Eintrag \n\n<b>"+ target +"</b>"+
                                     hint("Sobald du das Menü öffnest, verschwindet "+
                                     "dieser Hinweis! Präge ihn dir also gut ein."));
                                     
                targets.remove(target);
            }
        };
        
        request_next();
        
        if (menu == null) menu = new MenuManager();
        menu.init(type, type);
        
        smile.show_smile(true);
        menu.enable(true);
        
        disconnect_handlers();
        
        select_handler = menu.on_select.connect((item, time) => {
            if (item == target) {
                Logger.write("success|%s|%s|%u".printf(menu.get_path_numbers(target), menu.get_path_numbers(item), time));
                smile.make_happy(true);
            } else {
                Logger.write("fail|%s|%s|%u".printf(menu.get_path_numbers(target), menu.get_path_numbers(item), time));
                smile.make_happy(false);
            }

            request_next();
        });
        
        cancel_handler = menu.on_cancel.connect(() => {
            Logger.write("fail|%s|%s|%u".printf(menu.get_path_numbers(target), "-1", -1));
            smile.make_happy(false);
            
            request_next();
        });
        
        open_handler = menu.on_open.connect(() => {
            instruction.set_text("");
        });
    }
    
    private void disconnect_handlers() {
        if (cancel_handler > 0)
            menu.disconnect(cancel_handler);
            
        if (select_handler > 0)
            menu.disconnect(select_handler);
            
        if (open_handler > 0)
            menu.disconnect(open_handler);
        
        cancel_handler = 0;
        select_handler = 0;
        open_handler = 0;
    }
    
    private string heading(string text) {
        return "<span size='25000'><b>" + text + "</b></span>\n\n";
    }
    
    private string hint(string text) {
        return "\n\n<span size='15000' style='italic'>" + text + "</span>";
    }

}
