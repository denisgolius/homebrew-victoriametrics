class Victoriametrics < Formula
  desc "Cost-effective and scalable monitoring solution and time series database"
  homepage "https://docs.victoriametrics.com/Single-server-VictoriaMetrics.html"
  url "https://github.com/VictoriaMetrics/VictoriaMetrics/archive/v1.79.8.tar.gz"
  sha256 "aed027c8dabe1cb001f393e361930c675283f4818fd683641e59521eba15cf0b"
  license "Apache-2.0"
  # head 'https://git@github.com:VictoriaMetrics/VictoriaMetrics.git'    

  depends_on "gnu-tar" => :build
  depends_on "go" => :build
  depends_on "cmake" => :build
  
  def install
    ENV.deparallelize
    mkdir_p buildpath/"src/github.com/VictoriaMetrics"
    ln_sf buildpath, buildpath/"src/github.com/VictoriaMetrics/VictoriaMetrics"

    system "make", "victoria-metrics"
    bin.install "bin/victoria-metrics"

    (bin/"victoriametrics_brew_services").write <<~EOS
      #!/bin/bash
      exec #{bin}/victoria-metrics $(<#{etc}/victoriametrics.args)
    EOS

    (buildpath/"victoriametrics.args").write <<~EOS
      --promscrape.config #{etc}/scrape.yml
      --storageDataPath=#{var}/victoriametrics-data
      --retentionPeriod=12
      --httpListenAddr=127.0.0.1:8428 
      --graphiteListenAddr=:2003 
      --opentsdbListenAddr=:4242
      --influxListenAddr=:8089 
      --enableTCP
    EOS

    (buildpath/"scrape.yml").write <<~EOS
      global:
        scrape_interval: 10s

      scrape_configs:
        - job_name: "victoriametrics"
          static_configs:
          - targets: ["localhost:8429"]
    EOS
    etc.install "victoriametrics.args", "scrape.yml"
  end

  def caveats
    <<~EOS
      When run from `brew services`, `victoriametrics` is run from
      `victoriametrics_brew_services` and uses the flags in:
        #{etc}/victoriametrics.args
    EOS
  end

  service do
    run [opt_bin/"victoriametrics_brew_services"]
    keep_alive false
    log_path var/"log/victoria-metrics.log"
    error_log_path var/"log/victoria-metrics.err.log"
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
  