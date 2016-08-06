open ExtLib
open Prelude

open Printf
open Otypes

let () =
  Random.self_init ();
  match List.tl @@ Array.to_list Sys.argv with
  | "render"::files ->
    let p = ref None in
    let s = ref None in
    let output = ref None in
    let last = ref "/dev/null" in
    files |> List.iter begin fun f ->
      last := f ^ ".png";
      if String.ends_with f ".out" then (assert (!s = None); s := Some (Solution.input f));
      if String.ends_with f ".in" then (assert (!p = None); p := Some (Problem.input f));
      if String.ends_with f ".png" then (assert (!output = None); output := Some f);
    end;
    let output = Option.default !last !output in
    eprintfn "output to %s" output;
    Render.render ?p:!p ?s:!s output
  | "draw"::n::[] ->
    let p = sprintf "data/%s.in" n in
    let p = if Sys.file_exists p then Some (Problem.input p) else None in
    let s = sprintf "data/%s.out" n in
    let s = if Sys.file_exists s then Some (Solution.input s) else None in
    let out = sprintf "data/%s.png" n in
    eprintfn "output to %s" out;
    Render.render ?p ?s out
  | "bb"::file::[] ->
    let p = Problem.input file in
    let (lo,hi) = Ops.bounding_box p.shape in
    printfn "%s %s" (Pt.show lo) (Pt.show hi)
  | "solve"::meth::file::[] ->
    let p = Problem.input file in
    let solution =
      match meth with
      | "bb" -> Ops.solve_bb p.shape
      | "best_bb" -> Ops.solve_best_bb p.shape
      | _ -> assert false
    in
    print_string @@ Solution.show solution
  | "hello"::[] -> printfn "%s" (Api.get "hello")
  | "get_tasks"::[] -> Api.get_all_tasks ()
  | "submit_s"::[] -> Api.submit_all_solutions ()
  | "submit_s"::l -> Api.submit_solutions l
  | "submit_p"::[] -> Api.submit_problems ()
  | "is_inside"::file::pt::[] ->
    let p = Problem.input file in
    List.map (Ops.is_inside (Pt.of_string pt)) p.shape |> List.iter (printfn "%B")
  | "resemble"::a::b::[] ->
    let a = Problem.input a in
    let b = Problem.input b in
    printfn "%g" (Ops.resemble a.shape b.shape)
  | _ -> fail "wat"
