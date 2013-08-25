/*
Copyright (c) 2011 by Simon Schneegans

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

public class Menu : GLib.Object {

    private OpenPie open_pie = null;

    private int menu_id = 0;

    construct {
        open_pie = new OpenPie();
    }

    public void open() {
        menu_id = open_pie.show_menu(generate_menu());
    }

  private string generate_menu() {

    var b = new Json.Builder();

    // Rot:     Kirschsaft
    // Gelb:    Appenzeller,        Gouda
    // Violett: Marzipantorte,      Keksmischung
    // Blau A:  Weihnachtskekse,    Mehrkornbrötchen
    // Blau B:  Pfirsichmarmelade,  Serranoschinken
    // Grün:    Jagdwurst,          Heineken
    // Orange:  Ehringsdorfer,      Spezi

    b.begin_object();
    b.set_member_name("text").add_string_value("Supermarkt");
    b.set_member_name("subs").begin_array();

    b.begin_object();
      b.set_member_name("text").add_string_value("Backwaren");
      b.set_member_name("subs").begin_array();

      b.begin_object();
      b.set_member_name("text").add_string_value("Brote");
      b.set_member_name("subs").begin_array();
      b.begin_object(); b.set_member_name("text").add_string_value("Krustenbrot"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Landbrot"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Vollkornbrot"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Weizenbrot"); b.end_object();
      b.end_array();
      b.end_object();

      b.begin_object();
      b.set_member_name("text").add_string_value("Brötchen");
      b.set_member_name("subs").begin_array();
      b.begin_object(); b.set_member_name("text").add_string_value("Doppel-brötchen"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Käse-brötchen"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Leinsamen-brötchen"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Mehrkorn-brötchen"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Weizen-brötchen"); b.end_object();
      b.end_array();
      b.end_object();

      b.begin_object();
      b.set_member_name("text").add_string_value("Kekse");
      b.set_member_name("subs").begin_array();
      b.begin_object(); b.set_member_name("text").add_string_value("Butterkekse"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Dänische Kekse"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Keks-mischung"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Schoko-kekse"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Weihnachts-kekse"); b.end_object();
      b.end_array();
      b.end_object();

      b.begin_object();
      b.set_member_name("text").add_string_value("Torten");
      b.set_member_name("subs").begin_array();
      b.begin_object(); b.set_member_name("text").add_string_value("Blaubeer-torte"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Erdbeertorte"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Kirschtorte"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Marzipan-torte"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Schokotorte"); b.end_object();
      b.end_array();
      b.end_object();

      b.end_array();
    b.end_object();

    b.begin_object();
      b.set_member_name("text").add_string_value("Brotbelag");
      b.set_member_name("subs").begin_array();

      b.begin_object();
      b.set_member_name("text").add_string_value("Honig");
      b.set_member_name("subs").begin_array();
      b.begin_object(); b.set_member_name("text").add_string_value("Blütenhonig"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Holunder-honig"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Sanddorn-honig"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Waldhonig"); b.end_object();
      b.end_array();
      b.end_object();

      b.begin_object();
      b.set_member_name("text").add_string_value("Käse");
      b.set_member_name("subs").begin_array();
      b.begin_object(); b.set_member_name("text").add_string_value("Appenzeller"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Frischkäse"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Gouda"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Maasdamer"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Tilsiter"); b.end_object();
      b.end_array();
      b.end_object();

      b.begin_object();
      b.set_member_name("text").add_string_value("Marmelade");
      b.set_member_name("subs").begin_array();
      b.begin_object(); b.set_member_name("text").add_string_value("Erdbeer-marmelade"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Hagebutten-marmelade"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Kirsch-marmelade"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Pfirsich-marmelade"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Waldbeer-marmelade"); b.end_object();
      b.end_array();
      b.end_object();

      b.begin_object();
      b.set_member_name("text").add_string_value("Schinken");
      b.set_member_name("subs").begin_array();
      b.begin_object(); b.set_member_name("text").add_string_value("Hinter-schinken"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Koch-schinken"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Lachs-schinken"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Schwarz-wälder Schinken"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Serrano-Schinken"); b.end_object();
      b.end_array();
      b.end_object();

      b.begin_object();
      b.set_member_name("text").add_string_value("Wurst");
      b.set_member_name("subs").begin_array();
      b.begin_object(); b.set_member_name("text").add_string_value("Jagdwurst"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Leberwurst"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Teewurst"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Truthahn-Salami"); b.end_object();
      b.end_array();
      b.end_object();

      b.end_array();
    b.end_object();


    b.begin_object();
      b.set_member_name("text").add_string_value("Getränke");
      b.set_member_name("subs").begin_array();

      b.begin_object();
      b.set_member_name("text").add_string_value("Biere");
      b.set_member_name("subs").begin_array();
      b.begin_object(); b.set_member_name("text").add_string_value("Becks"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Ehringsdorfer"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Heineken"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Köstritzer"); b.end_object();
      b.end_array();
      b.end_object();

      b.begin_object();
      b.set_member_name("text").add_string_value("Softdrinks");
      b.set_member_name("subs").begin_array();
      b.begin_object(); b.set_member_name("text").add_string_value("Cola Light"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Cola"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Fanta"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Spezi"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Sprite"); b.end_object();
      b.end_array();
      b.end_object();

      b.begin_object();
      b.set_member_name("text").add_string_value("Säfte");
      b.set_member_name("subs").begin_array();
      b.begin_object(); b.set_member_name("text").add_string_value("Apfelsaft"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Bananensaft"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Kirschsaft"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Multivitamin-saft"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Orangensaft"); b.end_object();
      b.end_array();
      b.end_object();

      b.begin_object();
      b.set_member_name("text").add_string_value("Tees");
      b.set_member_name("subs").begin_array();
      b.begin_object(); b.set_member_name("text").add_string_value("Fencheltee"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Früchtetee"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Kamillentee"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Kräutertee"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Rotbuschtee"); b.end_object();
      b.end_array();
      b.end_object();

      b.begin_object();
      b.set_member_name("text").add_string_value("Weine");
      b.set_member_name("subs").begin_array();
      b.begin_object(); b.set_member_name("text").add_string_value("Burgunder"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Perlwein"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Rotwein"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Weißwein"); b.end_object();
      b.end_array();
      b.end_object();

      b.end_array();
    b.end_object();





    b.begin_object();
      b.set_member_name("text").add_string_value("Kleidung");
      b.set_member_name("subs").begin_array();

      b.begin_object();
      b.set_member_name("text").add_string_value("Hosen");
      b.set_member_name("subs").begin_array();
      b.begin_object(); b.set_member_name("text").add_string_value("Blaue Hose"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Gelbe Hose"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Grüne Hose"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Rote Hose"); b.end_object();
      b.end_array();
      b.end_object();

      b.begin_object();
      b.set_member_name("text").add_string_value("Mützen");
      b.set_member_name("subs").begin_array();
      b.begin_object(); b.set_member_name("text").add_string_value("Blaue Mütze"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Gelbe Mütze"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Grüne Mütze"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Rote Mütze"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Schwarze Mütze"); b.end_object();
      b.end_array();
      b.end_object();

      b.begin_object();
      b.set_member_name("text").add_string_value("Pullover");
      b.set_member_name("subs").begin_array();
      b.begin_object(); b.set_member_name("text").add_string_value("Blauer Pullover"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Gelber Pullover"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Grüner Pullover"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Roter Pullover"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Schwarzer Pullover"); b.end_object();
      b.end_array();
      b.end_object();

      b.begin_object();
      b.set_member_name("text").add_string_value("Socken");
      b.set_member_name("subs").begin_array();
      b.begin_object(); b.set_member_name("text").add_string_value("Blaue Socken"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Gelbe Socken"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Grüne Socken"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Rote Socken"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Schwarze Socken"); b.end_object();
      b.end_array();
      b.end_object();

      b.begin_object();
      b.set_member_name("text").add_string_value("T-Shirts");
      b.set_member_name("subs").begin_array();
      b.begin_object(); b.set_member_name("text").add_string_value("Gelbes T-Shirt"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Grünes T-Shirt"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Rotes T-Shirt"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Schwarzes T-Shirt"); b.end_object();
      b.end_array();
      b.end_object();

      b.end_array();
    b.end_object();



    b.begin_object();
      b.set_member_name("text").add_string_value("Tiefkühlware");
      b.set_member_name("subs").begin_array();

      b.begin_object();
      b.set_member_name("text").add_string_value("Eis");
      b.set_member_name("subs").begin_array();
      b.begin_object(); b.set_member_name("text").add_string_value("Erdbeer-Eis"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Schoko-Eis"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Stracciatella-Eis"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Vanille-Eis"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Karamell-Eis"); b.end_object();
      b.end_array();
      b.end_object();

      b.begin_object();
      b.set_member_name("text").add_string_value("Fertiggerichte");
      b.set_member_name("subs").begin_array();
      b.begin_object(); b.set_member_name("text").add_string_value("Tiefkühl-Chinapfanne"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Tiefkühl-Paella"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Tiefkühl-Reispfanne"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Tiefkühl-Wokpfanne"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Tiefkühl-Gemüse-pfanne"); b.end_object();
      b.end_array();
      b.end_object();

      b.begin_object();
      b.set_member_name("text").add_string_value("Gemüse");
      b.set_member_name("subs").begin_array();
      b.begin_object(); b.set_member_name("text").add_string_value("Tiefkühl-Blumenkohl"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Tiefkühl-Bohnen"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Tiefkühl-Brokoli"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Tiefkühl-Erbsen"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Tiefkühl-Möhren"); b.end_object();
      b.end_array();
      b.end_object();

      b.begin_object();
      b.set_member_name("text").add_string_value("Pizzen");
      b.set_member_name("subs").begin_array();
      b.begin_object(); b.set_member_name("text").add_string_value("Pizza-Hawaii"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Pizza-Peperoni"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Pizza-Salami"); b.end_object();
      b.begin_object(); b.set_member_name("text").add_string_value("Pizza-Speziale"); b.end_object();
      b.end_array();
      b.end_object();


        b.end_array();
    b.end_object();





    b.end_array();
    b.end_object();

    var generator = new Json.Generator();
    generator.root = b.get_root();

    return generator.to_data(null);
  }

}
