{ lib
, mkDerivation
, fetchurl
, autoPatchelfHook
, pkg-config
, ffmpeg
, openssl
, qtbase
, zlib

, withJava ? true
, jre_headless
}:

let
  version = "1.16.4";
  # Using two URLs as the first one will break as soon as a new version is released
  src_bin = fetchurl {
    urls = [
      "http://www.makemkv.com/download/makemkv-bin-${version}.tar.gz"
      "http://www.makemkv.com/download/old/makemkv-bin-${version}.tar.gz"
    ];
    sha256 = "18kalql846b9ggl3nsz2dpbg51byn8pj0y68fsdcgwwkgvsx7yr2";
  };
  src_oss = fetchurl {
    urls = [
      "http://www.makemkv.com/download/makemkv-oss-${version}.tar.gz"
      "http://www.makemkv.com/download/old/makemkv-oss-${version}.tar.gz"
    ];
    sha256 = "0ssg3q1z80652d4gkv1z7kpsxx82xcw6kpsw266c8q4y2n8x7c76";
  };
in mkDerivation {
  pname = "makemkv";
  inherit version;

  srcs = [ src_bin src_oss ];

  sourceRoot = "makemkv-oss-${version}";

  nativeBuildInputs = [ autoPatchelfHook pkg-config ];

  buildInputs = [ ffmpeg openssl qtbase zlib ];

  qtWrapperArgs =
    let
      binPath = lib.makeBinPath [ jre_headless ];
    in lib.optionals withJava [
      "--prefix PATH : ${binPath}"
    ];

  installPhase = ''
    runHook preInstall

    install -Dm555 -t $out/bin           out/makemkv ../makemkv-bin-${version}/bin/amd64/makemkvcon
    install -D     -t $out/lib           out/lib{driveio,makemkv,mmbd}.so.*
    install -D     -t $out/share/MakeMKV ../makemkv-bin-${version}/src/share/*

    runHook postInstall
  '';

  meta = with lib; {
    description = "Convert blu-ray and dvd to mkv";
    longDescription = ''
      makemkv is a one-click QT application that transcodes an encrypted
      blu-ray or DVD disc into a more portable set of mkv files, preserving
      subtitles, chapter marks, all video and audio tracks.

      Program is time-limited -- it will stop functioning after 60 days. You
      can always download the latest version from makemkv.com that will reset the
      expiration date.
    '';
    license = licenses.unfree;
    homepage = "http://makemkv.com";
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ titanous ];
  };
}
