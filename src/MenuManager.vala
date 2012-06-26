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

public class MenuManager {

    private static BindingManager bindings = null;
    
    protected static Menu menu;
    
    public static void init(string menu_type, string menu_mode) {
        bindings = new BindingManager();
        bindings.bind(new Trigger.from_string("button3"), "button2");
        
        bindings.on_press.connect((id) => {
            menu.set_structure(setup_menu(menu_type, menu_mode));
            menu.show();
        });
        
        if (menu_type == "trace") menu = new TraceMenu();
        else                      menu = new LinearMenu();
            
        menu.set_structure(setup_menu(menu_type, menu_mode));
    }
    
    private static MenuItem setup_menu(string menu_type, string menu_mode) {
        if (menu_mode == "expert" && menu_type == "trace") return setup_direction_menu();
        if (menu_mode == "expert" && menu_type == "linear") return setup_number_menu();
        if (menu_mode == "novice") return setup_name_menu();
        
        return setup_gedit_menu();
    }

    private static MenuItem setup_gedit_menu() {
    
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
                    tmp.add_child(tmp2);
                    
                    tmp2 = new MenuItem("Auszeichnung", "");
                        tmp2.add_child(new MenuItem("BibTex", ""));
                        tmp2.add_child(new MenuItem("Latex", ""));
                        tmp2.add_child(new MenuItem("XSLT", ""));
                        tmp2.add_child(new MenuItem("XML", ""));
                    tmp.add_child(tmp2);
                
                    tmp2 = new MenuItem("Wissenschaftlich", "");
                        tmp2.add_child(new MenuItem("MatLab", ""));
                        tmp2.add_child(new MenuItem("GAP", ""));
                        tmp2.add_child(new MenuItem("Octave", ""));
                        tmp2.add_child(new MenuItem("R", ""));
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
    
    private static MenuItem setup_name_menu() {
    
        string[] forenames = { "Thomas", "Hans", "Jim", "Alexander", "Beate", "Jennifer", "Karla", "Theresa"};
        string[] names = { "Anders", "Zimmermann", "Schulze", "Bauer", "Schreiber", "Jauch", "Opolka"};
        int[] taken_forenames = {};
        
        
        
    
        var root = new MenuItem("Names", "");
        
        for (int i=0; i<8; ++i) {
            
            // get random forename
            string forename = "";
            bool already_taken = true;
            while (already_taken) {
                int index = GLib.Random.int_range(0, 8);
                
                already_taken = false;
                foreach(var z in taken_forenames) {
                    if (z == index)
                        already_taken = true;
                }
                
                if (!already_taken) {
                    forename = forenames[index];
                    taken_forenames += index;
                }
            }
            
            var tmp = new MenuItem(forename, "");
            
            int[] taken_names = {};
            
            for (int j=0; j<7; ++j) {
                // get random name
                string name = "";
                bool already_taken2 = true;
                while (already_taken2) {
                    int index = GLib.Random.int_range(0, 7);

                    already_taken2 = false;
                    foreach(var z in taken_names) {
                        if (z == index)
                            already_taken2 = true;
                    }
                    
                    if (!already_taken2) {
                        name = names[index];
                        taken_names += index;
                    }
                }
            
            
                tmp.add_child(new MenuItem(name, ""));
            }
            
            root.add_child(tmp);
        }
            
        return root;
    }
    
    private static MenuItem setup_direction_menu() {
    
        var root = new MenuItem("Directions", "");
        
            var tmp = new MenuItem("N", "");
                tmp.add_child(new MenuItem("N", ""));
                tmp.add_child(new MenuItem("NW", ""));
                tmp.add_child(new MenuItem("W", ""));
                tmp.add_child(new MenuItem("SW", ""));
                tmp.add_child(new MenuItem("NE", ""));
                tmp.add_child(new MenuItem("E", ""));
                tmp.add_child(new MenuItem("SE", ""));
            root.add_child(tmp);
            
            tmp = new MenuItem("NW", "");
                tmp.add_child(new MenuItem("N", ""));
                tmp.add_child(new MenuItem("NW", ""));
                tmp.add_child(new MenuItem("W", ""));
                tmp.add_child(new MenuItem("SW", ""));
                tmp.add_child(new MenuItem("NE", ""));
                tmp.add_child(new MenuItem("E", ""));
                tmp.add_child(new MenuItem("S", ""));
            root.add_child(tmp);
            
            tmp = new MenuItem("W", "");
                tmp.add_child(new MenuItem("N", ""));
                tmp.add_child(new MenuItem("NW", ""));
                tmp.add_child(new MenuItem("W", ""));
                tmp.add_child(new MenuItem("SW", ""));
                tmp.add_child(new MenuItem("NE", ""));
                tmp.add_child(new MenuItem("SE", ""));
                tmp.add_child(new MenuItem("S", ""));
            root.add_child(tmp);
            
            tmp = new MenuItem("SW", "");
                tmp.add_child(new MenuItem("N", ""));
                tmp.add_child(new MenuItem("NW", ""));
                tmp.add_child(new MenuItem("W", ""));
                tmp.add_child(new MenuItem("SW", ""));
                tmp.add_child(new MenuItem("E", ""));
                tmp.add_child(new MenuItem("SE", ""));
                tmp.add_child(new MenuItem("S", ""));
            root.add_child(tmp);
            
            tmp = new MenuItem("NE", "");
                tmp.add_child(new MenuItem("N", ""));
                tmp.add_child(new MenuItem("NW", ""));
                tmp.add_child(new MenuItem("W", ""));
                tmp.add_child(new MenuItem("NE", ""));
                tmp.add_child(new MenuItem("E", ""));
                tmp.add_child(new MenuItem("SE", ""));
                tmp.add_child(new MenuItem("S", ""));
            root.add_child(tmp);
            
            tmp = new MenuItem("E", "");
                tmp.add_child(new MenuItem("N", ""));
                tmp.add_child(new MenuItem("NW", ""));
                tmp.add_child(new MenuItem("SW", ""));
                tmp.add_child(new MenuItem("NE", ""));
                tmp.add_child(new MenuItem("E", ""));
                tmp.add_child(new MenuItem("SE", ""));
                tmp.add_child(new MenuItem("S", ""));
            root.add_child(tmp);
            
            tmp = new MenuItem("SE", "");
                tmp.add_child(new MenuItem("N", ""));
                tmp.add_child(new MenuItem("W", ""));
                tmp.add_child(new MenuItem("SW", ""));
                tmp.add_child(new MenuItem("NE", ""));
                tmp.add_child(new MenuItem("E", ""));
                tmp.add_child(new MenuItem("SE", ""));
                tmp.add_child(new MenuItem("S", ""));
            root.add_child(tmp);
            
            tmp = new MenuItem("S", "");
                tmp.add_child(new MenuItem("NW", ""));
                tmp.add_child(new MenuItem("W", ""));
                tmp.add_child(new MenuItem("SW", ""));
                tmp.add_child(new MenuItem("NE", ""));
                tmp.add_child(new MenuItem("E", ""));
                tmp.add_child(new MenuItem("SE", ""));
                tmp.add_child(new MenuItem("S", ""));
            root.add_child(tmp);
            
        return root;
    }
    
    private static MenuItem setup_number_menu() {
    
        var root = new MenuItem("Numbers", "");
        
        for (int i=1; i<=8; ++i) {
        
            var tmp = new MenuItem("%i".printf(i), "");
        
            for (int j=1; j<=7; ++j) {
                tmp.add_child(new MenuItem("%i".printf(j), ""));
            }
            
            root.add_child(tmp);
        }
            
        return root;
    }
}
