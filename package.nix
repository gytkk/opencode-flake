{
  lib,
  stdenv,
  stdenvNoCC,
  fetchzip,
  patchelf,
  makeWrapper,
  ripgrep,
}:

let
  version = "1.2.0";

  platformMap = {
    "aarch64-darwin" = {
      suffix = "darwin-arm64";
      ext = "zip";
      hash = "sha256-e1oETr1NMvpqtkePMfa4b46Ki0v4JM/sB6DO70yjdfc=";
    };
    "x86_64-darwin" = {
      suffix = "darwin-x64";
      ext = "zip";
      hash = "sha256-ginjD6A5R5jiN7k8bHlPeSFWXImFgY0dS2rZ+zcYdbk=";
    };
    "x86_64-linux" = {
      suffix = "linux-x64";
      ext = "tar.gz";
      hash = "sha256-Tpj9CITLy5Y/pBgsodXTzbB+lIxGeTS19Q3oP4oy1S0=";
    };
    "aarch64-linux" = {
      suffix = "linux-arm64";
      ext = "tar.gz";
      hash = "sha256-VCsBCMbkvZxijMwJDZKURyqL8fasw9OfmwJACK1hx+k=";
    };
  };

  platform =
    platformMap.${stdenvNoCC.hostPlatform.system}
      or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");

  src = fetchzip {
    url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-${platform.suffix}.${platform.ext}";
    hash = platform.hash;
    stripRoot = false;
  };
in
stdenvNoCC.mkDerivation {
  pname = "opencode";
  inherit version src;

  nativeBuildInputs = [ makeWrapper ] ++ lib.optionals stdenvNoCC.hostPlatform.isLinux [ patchelf ];

  dontAutoPatchelf = true;
  dontPatchELF = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 opencode $out/bin/opencode
    ${lib.optionalString stdenvNoCC.hostPlatform.isLinux ''
      patchelf --set-interpreter "$(cat ${stdenv.cc}/nix-support/dynamic-linker)" $out/bin/opencode
    ''}
    wrapProgram $out/bin/opencode \
      --prefix PATH : ${lib.makeBinPath [ ripgrep ]}
    runHook postInstall
  '';

  meta = {
    description = "AI coding agent built for the terminal";
    homepage = "https://github.com/anomalyco/opencode";
    license = lib.licenses.mit;
    platforms = builtins.attrNames platformMap;
    mainProgram = "opencode";
  };
}
