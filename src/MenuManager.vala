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
    
    private string type;
    private string mode;
    
    private ulong cancel_handler;
    private ulong select_handler;
    
    public MenuManager() {
    
        bindings = new BindingManager();
        bindings.bind(new Trigger.from_string("button3"), "button2");
        
        bindings.on_press.connect((id) => {
            menu.set_structure(setup_menu(mode));
            menu.show();
        }); 
    }
    
    public void init(string menu_type, string menu_mode) {
        type = menu_type;
        mode = menu_mode;
        
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
    }
    
    private MenuItem setup_menu(string menu_mode) {
        if (menu_mode == "random")       
            return setup_name_menu(true);
            
        if (menu_mode == "static")       
            return setup_name_menu(false);
        
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
    
    private MenuItem setup_name_menu(bool random) {
    
        string[] forenames = { "Karl", "Hans", "Jens", "Rainer", "Andreas", "John", "Sebastian", "Tom"};
        string[] middlenames = { "Heinz", "Peter", "Martin", "Herbert", "Werner", "Frederick", "Eric"};
        string[] names = { "Schulze", "Zimmermann", "Walther", "Bauer", "Schreiber", "Schuhmacher", "Müller"};
        int[] taken_forenames = {};

        var root = new MenuItem("Names", "");
        
        for (int i=0; i<8; ++i) {
            
            // get random forename
            string forename = "";
            bool already_taken = true;
            while (already_taken) {
                int index = random ? GLib.Random.int_range(0, 8) : i;
                
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
            
            int[] taken_middlenames = {};
            
            for (int j=0; j<7; ++j) {
                // get random name
                string middlename = "";
                bool already_taken2 = true;
                while (already_taken2) {
                    int index = random ? GLib.Random.int_range(0, 7) : j;

                    already_taken2 = false;
                    foreach(var z in taken_middlenames) {
                        if (z == index)
                            already_taken2 = true;
                    }
                    
                    if (!already_taken2) {
                        middlename = middlenames[index];
                        taken_middlenames += index;
                    }
                }
                
                var tmp_tmp = new MenuItem(middlename, "");
            
                int[] taken_names = {};
            
                for (int k=0; k<7; ++k) {
                    // get random name
                    string name = "";
                    bool already_taken3 = true;
                    while (already_taken3) {
                        int index = random ? GLib.Random.int_range(0, 7) : k;

                        already_taken3 = false;
                        foreach(var z in taken_names) {
                            if (z == index)
                                already_taken3 = true;
                        }
                        
                        if (!already_taken3) {
                            name = names[index];
                            taken_names += index;
                        }
                    }
                
                
                    tmp_tmp.add_child(new MenuItem(name, ""));
                }
            
                tmp.add_child(tmp_tmp);
            }
            
            root.add_child(tmp);
        }
            
        return root;
    }
}
