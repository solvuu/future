open Core.Std
open CFStream

module Deferred_intf = struct
  type how = [ `Parallel | `Sequential ]
end
open Deferred_intf

module Deferred = struct
  type 'a t = 'a

  include Monad.Make(struct
    type 'a t = 'a
    let return x = x
    let bind m f = f m
    let map = `Custom (fun m ~f -> f m)
  end)

  module Result = struct
    type ('a, 'b) t = ('a, 'b) Result.t

    include Monad.Make2(struct
      type ('a, 'b) t = ('a, 'b) Result.t
      let return = Result.return
      let bind = Result.bind
      let map = `Custom Result.map
    end)
  end

  module List = struct
    let fold = List.fold
    let iter ?(how:_) l ~f = List.iter l ~f
    let map ?(how:_) l ~f = List.map l ~f
    let filter ?(how:_) l ~f = List.filter l ~f
  end

end

let return = Deferred.return
let (>>=) = Deferred.bind
let (>>|) = Deferred.(>>|)
let (>>=?) = Deferred.Result.(>>=)
let (>>|?) = Deferred.Result.(>>|)
let fail = raise
let raise = `Use_fail_instead

module Pipe = struct
  module Reader = struct
    type 'a t = 'a Stream.t
  end

  let read r = match Stream.next r with
    | Some x -> `Ok x
    | None -> `Eof

  let junk = Stream.junk

  let peek_deferred r = match Stream.peek r with
    | Some x -> `Ok x
    | None -> `Eof

  let map = Stream.map
  let fold = Stream.fold
  let iter = Stream.iter

end

module Reader = struct
  module Read_result = struct
    type 'a t = [ `Eof | `Ok of 'a ]
  end

  type t = in_channel

  let open_file ?buf_len file =
    In_channel.create file

  let close = In_channel.close

  let with_file ?buf_len file ~f =
    match buf_len with
    | None | Some _ -> In_channel.with_file file ~f

  let read_line ic =
    match In_channel.input_line ~fix_win_eol:true ic with
    | Some x -> `Ok x
    | None -> `Eof

  let read_all ic read_one =
    Stream.from (fun _ -> match read_one ic with
    | `Ok x -> Some x
    | `Eof -> In_channel.close ic; None
    )

  let lines ic = read_all ic read_line
end

module Writer = struct
  type t = out_channel

  let with_file ?perm ?append file ~f =
    Out_channel.with_file ?perm ?append file ~f

  let write = Out_channel.output_string
  let write_char = Out_channel.output_char
  let write_line t s = Out_channel.output_string t s; Out_channel.newline t
end
