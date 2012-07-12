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

public class Test : GLib.Object {

    private InstructionWindow   instruction;
    private SmileWindow         smile;
    private BindingManager      bindings = null;
    private MenuManager         menu = null;
    
    private bool ready = false;
    private int stage = 0;
    private int page = 0;
    
    private ulong cancel_handler = 0;
    private ulong select_handler = 0;

    public void init() {
        instruction = new InstructionWindow();
        smile = new SmileWindow();
        
        bindings = new BindingManager();
        bindings.bind(new Trigger.from_string("space"), "next");
        //bindings.bind(new Trigger.from_string("BackSpace"), "back");
        
        bindings.on_press.connect((id) => {
            if (ready && id=="next") {
                next_page();
            } else if (ready && id == "back") {
                prev_page();
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
                next_page_test_trace();
                break;
        }
        
        ++page;
    }
    
    private void prev_page() {
    
        if (page > 1) {
            page -= 2;
        
            switch (stage) {
                case 0:
                    next_page_introduction();
                    break;
                case 1:
                    next_page_test_trace();
                    break;
            }
            
            ++page;
        }
    }
    
    private void next_page_introduction() {
        switch (page) {
            case 0: 
                instruction.set_text(heading("Willkommen") + 
                                     "zum ultimativen <b>Piemenü-Test</b>! \n" +
                                     "Mach es dir gemütlich; diese Textmeldungen werden"+
                                     " dich Stück für Stück durch den gesamten Text führen."+ 
                                     hint("Weiter mit Leertaste..."));
                break;
            
            case 1: 
                instruction.set_text(heading("Einführung") + 
                                     "Im folgenden wirst du einigen unterhaltsamen "+
                                     "Tests mit verschiedenen Menüarten unterzogen." +
                                     hint("Weiter mit Leertaste..."));
                break;    
                
            case 2: 
                instruction.set_text(heading("Einführung") +
                                     "Dabei wirst du alles geben müssen. Aber das Beste ist: Danach gibt's Cookies!" + 
                                     hint("Leertaste um mit dem ersten Test zu beginnen..."));
                set_stage(1);
                break;
        }
        
        ready = true;
    }
    
    
    
    
    private void next_page_test_trace() {
        switch (page) {
            case 0: 
                instruction.set_text(heading("Erster Versuch: Trace-Menu") + 
                                     "Das Menü, mit dem du dich nun beschäftigen wirst," +
                                     " ist der Prototyp eines Piemenüs mit \"Marking-Mode\".\n\n" +
                                     "Es ist <b>nur ein Prototyp</b>: Wenn du Einträge des Menüs "+
                                     "wählst wird das nichts bewirken, du kannst dich also austoben!"+
                                     hint("Weiter mit Leertaste..."));
                break;
            case 1: 
                instruction.set_text(heading("Erster Versuch: Trace-Menu") + 
                                     "Um dich mit dem Menü vertraut zu machen, "+
                                     "klicke mit der <b>rechten Maustaste</b> "+
                                     "auf den Smile. Es wird sich ein Kontextmenü zu öffnen. \n\n"+
                                     "Wähle <b>mehrmals beliebige "+
                                     "Einträge</b> aus bis du die Funktionsweise des" +
                                     " Menüs verstanden hast."+ 
                                     hint("Sobald du dich im Umgang mit dem Menü"+
                                          " sicher fühlst, betätige die Leertaste."));
                
                menu = new MenuManager();
                menu.init("trace", "real");

                break;
                
            case 2: 
                instruction.set_text(heading("Erster Versuch: Trace-Menu") + 
                                     "Dieser Menütyp hat einen Expertenmodus. Um ihn zu benutzen, "+
                                     "halte die rechte Maustaste gedrückt und <b>zeichne den Pfad</b> "+
                                     "zu dem gewünschten Eintrag.\n\n"+ 
                                     "<b>Mach dich mit dem Modus vertraut</b> indem du diverse Einträge "+
                                     "auswählst, wie zum Beispiel \"Datei - Speichern als - Sound-Datei\"!"+
                                     hint("Sobald du dich im Umgang mit dem Experten-Modus"+
                                          " sicher fühlst, betätige die Leertaste."));

                break;
                
            case 3:
                instruction.set_text(heading("Erster Versuch: Trace-Menu") + 
                                     "Sehr gut!\n\nDeine nächste Aufgabe ist es,"+
                                     " vorgegebene Einträge möglichst schnell "+
                                     "auszuwählen."+
                                     hint("Weiter mit Leertaste..."));
                break;
                
            case 4:
                instruction.set_text(heading("Erster Versuch: Trace-Menu") + 
                                     "Zunächst nehmen wir ein tiefes Menü mit wenigen Einträgen"+
                                     " pro Hierachiestufe. \n\n"+
                                     "Die Zeitmessung wird gestartet, "+
                                     "sobald du das Menü öffnest. Also lass dir "+
                                     "zwischendurch ruhig Zeit!" + 
                                     hint("Leertaste um mit dem Test zu beginnen..."));
                break;
                
            case 5:
            
                menu.init("trace", "static", 6, 3);
                
                var target = menu.get_valid_entry();
            
                instruction.set_text(heading("Erster Versuch: Trace-Menu") + 
                                     "Aktiviere den Eintrag:\n<b>" + target + "</b>");
                
                
                
                disconnect_handlers();
                
                select_handler = menu.on_select.connect((item, time) => {
                    if (item == target) {
                        debug("%u", time);
                        smile.notify(true);
                    } else {
                        debug("fail");
                        smile.notify(false);
                    }
                });
                
                cancel_handler = menu.on_cancel.connect(() => {
                    debug("cancel");
                });
                
                break;
        }
        
        ready = true;
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
