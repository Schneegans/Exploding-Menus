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

public class G1_Final : GLib.Object {

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
    
    private const int REPETITIONS_SEARCH = 5;
    private const int REPETITIONS_FITT = 5;
    
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
                                     "zum ultimativen <b>Piemenü-Test</b>! \n" +
                                     "Mach es dir gemütlich; diese Textmeldungen werden"+
                                     " dich Stück für Stück durch den gesamten Test führen."+ 
                                     hint("Weiter mit Leertaste..."));
                break;
            
            case 1: 
                instruction.set_text(heading("Einführung") + 
                                     "Im Folgenden wirst du mit verschiedenen, "+
                                     "unkon-ventionellen Menüarten bekannt gemacht.\n\n" +
                                     "Dabei wird es deine Aufgabe sein, Einträge in diesen "+
                                     "Menüs zu suchen und auszuwählen."+
                                     hint("Weiter mit Leertaste..."));
                break;    
                
            case 2: 
                instruction.set_text(heading("Einführung") +
                                     "Und du wirst dabei alles geben müssen. "+
                                     "Aber das Beste ist: Danach gibt's Cookies!\n\n" +
                                     "Beginnen wir mit dem ersten Menü..." +  
                                     hint("Leertaste um mit dem ersten Menü zu beginnen..."));
                
                int index = GLib.Random.int_range(0, trainings.size);
                set_stage(trainings.get(index));
                trainings.remove_at(index); 
                page--;
                
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
        switch (page) {
            case 0: 
                instruction.set_text(heading("Das %s".printf(name)) + 
                                     "Das Menü, mit dem du dich nun beschäftigen wirst," +
                                     "ist <b>nur ein Prototyp</b>: Wenn du Einträge des Menüs "+
                                     "wählst, wird das nichts bewirken, du kannst dich also austoben!"+
                                     hint("Weiter mit Leertaste..."));
                                     
                if (menu == null) menu = new MenuManager();
                menu.init(type, "real");                     
                
                ready = true;
                break;
                
            case 1: 
                instruction.set_text(heading("Das %s".printf(name)) + 
                                     "Um dich mit dem Menü vertraut zu machen, "+
                                     "klicke mit der <b>rechten Maustaste "+
                                     "auf den Smile</b>. Es wird sich ein Menü öffnen. \n\n"+
                                     "Wähle <b>mehrmals beliebige "+
                                     "Einträge</b> aus, bis du die Funktionsweise des" +
                                     " Menüs verstanden hast."+ 
                                     hint("Sobald du dich im Umgang mit dem Menü"+
                                          " sicher fühlst, betätige die Leertaste."));
                
                if (type != "trace")
                    ++page;
                
                ready = true;
                break;
                
            case 2: 
                instruction.set_text(heading("Das %s".printf(name)) + 
                                     "Dieser Menütyp hat einen Expertenmodus. Um ihn zu benutzen, "+
                                     "halte die rechte Maustaste gedrückt und <b>zeichne den Pfad</b> "+
                                     "zu dem gewünschten Eintrag.\n\n"+ 
                                     "<b>Mach dich mit dem Modus vertraut</b> indem du diverse Einträge "+
                                     "auswählst, wie zum Beispiel \"Ansicht|Vollbild\"!"+
                                     hint("Sobald du dich im Umgang mit dem Experten-Modus"+
                                          " sicher fühlst, betätige die Leertaste."));
                ready = true;
                break;
                
            case 3:
                instruction.set_text(heading("Das %s".printf(name)) + 
                                     "Sehr gut! Nun fangen wir mit dem eigentlichen Test an. \n\nIm folgenden"+
                                     " werden dir Einträge gezeigt, die du so schnell wie möglich auswählen sollst."+
                                     hint("Weiter mit Leertaste..."));
                ready = true;
                break;
                
            case 4:
                instruction.set_text(heading("Das %s".printf(name)) + 
                                     "Die Zeit, die du vom Öffnen des Menüs bis zur Auswahl benötigst, wird gemessen."+
                                     " Vor dem Öffnen kannst du dir also jeweils Zeit lassen!\n\n"+
                                     "Außerdem ist das Menü immer ein anderes. Du kannst dir also nichts"+
                                     " merken und musst immer neu suchen.\n\n"+
                                     "Viel Spaß!"+
                                     hint("Beginnen mit Leertaste..."));
                ready = true;
                break;
                                
            case 5:
                
                int repetitions = 0;
                int depth = 0;
                int width = 0;
                string target = "";
                
                Logger.write("#%s_SEARCH_TEST# ".printf(type.up()));

                next request_next = () => {
                    if (repetitions == REPETITIONS_SEARCH) {
                        instruction.set_text(heading("Das %s".printf(name)) + 
                                             "Sehr gut! Das hast du echt gut gemacht! \n\n"+
                                             "Nun ist es an der Zeit mit einem weiteren Test zu beginnen. "+
                                             hint("Weiter mit Leertaste..."));
                        
                        disconnect_handlers();
                        ready = true;
                        
                    } else {
                    
                        ++repetitions;
                        
                        width = GLib.Random.int_range(5, 15);
                        depth = GLib.Random.int_range(1, 4);
                        
                        menu.init(type, "random", width, depth);
                        
                        target = menu.get_valid_entry();
                        instruction.set_text(heading("Das %s".printf(name)) + 
                                             "Wähle den Eintrag <b>"+ target +"</b>"+
                                             hint("Sobald du das Menü öffnest, verschwindet "+
                                             "dieser Hinweis! Präge ihn dir also gut ein."));
                    }
                };
                
                request_next();
                
                if (menu == null) menu = new MenuManager();
                
                disconnect_handlers();
                
                select_handler = menu.on_select.connect((item, time) => {
                    debug("%s %s", item, target);
                    if (item == target) {
                        Logger.write("%s: %u %u %u".printf(target, time, width, depth));
                        smile.notify(true);
                    } else {
                        Logger.write("%s: -1 %u %u".printf(target, width, depth));
                        smile.notify(false);
                    }

                    request_next();
                });
                
                cancel_handler = menu.on_cancel.connect(() => {
                    Logger.write("%s: -1 %u %u".printf(target, width, depth));
                    smile.notify(false);
                    
                    request_next();
                });
                
                open_handler = menu.on_open.connect(() => {
                    instruction.set_text("");
                });
                
                
                break;
                
                
             case 6:
                
                instruction.set_text(heading("Das %s".printf(name)) + 
                                     "Der nächste Test ist genau das Gegenteil. "+
                                     hint("Weiter mit Leertaste..."));
                ready = true;
                break;
                
            case 7:
                
                instruction.set_text(heading("Das %s".printf(name)) + 
                                     "Wieder ist es deine Aufgabe, Einträge so schnell"+
                                     " wie möglich zu wählen. Allerdings wechseln"+
                                     " sie nun nicht ihre Position und du musst ein "+
                                     "und den selben Eintrag sehr häufig auswählen. \n\n"+
                                     "Dabei kannst du üben, um ihn am Ende irre "+
                                     "schnell auswählen zu können!"+
                                     hint("Beginnen mit Leertaste..."));
                ready = true;
                break;
                
            case 8:
                
                int repetitions = 1;
                var targets = new Gee.ArrayList<string?>();
                
                if (type == "trace") {
                    targets.add("Avocados|Verwenden als|Nachtisch");
                    targets.add("Zitronen|Pressen");
                    targets.add("Pizza bestellen");
                } else if (type == "coral") {
                    targets.add("Wellensittich|Futter geben|Weizen");
                    targets.add("Hund|Waschen");
                    targets.add("Ameisenfarm versorgen");
                } else if (type == "linear") {
                    targets.add("Lastkraftwagen|Verkaufen bei|Flohmarkt");
                    targets.add("Personenkraftwagen|Verschrotten");
                    targets.add("Zur Fahrschule gehen");
                }
                    
                string target = "";
                
                Logger.write("#%s_FITT_TEST# ".printf(type.up()));

                next request_next = () => {
                    --repetitions;
                
                    if (repetitions == 0 && targets.size == 0) {
                        instruction.set_text(heading("Das %s".printf(name)) + 
                                             "Sehr gut! Das war echt schnell! \n\n"+
                                             "Nun ist es an der Zeit, mit dem nächsten"+
                                             " Menütyp weiterzumachen."+
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
                    
                        if (repetitions == 0) {
                            target = targets.get(GLib.Random.int_range(0, targets.size));                
                            targets.remove(target);
                            
                            repetitions = REPETITIONS_FITT;
                            
                            instruction.set_text(heading("Das %s".printf(name)) + 
                                             "Wähle den Eintrag <b>"+ target +"</b>"+
                                             " insgesamt <b>%ix</b> aus!".printf(repetitions) + 
                                             hint("Sobald du das Menü öffnest, verschwindet "+
                                             "dieser Hinweis! Präge ihn dir also gut ein."));
                        } else {
                            instruction.set_text(heading("Das %s".printf(name)) + 
                                             "Wähle den Eintrag <b>"+ target +"</b>"+
                                             "noch <b>%ix</b> aus!".printf(repetitions));
                        }
                    }
                };
                
                request_next();
                
                if (menu == null) menu = new MenuManager();
                menu.init(type, type);
                
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
                
                open_handler = menu.on_open.connect(() => {
                    instruction.set_text("");
                });

                break;
        } 
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
