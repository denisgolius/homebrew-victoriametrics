class VictoriametricsVmctl < Formula
  desc "VictoriaMetrics command-line tool which provide Vmctl data migration from InfluxDB, Prometheus, Thanos, Cortex to VictoriaMetrics"
  homepage "https://docs.victoriametrics.com/vmctl.html"
  url "https://github.com/VictoriaMetrics/VictoriaMetrics/archive/v1.87.1.tar.gz"
  sha256 "9fbb0ffe36b177387397f2d66733da605cf2bf7a9ec5242bb0c82fba2d4a56f9"
  license "Apache-2.0"

  depends_on "go" => :build
  depends_on "cmake" => :build

  def install
    system "make", "vmctl"
    bin.install "bin/vmctl"
    ohai 'Thanks for using VictoriaMetrics command-line tool!'
    ohai 'See the vmctl documetation: https://docs.victoriametrics.com/vmctl.html'
    ohai 'Join our communities: https://docs.victoriametrics.com/Single-server-VictoriaMetrics.html#contacts'
  end

  test do
    Open3.popen3("#{bin}/vmctl") do |_, stdout, _, wait_thr|
      sleep 0.5
      begin
        assert_match "help", stdout.read
      ensure
        Process.kill "TERM", wait_thr.pid
      end
    end
  end
end
