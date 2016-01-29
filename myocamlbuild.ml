open Solvuu_build

include Make(struct
  let info = Info.of_list [
    {
      Info.name = `Lib "unix";
      libs = [];
      pkgs = ["core"; "cfstream"];
    };

    {
      Info.name = `Lib "async";
      libs = ["unix"];
      pkgs = ["async"];
    };

    {
      Info.name = `Lib "lwt";
      libs = ["unix"];
      pkgs = ["lwt.preemptive"; "lwt.ppx"];
    };
  ]

  let ocamlinit_postfix = [
    "open Future_async.Std";
  ]

end)

let () = dispatch()
