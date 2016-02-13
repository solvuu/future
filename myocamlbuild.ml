open Solvuu_build

include Make(struct
  let info = Info.of_list [
    {
      Info.name = `Lib "unix";
      libs = [];
      pkgs = ["core"; "cfstream"];
      build_if = [];
    };

    {
      Info.name = `Lib "async";
      libs = ["unix"];
      pkgs = ["async"];
      build_if = [`Pkgs_installed];
    };

    {
      Info.name = `Lib "lwt";
      libs = ["unix"];
      pkgs = ["lwt.preemptive"; "lwt.ppx"];
      build_if = [`Pkgs_installed];
    };
  ]

  let ocamlinit_postfix = [
    "open Future_async.Std";
  ]

end)

let () = dispatch()
