open Core.Std
open Lwt

module Deferred = struct
  type 'a t = 'a Lwt.t

  include Monad.Make(struct
    type 'a t = 'a Lwt.t
    let return = Lwt.return
    let bind = Lwt.bind
    let map m ~f = Lwt.map f m
  end)

  module Result = struct
    type ('a, 'b) t = ('a, 'b) Result.t Lwt.t

    include Monad.Make2(struct
      type ('a, 'b) t = ('a, 'b) Result.t Lwt.t

      let return x = Lwt.return (Ok x)

      let bind m f = Lwt.bind m (function
        | Ok x -> f x
        | Error _ as x -> Lwt.return x
      )

      let map m ~f = Lwt.map (function
        | Ok x -> Ok (f x)
        | Error _ as x -> x
      ) m
    end)
  end
end

let return = Deferred.return
let (>>=) = Deferred.(>>=)
let (>>|) = Deferred.(>>|)
let (>>=?) = Deferred.Result.(>>=)
let (>>|?) = Deferred.Result.(>>|)
let fail = Lwt.fail
let raise = `Use_fail_instead

module Pipe = struct
  module Reader = struct
    type 'a t = 'a Lwt_stream.t
  end

  let read r =
    Lwt_stream.get r >>| function
    | Some x -> `Ok x
    | None -> `Eof

  let fold r ~init ~f =
    Lwt_stream.fold_s (fun a accum -> f accum a) r init
end

module Reader = struct
  module Read_result = struct
    type 'a t = [ `Eof | `Ok of 'a ]
  end

  type t = Lwt_io.input_channel

  let with_file ?buf_len file ~f =
    Lwt_io.with_file ?buffer_size:buf_len ~mode:Lwt_io.input file f

  let read_line ic =
    Lwt_io.read_line_opt ic >>| function
    | Some x -> `Ok x
    | None -> `Eof

  let read_all ic read_one =
    Lwt_stream.from (fun () -> match_lwt read_one ic with
    | `Ok x -> Lwt.return (Some x)
    | `Eof ->
      Lwt_io.close ic >>= fun () ->
      Lwt.return None
    )

  let lines ic = read_all ic read_line
end
