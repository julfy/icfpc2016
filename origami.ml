open ExtLib
open Prelude

open Otypes

let readlni ch = input_line ch |> String.strip |> int_of_string

let read ch =
  let shape =
    List.init (readlni ch) begin fun _ ->
      List.init (readlni ch) (fun _ -> Pt.of_string @@ input_line ch)
    end
  in
  let skel =
    List.init (readlni ch) (fun _ -> Line.of_string @@ input_line ch)
  in
  { Problem.shape; skel }

let read file = Control.with_open_in_txt file read

let () =
  match Action.args with
  | "render"::file::[] ->
    let p = read file in
    Control.with_open_out_bin (file ^ ".png") (Render.render p)
  | "bb"::file::[] ->
    let p = read file in
    let (lo,hi) = Ops.bounding_box p.shape in
    printfn "%s %s" (Pt.show lo) (Pt.show hi)
  | "solve"::meth::file::[] ->
    let p = read file in
    let solution =
      match meth with
      | "bb" -> Ops.bounding_box p.shape |> Ops.fold_bb
      | _ -> assert false
    in
    print_string @@ Solution.show solution
  | _ -> Exn.fail "wat"
