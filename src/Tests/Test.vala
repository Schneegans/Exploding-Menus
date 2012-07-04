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
    private int state = 0;
    
    private ulong cancel_handler = 0;
    private ulong select_handler = 0;

    public void init() {
        instruction = new InstructionWindow();
        smile = new SmileWindow();
        
        bindings = new BindingManager();
        bindings.bind(new Trigger.from_string("space"), "buh");
        
        bindings.on_press.connect((id) => {
            if (ready) {
                ++state;
                next_stage();
            }
        });
        
        instruction.open();
        smile.open();

        next_stage();
    }
    
    private void next_stage() {
        switch (state) {
            case 0: 
                instruction.set_text("Willkommen zum ultimativen <b>Piemenü-Test</b>!" + hint("Weiter mit Leertaste..."));
                break;
            
            case 1: 
                instruction.set_text(heading("Einführung") + "Im folgenden wirst du einigen unterhaltsamen Tests mit verschiedenen Menüarten unterzogen." + hint("Weiter mit Leertaste..."));
                break;    
                
            case 2: 
                instruction.set_text(heading("Einführung") + "Und das beste: Danach gibt's Cookies!" + hint("Weiter mit Leertaste..."));
                break; 
            
            case 3: 
                instruction.set_text(heading("Erster Versuch") + "Klicke mit der <b>rechten Maustaste</b> auf den Smile, um ein Kontextmenü zu öffnen. Mach dich zunächst mit der Funktionsweise des Menüs vertraut, indem du <b>mehrmals beliebige Einträge</b> auswählst." + hint("Sobald du dich im Umgang mit dem Menü sicher fühlst, betätige die Leertaste."));
                
                menu = new MenuManager();
                menu.init("linear", "real");

                break;
                
            case 4:
                instruction.set_text(heading("Erster Versuch") + "Sehr gut!\n\nDeine nächste Aufgabe ist es, vorgegebene Einträge möglichst schnell auszuwählen. Die Zeitmessung wird gestartet, sobald du das Menü öffnest. Also lass dir vorher ruhig Zeit!" + hint("Drücke Leertaste zum Beginnen!"));
                break;
                
            case 5:
                instruction.set_text(heading("Erster Versuch") + "Aktiviere den Eintrag:\n<b>Datei - Speichern</b>");
            
                disconnect_handlers();
                
                select_handler = menu.on_select.connect((item, time) => {
                    debug("%u: %s", time, item);
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
