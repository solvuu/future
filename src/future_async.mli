open Async.Std

include Future.S
  with type 'a Deferred.t = 'a Deferred.t
  and type 'a Pipe.Reader.t = 'a Pipe.Reader.t
  and type Reader.t = Reader.t
