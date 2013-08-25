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

public class SmileWindow : Gtk.Window {

    /////////////////////////////////////////////////////////////////////
    /// C'tor, sets up the window.
    /////////////////////////////////////////////////////////////////////

    public signal void on_smile_clicked();
    public signal void on_mouse_moved();

    private Image bg;
    private Image normal;
    private Image state;

    private bool smile_visible;
    private Vector smile_position;

    private AnimatedValue alpha;

    public SmileWindow(bool smile_visible = false) {
        this.set_title("Test");
        this.set_decorated(false);
        this.set_focus_on_map(false);
        this.set_app_paintable(true);
        this.set_position(Gtk.WindowPosition.CENTER);
        this.maximize();

        this.add_events(Gdk.EventMask.BUTTON_RELEASE_MASK |
                        Gdk.EventMask.BUTTON_PRESS_MASK |
                        Gdk.EventMask.POINTER_MOTION_MASK);

        this.smile_visible = smile_visible;

        bg = new Image.from_file("background.jpg");
        normal = new Image.from_file("normal.png");
        state = new Image.from_file("normal.png");

        this.draw.connect(this.draw_window);

        this.alpha = new AnimatedValue.linear(0, 0, 0);

        this.button_press_event.connect ((e) => {

            if (this.smile_visible) {
                var mouse = new Vector(e.x, e.y);
                if (Vector.distance(mouse, smile_position) < 32)
                    on_smile_clicked();
            }
            return true;
        });

        this.motion_notify_event.connect((e) => {
            on_mouse_moved();
            return true;
        });
    }

    public void open() {
        this.show();

        set_smile_position(new Vector(width()/2, height()/2));

        GLib.Timeout.add(100, () => {
            alpha.update(100);
            queue_draw();
            return visible;
        });
    }

    public void set_smile_position(Vector position) {
        smile_position = position;
    }

    public void show_smile(bool show) {
        smile_visible = show;
    }

    public void make_happy(bool happy) {
        if (happy) {
            state = new Image.from_file("happy.png");
        } else {
            state = new Image.from_file("sad.png");
        }

        alpha = new AnimatedValue.linear(1, 1, 0);

        GLib.Timeout.add(1000, ()=>{
            alpha = new AnimatedValue.linear(1, 0, 500);
            return false;
        });
    }

    public int width() {
        return get_window().get_width();
    }

    public int height() {
        return get_window().get_height();
    }

    private bool draw_window(Cairo.Context ctx) {

        ctx.save();
            ctx.translate(width()/2, height()/2);
            ctx.scale((double)width()/bg.width(), (double)height()/bg.height());
            bg.paint_on(ctx);
        ctx.restore();

        if (smile_visible) {
            ctx.save();
                ctx.translate(smile_position.x, smile_position.y);
                normal.paint_on(ctx);
                state.paint_on(ctx, alpha.val);
            ctx.restore();
        }

        return true;
    }
}
