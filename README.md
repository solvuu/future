### Future - Abstraction over Stdlib, Lwt, and Async.
[![Build Status](https://travis-ci.org/agarwal/future.png?branch=master)](https://travis-ci.org/agarwal/future)

OCaml has two concurrency libraries in wide use: Lwt and Async. When
writing your own library, the question is which of the two your API
should be developed against. For example, if you provide a
non-blocking function, should it return a `Lwt.t` or Async's
`Deferred.t`? Ideally, you could provide both because that allows
users of both Lwt and Async to use your new library.

In addition, sometimes you want to provide a blocking implementation
based on OCaml's Stdlib. Blocking APIs are easier for beginners to
understand and sometimes provide faster code (if your program doesn't
have much concurrency, the overhead of Lwt and Async is wasted time).

This library provides a signature `Future.S` that abstracts over
Stdlib, Lwt, and Async, and 3 implementations of it: `Future_std`,
`Future_lwt`, and `Future_async`. The goal is to have Async.Std
immediately satisfy this interface, i.e. to make `Future_async =
Async.Std`. Thus, by functorizing your code over this interface, you
can assume you are programming with Async (albeit with many fewer
functions), and get Lwt and Stdlib versions of your code for free.

We do not succeed in making `Future.S` an exact subset of `module type
of Async.Std`. Sometimes a Lwt or Stdlib implementation of some Async
construct is not possible or difficult. Such deviations are kept to a
minimum and documented. Usually, if a feature cannot be supported
uniformly for Stdlib, Lwt, and Async, then it is not included
here. There is no goal to be comprehensive. Async is a large library
and we are not attempting to provide compatible Stdlib and Lwt
versions for all of it.
