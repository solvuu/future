#!/bin/bash
set -ev

export OPAMYES=1
export OPAMJOBS=2
export OPAMVERBOSE=1

# View settings
echo "TRAVIS_BUILD_DIR=$TRAVIS_BUILD_DIR"

full_apt_version () {
  package=$1
  version=$2
  echo -n "${package}="
  apt-cache show $package | sed -n "s/^Version: \(${version}\)/\1/p" | head -1
}

install_on_linux () {
  case "$OCAML_VERSION,$OPAM_VERSION" in
  3.12.1,1.0.0) ppa=avsm/ocaml312+opam10 ;;
  3.12.1,1.1.0) ppa=avsm/ocaml312+opam11 ;;
  3.12.1,1.2.0) ppa=avsm/ocaml312+opam12 ;;
  4.00.1,1.0.0) ppa=avsm/ocaml40+opam10 ;;
  4.00.1,1.1.0) ppa=avsm/ocaml40+opam11 ;;
  4.00.1,1.2.0) ppa=avsm/ocaml40+opam12 ;;
  4.01.0,1.0.0) ppa=avsm/ocaml41+opam10 ;;
  4.01.0,1.1.0) ppa=avsm/ocaml41+opam11 ;;
  4.01.0,1.2.0) ppa=avsm/ocaml41+opam12 ;;
  4.02.0,1.1.0) ppa=avsm/ocaml42+opam11 ;;
  4.02.0,1.2.0) ppa=avsm/ocaml42+opam12 ;;
  *) echo Unknown $OCAML_VERSION,$OPAM_VERSION; exit 1 ;;
  esac

  sudo add-apt-repository "deb mirror://mirrors.ubuntu.com/mirrors.txt trusty main restricted universe"
  sudo add-apt-repository --yes ppa:$ppa
  sudo apt-get update -qq
  sudo apt-get install -y \
    $(full_apt_version ocaml-compiler-libs $OCAML_VERSION) \
    $(full_apt_version ocaml-interp $OCAML_VERSION) \
    $(full_apt_version ocaml-base-nox $OCAML_VERSION) \
    $(full_apt_version ocaml-base $OCAML_VERSION) \
    $(full_apt_version ocaml $OCAML_VERSION) \
    $(full_apt_version ocaml-nox $OCAML_VERSION) \
    $(full_apt_version ocaml-native-compilers $OCAML_VERSION) \
    $(full_apt_version camlp4 $OCAML_VERSION) \
    $(full_apt_version camlp4-extra $OCAML_VERSION) \
    opam time
}

install_on_osx () {
  curl -OL "http://xquartz.macosforge.org/downloads/SL/XQuartz-2.7.6.dmg"
  sudo hdiutil attach XQuartz-2.7.6.dmg
  sudo installer -verbose -pkg /Volumes/XQuartz-2.7.6/XQuartz.pkg -target /
  case "$OCAML_VERSION,$OPAM_VERSION" in
  4.01.0,1.1.*) brew install opam ;;
  4.01.0,1.2.*) brew update; brew install opam --HEAD ;;
  4.02.0,1.1.*) brew install opam ;;
  4.02.0,1.2.*) brew update; brew install opam --HEAD ;;
  *) echo Unknown $OCAML_VERSION,$OPAM_VERSION; exit 1 ;;
  esac
}

# Install OCaml and OPAM
install_on_linux

# Confirm installed versions
echo OCaml version
ocaml -version
echo OPAM versions
opam --version
opam --git-version

# Install OCaml packages
opam init --no-setup
eval `opam config env`
opam install ocamlfind omake core cfstream lwt async

# Run the tests
cd $TRAVIS_BUILD_DIR
omake
