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

public class G2_Introduction : GLib.Object {

    public signal void on_finish();

    private InstructionWindow   instruction;
    private SmileWindow         smile;
    private BindingManager      bindings = null;
    private MenuManager         menu = null;
    
    private bool ready = false;
    private bool semi_ready = false;
    private int stage = 0;
    private int page = 0;
    
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
        bindings.bind(new Trigger.from_string("<ctrl>space"), "semi_next");
        
        bindings.on_press.connect((id) => {
            if (ready && id=="next") {
                ready = false;
                next_page();
            } 
            
            if (semi_ready && id=="semi_next") {
                semi_ready = false;
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
                introduction("trace", "Trace-Menu");
                break;
            case 2:
                introduction("coral", "Coral-Menu");
                break;
            case 3:
                introduction("linear", "Linear-Menu");
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
                                     "Sitzt du nach wie vor gemütlich? Diese Textmeldungen werden"+
                                     " dich Stück für Stück durch den weiteren Test führen."+ 
                                     hint("Weiter mit Leertaste..."));
                break;
            
            case 1: 
                instruction.set_text(heading("Einführung") + 
                                     "Im Folgenden wirst du mit verschiedenen "+
                                     "Menüarten bekannt gemacht.\n\n" +
                                     "Später wird es deine Aufgabe sein, den Umgang mit diesen "+
                                     "Menüs zu üben und zu bewerten."+
                                     hint("Weiter mit Leertaste..."));
                break;    
                
            case 2: 
                instruction.set_text(heading("Einführung") +
                                     "Dabei wirst du alles geben müssen. Aber das Beste ist: Danach gibt's Cookies!\n\n" +
                                     "Beginnen wir mit dem ersten Menü..." +  
                                     hint("Leertaste um mit dem ersten Menü zu beginnen..."));
                
                int index = GLib.Random.int_range(0, trainings.size);
                set_stage(trainings.get(index));
                trainings.remove_at(index); 
                
                break;
        }
        
        ready = true;
    }
    
    private void next_page_finish() {
        switch (page) {
            case 1: 
                instruction.set_text(heading("Ach nee..") + 
                                     "Du bist ja schon durch jedes Menü durch! "+
                                     "Dann hab schon einmal Dank für deine Teilnahme bis hierher!" + 
                                     hint("Weiter mit Leertaste..."));
                break;
            case 2: 
                instruction.set_text(heading("Ausblick") + 
                                     "In der folgenden Testeinheit lernst du die Menüeinträge kennen, die du " +
                                     "in den nächsten Tagen üben wirst." +
                                     hint("Beenden mit Leertaste."));
                break;
            default:
                on_finish();
                break;
        }
        
        ready = true;
    }

    private void introduction(string type, string name) {
        switch (page) {
            case 1: 
                instruction.set_text(heading("Das %s".printf(name)) + 
                                     "Das Menü, mit dem du dich nun beschäftigen wirst, " +
                                     "ist <b>nur ein Prototyp</b>: Wenn du Einträge des Menüs "+
                                     "wählst wird das nichts bewirken, du kannst dich also austoben!"+
                                     hint("Weiter mit Leertaste..."));
                ready = true;
                break;
            case 2: 
                instruction.set_text(heading("Das %s".printf(name)) + 
                                     "Um dich mit dem Menü vertraut zu machen, "+
                                     "klicke mit der <b>rechten Maustaste "+
                                     "auf den Smile</b>. Es wird sich ein Menü öffnen. "+
                                     "Um die Funktionsweise des" +
                                     " Menüs zu verstehen, wähle die Einträge \n\n"+
                                     "<b>Ansicht|Vollbild</b>\n"+
                                     "<b>Datei|Druckvorschau</b>\n"+
                                     "<b>Ansicht|Hervorhebungsmodus|Auszeichnung|Latex</b>\n\n"+
                                     "jeweils mindestens einmal aus!"+
                                     hint("Sobald du dich im Umgang mit dem Menü"+
                                          " sicher fühlst, sag dem Versuchsleiter Bescheid!"));
                
                smile.set_smile_position(new Vector(smile.width()/2, smile.height()/2));
                
                
                if (menu == null) menu = new MenuManager();
                menu.init(type, "real");
                
                smile.show_smile(true);
                menu.enable(true);
                
                if (type != "trace")
                    page++;
                
                semi_ready = true;
                break;
                
            case 3: 
                instruction.set_text(heading("Das %s".printf(name)) + 
                                     "Dieser Menütyp hat einen Expertenmodus. Um ihn zu benutzen, "+
                                     "halte die rechte Maustaste gedrückt und <b>zeichne den Pfad</b> "+
                                     "zu dem gewünschten Eintrag."+ 
                                     "Um den Modus" +
                                     " zu verstehen, wähle die Einträge \n\n"+
                                     "<b>Ansicht|Vollbild</b>\n"+
                                     "<b>Datei|Druckvorschau..</b>\n"+
                                     "<b>Ansicht|Hervorhebungsmodus|Auszeichnung|Latex</b>\n\n"+
                                     "jeweils mindestens einmal im Tracing-Mode aus!"+
                                     hint("Sobald du dich im Umgang mit dem Menü"+
                                          " sicher fühlst, sag dem Versuchsleiter Bescheid!"));
                semi_ready = true;
                break;
                
            case 4: 
                instruction.set_text(heading("Das %s".printf(name)) + 
                                     "So viel zu diesem Menü. Machen wir weiter mit dem nächsten Menütyp."+
                                     hint("Leertaste um mit dem nächsten Typ zu beginnen!"));
                
                smile.show_smile(false);
                menu.enable(false);
                            
                if (trainings.size > 0) {
                    int index = GLib.Random.int_range(0, trainings.size);
                    set_stage(trainings.get(index));
                    trainings.remove_at(index); 
                } else {
                    set_stage(4);
                }  
                
                ready = true;
                break;
        }
        
        
    }

    
    private string heading(string text) {
        return "<span size='25000'><b>" + text + "</b></span>\n\n";
    }
    
    private string hint(string text) {
        return "\n\n<span size='15000' style='italic'>" + text + "</span>";
    }

}
