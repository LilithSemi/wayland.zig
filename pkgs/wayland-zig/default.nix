{
  lib,
  stdenv,
  mkShell,
  zig,
  flakever,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "wayland.zig";
  inherit (flakever) version;

  src = lib.cleanSource ../../.;

  zigDeps = zig.fetchDeps {
    inherit (finalAttrs) src pname version;
    hash = "sha256-biV1s1r7DwCv29qHivlAAE5VjoI8a09aZPD8FonN6oA=";
  };

  nativeBuildInputs = [
    zig
  ];

  postConfigure = ''
    ln -s ${finalAttrs.zigDeps} "$ZIG_GLOBAL_CACHE_DIR/p"
  '';

  doCheck = true;

  passthru.shell = mkShell {
    name = "wayland.zig-dev-shell";
    packages = [
      zig
    ];
  };
})
