(** Filmstrip: a shared, adapter-parameterized launcher strip.

    One component - {!render_strip} - takes a list of tiles and options and
    emits server-rendered plain links. The package knows nothing about any
    consumer: PP feeds it tiles from its app registry, tuna from its public
    surfaces; the adapters live in the consumers.

    Markup notes: works with JS disabled (plain <a> hrefs, no <script>), and is
    htmx-compatible (consumers may add hx-* attributes on their own wrapper).
    Every live number carries a bake/live stamp; when a feed errors the
    consumer degrades to a baked stamp - a bare number is never rendered. *)

type stamp = { label : string; live : bool }

let bake = { label = "baked"; live = false }
let live ?(label = "live") () = { label; live = true }

type tile = {
  glyph : string;
  name : string;
  summary : string;
  href : string;
  count : int option;
  stamp : stamp option;
}

let tile ?count ?stamp ~glyph ~name ~summary ~href () =
  { glyph; name; summary; href; count; stamp }

type opts = { id : string; label : string option; extra_class : string }

let default_opts = { id = "filmstrip"; label = Some "Apps"; extra_class = "" }

let escape s =
  let b = Buffer.create (String.length s) in
  String.iter
    (fun c ->
      match c with
      | '&' -> Buffer.add_string b "&amp;"
      | '<' -> Buffer.add_string b "&lt;"
      | '>' -> Buffer.add_string b "&gt;"
      | '"' -> Buffer.add_string b "&quot;"
      | '\'' -> Buffer.add_string b "&#39;"
      | c -> Buffer.add_char b c)
    s;
  Buffer.contents b

let render_count (t : tile) =
  match t.count with
  | None -> ""
  | Some n ->
      let stamp = match t.stamp with Some s -> s | None -> bake in
      Printf.sprintf
        "<span class=\"filmstrip-count\" data-stamp-label=\"%s\" \
         data-stamp-live=\"%b\">%d</span>"
        (escape stamp.label) stamp.live n

let render_tile (t : tile) =
  Printf.sprintf
    "<li class=\"filmstrip-tile\"><a class=\"filmstrip-link\" href=\"%s\">\
     <span class=\"filmstrip-glyph\" aria-hidden=\"true\">%s</span>\
     <span class=\"filmstrip-name\">%s</span>\
     <span class=\"filmstrip-summary\">%s</span>%s</a></li>"
    (escape t.href) (escape t.glyph) (escape t.name) (escape t.summary)
    (render_count t)

let render_strip ?(opts = default_opts) tiles =
  let label =
    match opts.label with
    | None -> ""
    | Some l -> Printf.sprintf " aria-label=\"%s\"" (escape l)
  in
  let extra = match opts.extra_class with "" -> "" | c -> " " ^ escape c in
  Printf.sprintf
    "<nav class=\"filmstrip%s\" id=\"%s\"%s><ul class=\"filmstrip-track\">%s</ul></nav>"
    extra (escape opts.id) label
    (String.concat "" (List.map render_tile tiles))
