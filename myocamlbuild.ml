open Printf
open Solvuu_build.Std
open Solvuu_build.Util

let project_name = "future"
let version = "0.2.0"

let lib ?findlib_deps ?internal_deps ?ml_files lib_name : Project.item =
  Project.lib (sprintf "%s_%s" project_name lib_name)
    ~pkg:(sprintf "%s.%s" project_name lib_name)
    ~dir:(sprintf "lib/%s" lib_name)
    ~style:(`Pack  (sprintf "%s_%s" project_name lib_name))
    ?findlib_deps
    ?internal_deps
    ?ml_files

let unix = lib "unix" ~findlib_deps:["core"; "cfstream"]
let async = lib "async" ~internal_deps:[unix] ~findlib_deps:["async"]
let lwt = lib "lwt" ~internal_deps:[unix]
    ~findlib_deps:["lwt"; "lwt.preemptive"; "lwt.ppx"]

let ocamlinit_postfix = [
  "open Core.Std";
  "open Async.Std";
  "open Future_async.Std";
]

let optional_pkgs = ["async"; "lwt"]

let items =
  [unix;async;lwt] |>
  List.filter ~f:(fun x -> Project.dep_opts_sat x optional_pkgs)

;;
let () = Project.solvuu1 ~project_name ~version ~ocamlinit_postfix items
