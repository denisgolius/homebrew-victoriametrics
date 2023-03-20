class Vmctl < Formula
  desc "VictoriaMetrics command-line tool which provide Vmctl data migration from InfluxDB, Prometheus, Thanos, Cortex to VictoriaMetrics"
  homepage "https://docs.victoriametrics.com/vmctl.html"
  url "https://github.com/VictoriaMetrics/VictoriaMetrics/archive/v1.89.1.tar.gz"
  sha256 "3c090a8ce399452322ac1718c4bfd878a46c1f17366c0db2587d95cd915c8fd4"
  license "Apache-2.0"

  depends_on "go" => :build
  depends_on "make" => :build

  def install
    system "make", "vmctl"
    bin.install "bin/vmctl"
  end

  test do
    Open3.popen3("#{bin}/vmctl -v") do |_, stdout, _, wait_thr|
      sleep 0.5
      begin
        assert_match "vmctl version", stdout.read
      ensure
        Process.kill "TERM", wait_thr.pid
      end
    end
  end
end