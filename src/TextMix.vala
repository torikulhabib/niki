/*
* Copyright (c) {2019} torikulhabib (https://github.com/torikulhabib)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: torikulhabib <torik.habib@Gmail.com>
*/

namespace Niki {
    public class TextMix : Gst.Bin {
        private dynamic Gst.Element textqueue;
        private dynamic Gst.Element texttee;
        private dynamic Gst.Element textoverlay;
        private dynamic Gst.Element subparse;
        private dynamic Gst.Element testsink;

        public TextMix () {
            texttee = Gst.ElementFactory.make ("tee", "tee");
            textqueue = Gst.ElementFactory.make ("queue", "queue");
            textoverlay = Gst.ElementFactory.make ("textoverlay", "textoverlay");
            subparse = Gst.ElementFactory.make ("subparse", "subparse");
            testsink = Gst.ElementFactory.make ("textsink", "autotextsink");
            add_many (textqueue, texttee, subparse, textoverlay, testsink);
            add_pad (new Gst.GhostPad ("sink", texttee.get_static_pad ("sink")));
            textqueue.link_many (subparse, textoverlay, testsink);
            Gst.Pad sinkpad = textqueue.get_static_pad ("sink");
            Gst.Pad pad = texttee.get_request_pad ("src_%u");
            pad.link (sinkpad);
            texttee["alloc-pad"] = pad;
            Gst.ControlSource cs_a = new Gst.Controller.LFOControlSource ();
            cs_a.set ("frequency", (double) 0.5, "amplitude", (double) 0.5, "offset", (double) 0.5);
            Gst.ControlSource cs_r = new Gst.Controller.LFOControlSource ();
            cs_r.set ("frequency", (double) 0.19, "amplitude", (double) 0.5, "offset", (double) 0.5);
            Gst.ControlSource cs_g = new Gst.Controller.LFOControlSource ();
            cs_g.set ("frequency", (double) 0.27, "amplitude", (double) 0.5, "offset", (double) 0.5);
            Gst.ControlSource cs_b = new Gst.Controller.LFOControlSource ();
            cs_b.set ("frequency", (double) 0.13, "amplitude", (double) 0.5, "offset", (double) 0.5);
            ((Gst.Object) textoverlay).add_control_binding (new Gst.Controller.ARGBControlBinding ((Gst.Object) textoverlay, "color", cs_a, cs_r, cs_g, cs_b));

        }
    }
}
