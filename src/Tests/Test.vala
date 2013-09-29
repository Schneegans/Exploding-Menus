/*
Copyright (c) 2011-2012 by Simon Schneegans

This program is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option)
any later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
this program. If not, see <http://www.gnu.org/licenses/>.
*/

public class Test : GLib.Object {

  public signal void on_finish();

  private InstructionWindow instruction;
  private SmileWindow       smile;
  private Menu              menu = null;

  private bool ready  = false;
  private int stage   = 0;
  private int page    = 0;

  private ulong select_callback;

  private delegate void next();

  public void init(bool hidemouse) {
    instruction = new InstructionWindow();
    smile = new SmileWindow();
    menu = new Menu();

    smile.on_touch.connect(() => {
      if (ready) {
        ready = false;
        next_page();
      }
    });

    instruction.open();
    smile.open();

    if (hidemouse) {
      instruction.get_window().set_cursor(new Gdk.Cursor(Gdk.CursorType.BLANK_CURSOR));
      smile.get_window().set_cursor(new Gdk.Cursor(Gdk.CursorType.BLANK_CURSOR));
    }

    // make sure that the window is displayed
    while(Gtk.events_pending() || Gdk.events_pending()) {
      Gtk.main_iteration_do(true);
    }

    smile.set_grandma_state(SmileWindow.State.NORMAL);


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
        next_page_training();
        break;
      case 2:
        next_page_novice_intro();
        break;
      case 3:
        next_page_novice();
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
        smile.set_smile_position(new Vector(smile.width()/2, smile.height()/2));
        smile.set_grandma_state(SmileWindow.State.HELLO);

        instruction.set_text(
          heading("Oma Erika") +
          "Das ist Oma Erika. Obwohl sie schon ziemlich alt ist, möchte sie nicht "+
          "auf die Vorzüge der Konsumgesellschaft verzichten müssen. "+
          "Du bist auserwählt worden, Oma Erika bei ihrem Einkauf zu helfen!" +
          hint("Zum Fortfahren berühre Oma Erika..."));
        break;

      case 1:

        smile.set_grandma_state(SmileWindow.State.HELLO);

        instruction.set_text(
          heading("Einführungstest") +
          "Du hast gerade in einem kurzem Video gesehen, wie man das Einkaufs-Tool "+
          "verwendet. Zur Eingewöhnung darfst du gleich "+
          "selbst ein paar Dinge einkaufen!" +
          hint("Zum Beginnen berühre Oma Erika!"));

        set_stage(1);

        Logger.write("##START_OF_TRAINING## " + Logger.get_time());

        break;
    }

    ready = true;
  }

  private void next_page_novice_intro() {
    switch (page) {
      case 0:
        smile.set_grandma_state(SmileWindow.State.HELLO);
        instruction.set_text(
          heading("Sehr gut!") +
          "Das hast du exzellent gemeistert! Du hast realistische Chancen, von Oma " +
          "Erika zum Einkaufs-Profi ernannt zu werden!" +
          hint("Zum Fortfahren berühre Oma Erika..."));
        break;

      case 1:
        smile.set_grandma_state(SmileWindow.State.HELLO);
        instruction.set_text(
          heading("Es geht los...") +
          "Du bist nun in der Lage, Oma Erika beim Einkaufen zu helfen. " +
          "Sie wird dir die Produkte sagen, die sie gerne haben möchte. \n\n" +
          "Wähle die gewünschten Produkte möglichst " +
          "schnell und präzise aus! Wählst du falsche Produkte, " +
          "wird Oma Erika böse werden!" +
          hint("Zum Fortfahren berühre Oma Erika..."));
        break;

      case 2:
        smile.set_grandma_state(SmileWindow.State.HELLO);
        instruction.set_text(
          heading("Es geht los...") +
          "Da Oma Erika sehr vergesslich ist, wird sie dich häufig nach den "+
          "gleichen Produkten fragen. Bitte sei geduldig und lass ihr den Spaß!\n\n" +
          "Nutze diese Schwäche aus, um die jeweiligen Produkte immer schneller "+
          "wählen zu können!"+
          hint("Zum Fortfahren berühre Oma Erika..."));
        break;

      case 3:
        smile.set_grandma_state(SmileWindow.State.HELLO);
        instruction.set_text(
          heading("Es geht los...") +
          "Neben jedem Produkt wird dein aktueller Rekord angezeigt. "+
          "Versuche ihn immer wieder zu brechen!"+
          hint("Zum Beginnen berühre Oma Erika!"));

        set_stage(3);

        Logger.write("##START_OF_TEST## " + Logger.get_time());

        break;
    }

    ready = true;
  }

  private void next_page_finish() {
    switch (page) {
      case 0:
        instruction.show();
        instruction.set_text(
          heading("Sehr gut!") +
          "Soviel zur Einführung. Beginnen wir mit dem spannenden Teil..." +
          hint("Zum Fortfahren berühre Oma Erika..."));
        break;
      default:
        on_finish();
        break;
    }

    ready = true;
  }

  private void next_page_training() {

    smile.set_grandma_state(SmileWindow.State.HELLO);

    var targets = new Gee.HashMap<string?, string?>();
    var target_count = new Gee.HashMap<string?, int>();

    targets.set("4 3 0", "Pizza-Hawaii");
    targets.set("4 0 1", "Schoko-Eis");
    targets.set("2 3 2", "Kamillentee");
    targets.set("2 2 0", "Apfelsaft");

    const int COUNT = 1;

    target_count.set("4 3 0", COUNT);
    target_count.set("4 0 1", COUNT);
    target_count.set("2 3 2", COUNT);
    target_count.set("2 2 0", COUNT);

    next update = () => {
      if (targets.size > 0) {
        string target_string = "";

        foreach (var target in targets.entries) {
          target_string += "  " + target.value + "\t (noch " + target_count.get(target.key).to_string() + " mal)\n";
        }

        instruction.set_text(heading("Einführungstest") +
                     "Wähle zum Üben mit dem Einkaufs-Tool die Produkte <b> \n" +
                     target_string + "</b>aus!");

        GLib.Timeout.add(2000, () => {
          menu.open();
          return false;
        });

      } else {

        menu.disconnect(select_callback);

        set_stage(2);
        next_page();
      }
    };

    select_callback = menu.on_select.connect((item) => {

      if (targets.has_key(item)) {
        smile.set_grandma_state(SmileWindow.State.HAPPY);

        var count = target_count.get(item) - 1;

        if (count > 0) {
          target_count.set(item, count);
        } else {
          targets.unset(item);
          target_count.unset(item);
        }

      } else {
        smile.set_grandma_state(SmileWindow.State.ANGRY);
      }

      update();
    });

    update();
  }

  private void next_page_novice() {

    smile.set_grandma_state(SmileWindow.State.HELLO);

    var targets = new Gee.HashMap<string?, string?>();
    var target_records = new Gee.HashMap<string?, double?>();

    targets.set("4 3 0", "Pizza-Hawaii");
    targets.set("4 0 1", "Schoko-Eis");
    targets.set("2 3 2", "Kamillentee");
    targets.set("2 2 0", "Apfelsaft");

    target_records.set("4 3 0", 99999);
    target_records.set("4 0 1", 99999);
    target_records.set("2 3 2", 99999);
    target_records.set("2 2 0", 99999);

    var open_time = new DateTime.now_local();

    next update = () => {
      if (targets.size > 0) {
        string target_string = "";

        foreach (var target in targets.entries) {
          target_string += "  " + target.value + "\t (Rekord: %2.3f".printf(target_records.get(target.key)) + " s)\n";
        }

        instruction.set_text(heading("Shopping") +
                     "Wähle mit dem Einkaufs-Tool die Produkte <b> \n" +
                     target_string + "</b>aus!");

        GLib.Timeout.add(2000, () => {
          open_time = new DateTime.now_local();
          menu.open();
          return false;
        });

      } else {

        menu.disconnect(select_callback);

        set_stage(4);
        next_page();
      }
    };

    select_callback = menu.on_select.connect((item) => {

      if (targets.has_key(item)) {
        smile.set_grandma_state(SmileWindow.State.HAPPY);

        var record = target_records.get(item);

        var close_time = new DateTime.now_local();
        var diff = close_time.difference(open_time) * 0.000001;

        debug(diff.to_string());

        if (diff < record) {
          target_records.set(item, diff);
        }

      } else {
        smile.set_grandma_state(SmileWindow.State.ANGRY);
      }

      update();
    });

    update();
  }

  private string heading(string text) {
    return "<span size='25000'><b>" + text + "</b></span>\n\n";
  }

  private string hint(string text) {
    return "\n\n<span size='15000' style='italic'>" + text + "</span>";
  }

}
