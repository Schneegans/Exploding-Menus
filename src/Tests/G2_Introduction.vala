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
                introduction_trace();
                break;
            case 2:
                introduction_coral();
                break;
            case 3:
                introduction_linear();
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
                                     "Im folgenden wirst du mit verschiedenen, "+
                                     "unkonventionellen Menüarten bekannt gemacht.\n\n" +
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
   
    
    private void introduction_trace() {
        switch (page) {
            case 1: 
                instruction.set_text(heading("Das Trace-Menu") + 
                                     "Das Menü, mit dem du dich nun beschäftigen wirst," +
                                     " ist der Prototyp eines Piemenüs mit \"Marking-Mode\".\n\n" +
                                     "Es ist <b>nur ein Prototyp</b>: Wenn du Einträge des Menüs "+
                                     "wählst wird das nichts bewirken, du kannst dich also austoben!"+
                                     hint("Weiter mit Leertaste..."));
                break;
            case 2: 
                instruction.set_text(heading("Das Trace-Menu") + 
                                     "Um dich mit dem Menü vertraut zu machen, "+
                                     "klicke mit der <b>rechten Maustaste</b> "+
                                     "auf den Smile. Es wird sich ein Kontextmenü zu öffnen. \n\n"+
                                     "Wähle <b>mehrmals beliebige "+
                                     "Einträge</b> aus bis du die Funktionsweise des" +
                                     " Menüs verstanden hast."+ 
                                     hint("Sobald du dich im Umgang mit dem Menü"+
                                          " sicher fühlst, betätige die Leertaste."));
                
                if (menu == null) menu = new MenuManager();
                menu.init("trace", "real");

                break;
                
            case 3: 
                instruction.set_text(heading("Das Trace-Menu") + 
                                     "Dieser Menütyp hat einen Expertenmodus. Um ihn zu benutzen, "+
                                     "halte die rechte Maustaste gedrückt und <b>zeichne den Pfad</b> "+
                                     "zu dem gewünschten Eintrag.\n\n"+ 
                                     "<b>Mach dich mit dem Modus vertraut</b> indem du diverse Einträge "+
                                     "auswählst, wie zum Beispiel \"Datei - Speichern als - Sound-Datei\"!"+
                                     hint("Sobald du dich im Umgang mit dem Experten-Modus"+
                                          " sicher fühlst, betätige die Leertaste."));

                break;
            case 4: 
                instruction.set_text(heading("Das Trace-Menu") + 
                                     "So viel zu diesem Menü. Machen wir weiter mit dem nächsten Menütyp."+
                                     hint("Leertaste um mit dem nächsten Typ zu beginnen!"));
                                     
                if (trainings.size > 0) {
                    int index = GLib.Random.int_range(0, trainings.size);
                    set_stage(trainings.get(index));
                    trainings.remove_at(index); 
                } else {
                    set_stage(4);
                }  

                break;
        }
        
        ready = true;
    }
    
    private void introduction_coral() {
        switch (page) {
            case 1: 
                instruction.set_text(heading("Das Coral-Menu") + 
                                     "Das Menü, mit dem du dich nun beschäftigen wirst," +
                                     " ist der Prototyp eines Piemenüs mit innovativer Itemanordnung.\n\n" +
                                     "Es ist <b>nur ein Prototyp</b>: Wenn du Einträge des Menüs "+
                                     "wählst wird das nichts bewirken, du kannst dich also austoben!"+
                                     hint("Weiter mit Leertaste..."));
                break;
            case 2: 
                instruction.set_text(heading("Das Coral-Menu") + 
                                     "Um dich mit dem Menü vertraut zu machen, "+
                                     "klicke mit der <b>rechten Maustaste</b> "+
                                     "auf den Smile. Es wird sich ein Kontextmenü zu öffnen. \n\n"+
                                     "Wähle <b>mehrmals beliebige "+
                                     "Einträge</b> aus bis du die Funktionsweise des" +
                                     " Menüs verstanden hast."+ 
                                     hint("Sobald du dich im Umgang mit dem Menü"+
                                          " sicher fühlst, betätige die Leertaste."));
                
                if (menu == null) menu = new MenuManager();
                menu.init("coral", "real");

                break;
            case 3: 
                instruction.set_text(heading("Das Coral-Menu") + 
                                     "So viel zu diesem Menü. Machen wir weiter mit dem nächsten Menütyp."+
                                     hint("Leertaste um mit dem nächsten Typ zu beginnen!"));
                                     
                if (trainings.size > 0) {
                    int index = GLib.Random.int_range(0, trainings.size);
                    set_stage(trainings.get(index));
                    trainings.remove_at(index); 
                } else {
                    set_stage(4);
                }  

                break;
        }
        
        ready = true;
    }
    
    private void introduction_linear() {
        switch (page) {
            case 1: 
                instruction.set_text(heading("Das Lineare Menü") + 
                                     "Das Menü, mit dem du dich nun beschäftigen wirst," +
                                     " ist eine Nachbildung eines normalen Menüs. Es"+
                                     " dient als Vergleichsbasis zu den anderen Menütypen.\n\n" +
                                     "Es ist <b>nur ein Prototyp</b>: Wenn du Einträge des Menüs "+
                                     "wählst wird das nichts bewirken, du kannst dich also austoben!"+
                                     hint("Weiter mit Leertaste..."));
                break;
            case 2: 
                instruction.set_text(heading("Das Lineare Menü") + 
                                     "Um dich mit dem Menü vertraut zu machen, "+
                                     "klicke mit der <b>rechten Maustaste</b> "+
                                     "auf den Smile. Es wird sich ein Kontextmenü zu öffnen. \n\n"+
                                     "Wähle <b>mehrmals beliebige "+
                                     "Einträge</b> aus bis du die Funktionsweise des" +
                                     " Menüs verstanden hast."+ 
                                     hint("Sobald du dich im Umgang mit dem Menü"+
                                          " sicher fühlst, betätige die Leertaste."));
                
                if (menu == null) menu = new MenuManager();
                menu.init("linear", "real");

                break;
                
            case 3: 
                instruction.set_text(heading("Das Lineare Menü") + 
                                     "So viel zu diesem Menü. Machen wir weiter mit dem nächsten Menütyp."+
                                     hint("Leertaste um mit dem nächsten Typ zu beginnen!"));
                                     
                if (trainings.size > 0) {
                    int index = GLib.Random.int_range(0, trainings.size);
                    set_stage(trainings.get(index));
                    trainings.remove_at(index); 
                } else {
                    set_stage(4);
                }  

                break;
        }
        
        ready = true;
    }

    
    private string heading(string text) {
        return "<span size='25000'><b>" + text + "</b></span>\n\n";
    }
    
    private string hint(string text) {
        return "\n\n<span size='15000' style='italic'>" + text + "</span>";
    }

}
