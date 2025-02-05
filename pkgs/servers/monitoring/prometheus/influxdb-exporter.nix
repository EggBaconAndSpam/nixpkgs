{ lib, buildGoModule, fetchFromGitHub, nixosTests }:

buildGoModule rec {
  pname = "influxdb_exporter";
  version = "0.8.0";
  rev = "v${version}";

  src = fetchFromGitHub {
    inherit rev;
    owner = "prometheus";
    repo = "influxdb_exporter";
    sha256 = "sha256-aNj4ru3yDet+jdcEpckFVaymmjWmKzTMPcTxPMNFbgo=";
  };

  vendorSha256 = null;

  buildFlagsArray = let
    goPackagePath = "github.com/prometheus/influxdb_exporter";
  in ''
    -ldflags=
        -s -w
        -X github.com/prometheus/common/version.Version=${version}
        -X github.com/prometheus/common/version.Revision=${rev}
        -X github.com/prometheus/common/version.Branch=unknown
        -X github.com/prometheus/common/version.BuildUser=nix@nixpkgs
        -X github.com/prometheus/common/version.BuildDate=unknown
  '';

  passthru.tests = { inherit (nixosTests.prometheus-exporters) influxdb; };

  meta = with lib; {
    description = "Prometheus exporter that accepts InfluxDB metrics";
    homepage = "https://github.com/prometheus/influxdb_exporter";
    license = licenses.asl20;
    maintainers = with maintainers; [ hexa ];
    platforms = platforms.unix;
  };
}
