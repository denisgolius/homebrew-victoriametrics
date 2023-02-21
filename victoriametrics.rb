class Victoriametrics < Formula
    desc "Cost-effective and scalable monitoring solution and time series database"
    homepage "https://victoriametrics.com/"
    url "https://github.com/VictoriaMetrics/VictoriaMetrics/archive/v1.79.8.tar.gz"
    sha256 "aed027c8dabe1cb001f393e361930c675283f4818fd683641e59521eba15cf0b"
    license "Apache-2.0"
    head 'https://git@github.com:VictoriaMetrics/VictoriaMetrics.git'    

    depends_on "go" => :build
  
    def install
      system "make", "victoria-metrics"
      bin.install "bin/victoria-metrics"
    end
  
    test do
      Open3.popen3("#{bin}/victoria-metrics") do |_, stdout, _, wait_thr|
        sleep 0.5
        begin
          assert_match "build version", stdout.read
        ensure
          Process.kill "TERM", wait_thr.pid
        end
      end
    end
  end
  