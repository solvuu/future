open Core.Std
open Lwt

module Deferred_intf = struct
  type how = [ `Parallel | `Sequential ]
end
open Deferred_intf

module Deferred = struct
  type 'a t = 'a Lwt.t

  include Monad.Make(struct
    type 'a t = 'a Lwt.t
    let return = Lwt.return
    let bind = Lwt.bind
    let map = `Custom (fun m ~f -> Lwt.map f m)
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

      let map = `Custom (fun m ~f -> Lwt.map (function
        | Ok x -> Ok (f x)
        | Error _ as x -> x
      ) m)
    end)
  end

  module List = struct

    let fold l ~init ~f = Lwt_list.fold_left_s f init l

    let iter ?(how = `Sequential) l ~f =
      match how with
      | `Sequential -> Lwt_list.iter_s f l
      | `Parallel -> Lwt_list.iter_p f l

    let map ?(how = `Sequential) l ~f =
      match how with
      | `Sequential -> Lwt_list.map_s f l
      | `Parallel -> Lwt_list.map_p f l

    let filter ?(how = `Sequential) l ~f =
      match how with
      | `Sequential -> Lwt_list.filter_s f l
      | `Parallel -> Lwt_list.filter_p f l

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

  let junk = Lwt_stream.junk

  let peek_deferred r =
    Lwt_stream.peek r >>| function
    | Some x -> `Ok x
    | None -> `Eof

  let map r ~f = Lwt_stream.map f r

  let fold r ~init ~f =
    Lwt_stream.fold_s (fun a accum -> f accum a) r init

  let iter r ~f = Lwt_stream.iter_s f r

end

module Reader = struct
  module Read_result = struct
    type 'a t = [ `Eof | `Ok of 'a ]
  end

  type t = Lwt_io.input_channel

  let open_file ?buf_len file =
    Lwt_io.open_file ?buffer_size:buf_len ~mode:Lwt_io.input file

  let close = Lwt_io.close

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

module Writer = struct
  type t = Lwt_io.output_channel

  let with_file ?perm ?(append=false) file ~f =
    let flags = match append with
      | true ->  Unix.([O_WRONLY; O_CREAT; O_APPEND])
      | false -> Unix.([O_WRONLY; O_CREAT; O_TRUNC])
    in
    Lwt_io.with_file ~flags ?perm ~mode:Lwt_io.output file f

  let write = Lwt_io.write
  let write_char = Lwt_io.write_char
  let write_line = Lwt_io.write_line
end
