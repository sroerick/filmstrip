(** Proves the adapter story: two unrelated tile providers feed the one
    component, and the emitted markup is checked structurally (a link per tile,
    no JS, glyphs/names/summaries present, stamped counts only). *)

open Filmstrip

let contains ~needle haystack =
  let n = String.length needle and h = String.length haystack in
  let rec go i = i + n <= h && (String.sub haystack i n = needle || go (i + 1)) in
  n = 0 || go 0

let count ~needle haystack =
  let n = String.length needle and h = String.length haystack in
  let rec go i acc =
    if i + n > h then acc
    else if String.sub haystack i n = needle then go (i + 1) (acc + 1)
    else go (i + 1) acc
  in
  if n = 0 then 0 else go 0 0

let check label cond =
  if not cond then failwith ("assertion failed: " ^ label)

(* Provider 1: pricklypear-style - face routes out of an app registry. *)
let pp_tiles =
  [
    tile ~glyph:"📊" ~name:"dash" ~summary:"the board" ~href:"/dash" ();
    tile ~glyph:"🧾" ~name:"ledger" ~summary:"money in, money out"
      ~href:"/ledger" ~count:7 ~stamp:(live ~label:"live 2m" ()) ();
    tile ~glyph:"🛠" ~name:"ops" ~summary:"runs and deploys" ~href:"/ops"
      ~count:0 ~stamp:bake ();
  ]

(* Provider 2: tuna-style - public surfaces with no counts at all. *)
let tuna_tiles =
  [
    tile ~glyph:"🎬" ~name:"films" ~summary:"what is showing" ~href:"/films" ();
    tile ~glyph:"📅" ~name:"screenings" ~summary:"times and rooms"
      ~href:"/screenings" ();
  ]

let test_same_component () =
  let a = render_strip pp_tiles in
  let b = render_strip ~opts:{ default_opts with id = "tuna"; label = Some "Public" } tuna_tiles in
  check "pp strip is a nav" (contains ~needle:"<nav" a);
  check "tuna strip is a nav" (contains ~needle:"<nav" b);
  check "both use the same track class" (contains ~needle:"filmstrip-track" a);
  check "both use the same link class" (contains ~needle:"filmstrip-link" b);
  check "pp tile count" (count ~needle:"<a class=\"filmstrip-link\"" a = 3);
  check "tuna tile count" (count ~needle:"<a class=\"filmstrip-link\"" b = 2);
  check "no script tag" (not (contains ~needle:"<script" a));
  check "no js url" (not (contains ~needle:"javascript:" a))

let test_tile_structure () =
  let h = render_strip pp_tiles in
  check "every tile is a link with href"
    (count ~needle:"href=\"" h = count ~needle:"<a " h);
  check "glyph renders" (contains ~needle:"filmstrip-glyph" h);
  check "name renders" (contains ~needle:"ledger" h);
  check "summary renders" (contains ~needle:"money in, money out" h);
  check "count carries a stamp"
    (contains ~needle:"data-stamp-label=\"live 2m\"" h);
  check "baked stamp present" (contains ~needle:"data-stamp-label=\"baked\"" h);
  check "bare count never rendered"
    (count ~needle:"<span class=\"filmstrip-count\"" h = 2)

let test_escaping_and_opts () =
  let t =
    tile ~glyph:"<x>" ~name:"a&b" ~summary:"q\"q" ~href:"/a?b=1&c=2" ()
  in
  let h = render_strip ~opts:{ default_opts with label = None; extra_class = "wide" } [ t ] in
  check "glyph escaped" (contains ~needle:"&lt;x&gt;" h);
  check "name escaped" (contains ~needle:"a&amp;b" h);
  check "summary escaped" (contains ~needle:"q&quot;q" h);
  check "href escaped" (contains ~needle:"/a?b=1&amp;c=2" h);
  check "extra class applied" (contains ~needle:"class=\"filmstrip wide\"" h);
  check "no aria-label when omitted" (not (contains ~needle:"aria-label" h))

let test_css () =
  let c = Filmstrip_css.stylesheet in
  check "track scrolls horizontally" (contains ~needle:"overflow-x: auto" c);
  check "44px min width" (contains ~needle:"min-width: 44px" c);
  check "44px min height" (contains ~needle:"min-height: 44px" c);
  check "strip does not overflow page" (contains ~needle:"max-width: 100%" c);
  check "no script in css" (not (contains ~needle:"<script" c))

let () =
  test_same_component ();
  test_tile_structure ();
  test_escaping_and_opts ();
  test_css ();
  print_endline "consumer_test: ok"
