{ lib, stdenv, fetchurl, fetchzip, autoPatchelfHook, installShellFiles, cpio, xar }:

let
  inherit (stdenv.hostPlatform) system;
  fetch = srcPlatform: sha256: extension:
    let
      args = {
        url = "https://cache.agilebits.com/dist/1P/op2/pkg/v${version}/op_${srcPlatform}_v${version}.${extension}";
        inherit sha256;
      } // lib.optionalAttrs (extension == "zip") { stripRoot = false; };
    in
    if extension == "zip" then fetchzip args else fetchurl args;

  pname = "1password-cli";
  version = "2.7.1";
  sources = rec {
    aarch64-linux = fetch "linux_arm64" "sha256-JEOvLga6o3QOPYyGJfvqWIYL00TaqjcFzSMKw1ZSxtM=" "zip";
    i686-linux = fetch "linux_386" "sha256-Xd40mOsElbrGioPX0irz13jhiu8mZ2n6LmKrt4FyzDg=" "zip";
    x86_64-linux = fetch "linux_amd64" "sha256-DZYSkgrIpH0cYpIllVWHIuUcNgNyeX09dZ1RgUudWP8=" "zip";
    aarch64-darwin = fetch "apple_universal" "sha256-j+e9y1FQp30O5pFVLbbXhtrbyRjWZZPFhkFfNXDcCPs=" "pkg";
    x86_64-darwin = aarch64-darwin;
  };
  platforms = builtins.attrNames sources;
  mainProgram = "op";
in

stdenv.mkDerivation {
  inherit pname version;
  src =
    if (builtins.elem system platforms) then
      sources.${system}
    else
      throw "Source for ${pname} is not available for ${system}";

  nativeBuildInputs = [ installShellFiles ] ++ lib.optional stdenv.isLinux autoPatchelfHook;

  buildInputs = lib.optionals stdenv.isDarwin [ xar cpio ];

  unpackPhase = lib.optionalString stdenv.isDarwin ''
    xar -xf $src
    zcat op.pkg/Payload | cpio -i
  '';

  installPhase = ''
    runHook preInstall
    install -D ${mainProgram} $out/bin/${mainProgram}
    runHook postInstall
  '';

  postInstall = ''
    HOME=$TMPDIR
    installShellCompletion --cmd ${mainProgram} \
      --bash <($out/bin/${mainProgram} completion bash) \
      --fish <($out/bin/${mainProgram} completion fish) \
      --zsh <($out/bin/${mainProgram} completion zsh)
  '';

  dontStrip = stdenv.isDarwin;

  doInstallCheck = true;

  installCheckPhase = ''
    $out/bin/${mainProgram} --version
  '';

  meta = with lib; {
    description = "1Password command-line tool";
    homepage = "https://developer.1password.com/docs/cli/";
    downloadPage = "https://app-updates.agilebits.com/product_history/CLI2";
    maintainers = with maintainers; [ joelburget marsam ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.unfree;
    inherit mainProgram platforms;
  };
}
