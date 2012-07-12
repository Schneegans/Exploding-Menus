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

public class MenuManager : GLib.Object {

    public signal void on_select(string item, uint milliseconds);
    public signal void on_cancel();

    private BindingManager bindings = null;
    private Menu menu = null;
    private MenuItem model = null;
    
    private string type;
    private string mode;
    private int depth;
    private int width;
    
    private ulong cancel_handler;
    private ulong select_handler;
    
    public MenuManager() {
    
        bindings = new BindingManager();
        bindings.bind(new Trigger.from_string("button3"), "button2");
        
        bindings.on_press.connect((id) => {
            menu.set_structure(model);
            menu.show();
        }); 
    }
    
    public void init(string menu_type, string menu_mode, int width = 7, int depth = 2) {
        this.type = menu_type;
        this.mode = menu_mode;
        this.width = width;
        this.depth = depth;
        
        if (menu != null) {
            menu.disconnect(cancel_handler);
            menu.disconnect(select_handler);
        }
        
        if (type == "linear")     menu = new LinearMenu();
        else if (type == "coral") menu = new CoralMenu();
        else                      menu = new TraceMenu();
        
        cancel_handler = menu.on_cancel.connect(() => {
            on_cancel();
        });
        
        select_handler = menu.on_select.connect((item, time) => {
            on_select(item, time);
        });
        
        model = setup_menu(mode);
    }
    
    public string get_valid_entry() {
        return model.get_valid_entry();
    }
    
    private MenuItem setup_menu(string menu_mode) {
        if (menu_mode == "random")       
            return setup_name_menu(true, width, depth);
            
        if (menu_mode == "static")       
            return setup_name_menu(false, width, depth);
        
        return setup_gedit_menu();
    }

    private MenuItem setup_gedit_menu() {
    
        var root = new MenuItem("Hauptmenü", "");
        
            var file = new MenuItem("Datei", "");
                file.add_child(new MenuItem("Neu...", "file_new"));
                file.add_child(new MenuItem("Öffnen...", "fileopen"));
                file.add_child(new MenuItem("Speichern", "filesave"));
                
                var tmp = new MenuItem("Speichern als", "filesaveas");
                    tmp.add_child(new MenuItem("Text-Datei", ""));
                    tmp.add_child(new MenuItem("Bild-Datei", ""));
                    tmp.add_child(new MenuItem("Sound-Datei", ""));
                    tmp.add_child(new MenuItem("Video-Datei", ""));
                file.add_child(tmp);
                
                file.add_child(new MenuItem("Zurücksetzen", ""));
                file.add_child(new MenuItem("Drucken...", "fileprint"));
                file.add_child(new MenuItem("Druckvorschau", "preview-file"));
            
            root.add_child(file);
            
            var edit = new MenuItem("Bearbeiten", "gtk-edit");
                edit.add_child(new MenuItem("Rückgängig", "edit-undo"));
                edit.add_child(new MenuItem("Wiederholen", "edit-redo"));
                edit.add_child(new MenuItem("Ausschneiden", "editcut"));
                edit.add_child(new MenuItem("Kopieren", "edit-copy"));
                edit.add_child(new MenuItem("Einfügen", "editpaste"));
                edit.add_child(new MenuItem("Einstellungen", ""));
                
                edit.add_child(new MenuItem("Rückgängig", "edit-undo"));
                edit.add_child(new MenuItem("Wiederholen", "edit-redo"));
                edit.add_child(new MenuItem("Ausschneiden", "editcut"));
                edit.add_child(new MenuItem("Kopieren", "edit-copy"));
                edit.add_child(new MenuItem("Einfügen", "editpaste"));
                edit.add_child(new MenuItem("Einstellungen", ""));
                
                edit.add_child(new MenuItem("Rückgängig", "edit-undo"));
                edit.add_child(new MenuItem("Wiederholen", "edit-redo"));
                edit.add_child(new MenuItem("Ausschneiden", "editcut"));
                edit.add_child(new MenuItem("Kopieren", "edit-copy"));
                edit.add_child(new MenuItem("Einfügen", "editpaste"));
                edit.add_child(new MenuItem("Einstellungen", ""));
                
                edit.add_child(new MenuItem("Rückgängig", "edit-undo"));
                edit.add_child(new MenuItem("Wiederholen", "edit-redo"));
                edit.add_child(new MenuItem("Ausschneiden", "editcut"));
                edit.add_child(new MenuItem("Kopieren", "edit-copy"));
                edit.add_child(new MenuItem("Einfügen", "editpaste"));
                edit.add_child(new MenuItem("Einstellungen", ""));
                
                edit.add_child(new MenuItem("Rückgängig", "edit-undo"));
                edit.add_child(new MenuItem("Wiederholen", "edit-redo"));
                edit.add_child(new MenuItem("Ausschneiden", "editcut"));
                edit.add_child(new MenuItem("Kopieren", "edit-copy"));
                edit.add_child(new MenuItem("Einfügen", "editpaste"));
                edit.add_child(new MenuItem("Einstellungen", ""));
                
                edit.add_child(new MenuItem("Rückgängig", "edit-undo"));
                edit.add_child(new MenuItem("Wiederholen", "edit-redo"));
                edit.add_child(new MenuItem("Ausschneiden", "editcut"));
                edit.add_child(new MenuItem("Kopieren", "edit-copy"));
                edit.add_child(new MenuItem("Einfügen", "editpaste"));
                edit.add_child(new MenuItem("Einstellungen", ""));
                
                edit.add_child(new MenuItem("Rückgängig", "edit-undo"));
                edit.add_child(new MenuItem("Wiederholen", "edit-redo"));
                edit.add_child(new MenuItem("Ausschneiden", "editcut"));
                edit.add_child(new MenuItem("Kopieren", "edit-copy"));
                edit.add_child(new MenuItem("Einfügen", "editpaste"));
                edit.add_child(new MenuItem("Einstellungen", ""));
            root.add_child(edit);
            
            var view = new MenuItem("Ansicht", "");
                view.add_child(new MenuItem("Vollbild", "view-fullscreen"));
                
                tmp = new MenuItem("Hervorhebungsmodus", "");
                
                    tmp.add_child(new MenuItem("Reiner Text", ""));
                    
                    var tmp2 = new MenuItem("Quellcode", "");
                        tmp2.add_child(new MenuItem("HTML", ""));
                        tmp2.add_child(new MenuItem("C++", ""));
                        tmp2.add_child(new MenuItem("Vala", ""));
                        tmp2.add_child(new MenuItem("Python", ""));
                        tmp2.add_child(new MenuItem("Ruby", ""));
                        tmp2.add_child(new MenuItem("Shell", ""));
                        
                        tmp2.add_child(new MenuItem("C++", ""));
                        tmp2.add_child(new MenuItem("Vala", ""));
                        tmp2.add_child(new MenuItem("Python", ""));
                        tmp2.add_child(new MenuItem("Ruby", ""));
                        tmp2.add_child(new MenuItem("Shell", ""));
                    tmp.add_child(tmp2);
                    
                    tmp2 = new MenuItem("Auszeichnung", "");
                        tmp2.add_child(new MenuItem("BibTex", ""));
                        tmp2.add_child(new MenuItem("Latex", ""));
                        tmp2.add_child(new MenuItem("XSLT", ""));
                        tmp2.add_child(new MenuItem("XML", ""));
                        
                        tmp2.add_child(new MenuItem("C++", ""));
                        tmp2.add_child(new MenuItem("Vala", ""));
                        tmp2.add_child(new MenuItem("Python", ""));
                        tmp2.add_child(new MenuItem("Ruby", ""));
                        tmp2.add_child(new MenuItem("Shell", ""));
                    tmp.add_child(tmp2);
                
                    tmp2 = new MenuItem("Wissenschaftlich", "");
                        tmp2.add_child(new MenuItem("MatLab", ""));
                        tmp2.add_child(new MenuItem("GAP", ""));
                        tmp2.add_child(new MenuItem("Octave", ""));
                        tmp2.add_child(new MenuItem("R", ""));
                        
                        tmp2.add_child(new MenuItem("C++", ""));
                        tmp2.add_child(new MenuItem("Vala", ""));
                        tmp2.add_child(new MenuItem("Python", ""));
                        tmp2.add_child(new MenuItem("Ruby", ""));
                        tmp2.add_child(new MenuItem("Shell", ""));
                    tmp.add_child(tmp2);
                    
                view.add_child(tmp);
                
            root.add_child(view);
            
            var search = new MenuItem("Suchen", "stock_search");
                search.add_child(new MenuItem("Suchen...", ""));
                search.add_child(new MenuItem("Ersetzen...", ""));
                search.add_child(new MenuItem("Gehe zu Zeile...", ""));
            root.add_child(search);
            
            var tools = new MenuItem("Werkzeuge", "");
                tools.add_child(new MenuItem("Rechtschreibung prüfen...", "tools-check-spelling"));
                tools.add_child(new MenuItem("Rechtschreibfehler hervorheben", ""));
                
                tmp = new MenuItem("Sprache festlegen", "");
                    tmp.add_child(new MenuItem("Deutsch", ""));
                    tmp.add_child(new MenuItem("Englisch (Britisch)", ""));
                    tmp.add_child(new MenuItem("Englisch (Amerikanisch)", ""));
                tools.add_child(tmp);
                
                tools.add_child(new MenuItem("Statistik zum Dokument...", ""));
            root.add_child(tools);
            
            var project = new MenuItem("Projekt", "");
                project.add_child(new MenuItem("Erstellen", ""));
                project.add_child(new MenuItem("Säubern", ""));
                project.add_child(new MenuItem("Ausführen", ""));
                project.add_child(new MenuItem("Einstellungen", ""));
            root.add_child(project);
            
            var documents = new MenuItem("Dokumente", "document-properties");
                documents.add_child(new MenuItem("Alle speichern", ""));
                documents.add_child(new MenuItem("Alle schließen", ""));
            root.add_child(documents);
            
            var help = new MenuItem("Hilfe", "");
                help.add_child(new MenuItem("Inhalte...", ""));
                help.add_child(new MenuItem("Online Hilfe erhalten...", ""));
                help.add_child(new MenuItem("Diese Anwendung Übersetzen...", ""));
                help.add_child(new MenuItem("Info...", ""));
            root.add_child(help);
  
        return root;
    }
    
    private void setup_name_menu_recursively(MenuItem parent, bool random, int width, int depth, string[] labels) {
        
        int[] taken_labels = {};
        
        for (int i=0; i<width; ++i) {
            
            // get random forename
            string label = "";
            bool already_taken = true;
            while (already_taken) {
                int index = random ? GLib.Random.int_range(0, labels.length-1) : i;
                
                if (depth%2 == 0)
                    index = labels.length-1-index;
                
                already_taken = false;
                foreach(var z in taken_labels) {
                    if (z == index) {
                        already_taken = true;
                        break;
                    }
                }
                
                if (!already_taken) {
                    label = labels[index];
                    taken_labels += index;
                }
            }
            
            var child = new MenuItem(label, "");
            
            if (depth > 1) {
                string[] names = { "Schulze", "Zimmermann", "Walther", "Bauer", "Schreiber", "Schuhmacher", "Müller", "Schönherr", "Schröder", "Gutsmann", "Schmidt", "Hoffmann", "Jenkins", "Wachmann", "Heinemann", "Wachser", "Bolle", "Lehmann", "Meier", "Franke", "Schulze", "Brandt", "Schneider", "Krämer", "Neumann"};
                setup_name_menu_recursively(child, random, width, depth-1, names);
            }
            
            parent.add_child(child);
        }
    }
    
    private MenuItem setup_name_menu(bool random, int width, int depth) {
        string[] forenames = { "Karl", "Hans", "Jens", "Rainer", "Andreas", "John", "Sebastian", "Tom", "Veronika", "Karla", "Wenke", "Jennifer", "Jana", "Kerstin", "Theresa", "Maria", "Anke", "Karsten", "Thomas", "Chris", "Johannes", "Francis", "Maximilian", "Max", "René", "Nele", "Mareike"};

        var root = new MenuItem("Names", "");
        setup_name_menu_recursively(root, random, width, depth, forenames);
            
        return root;
    }
}
