# class Vmctl < Formula
#   desc "VictoriaMetrics command-line tool which provide Vmctl data migration from InfluxDB, Prometheus, Thanos, Cortex to VictoriaMetrics"
#   homepage "https://docs.victoriametrics.com/vmctl.html"
#   url "https://github.com/VictoriaMetrics/VictoriaMetrics/archive/v1.89.1.tar.gz"
#   sha256 "3c090a8ce399452322ac1718c4bfd878a46c1f17366c0db2587d95cd915c8fd4"
#   license "Apache-2.0"
class Vmctl < Formula
  desc "VictoriaMetrics command-line tool which provide Vmctl data migration from InfluxDB, Prometheus, Thanos, Cortex to VictoriaMetrics"
  homepage "https://docs.victoriametrics.com/vmctl.html"
  url "https://github.com/VictoriaMetrics/VictoriaMetrics.git",
      tag:      "v1.89.1",
      revision: "388d6ee16e6b51597f05d5556027943a4cb07547"
  license "Apache-2.0"
  # head "https://github.com/VictoriaMetrics/VictoriaMetrics.git", branch: "master"


  depends_on "go" => :build

  def install
    system "make", "vmctl"
    bin.install "bin/vmctl"
    ohai "Documentation: https://docs.victoriametrics.com/vmctl.html"
    ohai "VictoriaMetrics Github : https://github.com/VictoriaMetrics/VictoriaMetrics"
    ohai "Join our communities: https://docs.victoriametrics.com/Single-server-VictoriaMetrics.html#contacts"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/vmctl --version")
  end
end