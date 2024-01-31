{ pkgs ? import <nixpkgs> {} }:
let
  driver-python-packages = ps: with ps; [
    numpy
    pyserial
  ];
  driver-python = pkgs.python3.withPackages driver-python-packages;
in pkgs.mkShell {
  packages = [
    driver-python

    pkgs.minicom
  ];
}
