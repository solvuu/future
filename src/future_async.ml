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
  let fold r ~init ~f = fold r ~init ~f
end

module Reader = struct
  include Reader
  let with_file ?buf_len file ~f = with_file ?buf_len file ~f
end
