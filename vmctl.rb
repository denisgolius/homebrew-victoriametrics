class Vmctl < Formula
  desc "VictoriaMetrics command-line tool which provide Vmctl data migration from InfluxDB, Prometheus, Thanos, Cortex to VictoriaMetrics"
  homepage "https://docs.victoriametrics.com/vmctl.html"
  url "https://github.com/VictoriaMetrics/VictoriaMetrics/archive/v1.89.1.tar.gz"
  sha256 "3c090a8ce399452322ac1718c4bfd878a46c1f17366c0db2587d95cd915c8fd4"
  license "Apache-2.0"

  depends_on "go" => :build

  def install
    system "make", "vmctl"
    bin.install "bin/vmctl"
    ohai "Documentation: https://docs.victoriametrics.com/vmctl.html"
    ohai "VictoriaMetrics Github : https://github.com/VictoriaMetrics/VictoriaMetrics"
    ohai "Join our communities: https://docs.victoriametrics.com/Single-server-VictoriaMetrics.html#contacts"
  end

  test do
    Open3.popen3("#{bin}/vmctl --version") do |_, stdout, _, wait_thr|
      sleep 1
      begin
        assert_match "vmctl - VictoriaMetrics command-line tool", stdout.read
      ensure
        Process.kill(9, pid)
        Process.wait(pid)
      end
    end
  end
end