#!/bin/bash
set -ev

# install opam
sudo sh -c "echo 'deb http://download.opensuse.org/repositories/home:/ocaml/xUbuntu_12.10/ /' >> /etc/apt/sources.list.d/opam.list"
sudo apt-get -y update
sudo apt-get -y --force-yes install opam

# configure and view settings
export OPAMJOBS=2
export OPAMYES=1
opam --version
opam --git-version

# install OCaml packages
opam init --comp=$OCAML_VERSION --no-setup
eval `opam config env`
opam install ocamlfind omake core cfstream lwt async

# run the build
cd $TRAVIS_BUILD_DIR
omake
