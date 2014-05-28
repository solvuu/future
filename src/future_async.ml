open Async.Std

module Deferred = Deferred

let return = return
let (>>=) = (>>=)
let (>>|) = (>>|)
let (>>=?) = (>>=?)
let (>>|?) = (>>|?)
let fail = raise
let raise = `Use_fail_instead

module Pipe = struct
  include Pipe
  let read r = read r
  let map = map
  let fold r ~init ~f = fold r ~init ~f
  let iter r ~f = iter r ~f
end

module Reader = struct
  include Reader
  let with_file ?buf_len file ~f = with_file ?buf_len file ~f
end

module Writer = struct
  include Writer
  let write t x = write t x; Deferred.unit
  let write_char t x = write_char t x; Deferred.unit
  let write_line t x = write_line t x; Deferred.unit
end
