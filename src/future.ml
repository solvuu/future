(** Signature defining a small subset of Async's API. Async, Lwt, and
    Stdlib (blocking) implementations of this interface are provided.
*)
open Core.Std

module type S = sig
  module Deferred : sig
    include Monad.S

    module Result : Monad.S2
      with type ('a, 'b) t = ('a, 'b) Result.t t
  end

  val return : 'a -> 'a Deferred.t
  val (>>=) : 'a Deferred.t -> ('a -> 'b Deferred.t) -> 'b Deferred.t
  val (>>|) : 'a Deferred.t -> ('a -> 'b) -> 'b Deferred.t

  val (>>=?) :
    ('a, 'b) Deferred.Result.t ->
    ('a -> ('c, 'b) Deferred.Result.t) ->
    ('c, 'b) Deferred.Result.t

  val (>>|?) :
    ('a, 'b) Deferred.Result.t ->
    ('a -> 'c) ->
    ('c, 'b) Deferred.Result.t

  (** Difference from Async: Use [fail] instead of [raise]. *)
  val fail : exn -> 'a Deferred.t
  val raise : [> `Use_fail_instead ]

  module Pipe : sig
    module Reader : sig
      type 'a t
    end

    val read : 'a Reader.t -> [ `Eof | `Ok of 'a ] Deferred.t

    val map : 'a Reader.t -> f:('a -> 'b) -> 'b Reader.t

    val fold :
      'a Reader.t ->
      init:'accum ->
      f:('accum -> 'a -> 'accum Deferred.t) ->
      'accum Deferred.t
  end

  module Reader : sig
    module Read_result : sig
      type 'a t = [ `Eof | `Ok of 'a ]
    end

    type t

    (** Difference from Async: implementations should try to use
        [buf_len] but are not required to. *)
    val with_file :
      ?buf_len:int ->
      string ->
      f:(t -> 'a Deferred.t) ->
      'a Deferred.t

    val read_line : t -> string Read_result.t Deferred.t
    val read_all : t -> (t -> 'a Read_result.t Deferred.t) -> 'a Pipe.Reader.t
    val lines : t -> string Pipe.Reader.t
  end

end
