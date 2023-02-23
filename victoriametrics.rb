class Victoriametrics < Formula
  desc "Cost-effective and scalable monitoring solution and time series database"
  homepage "https://victoriametrics.com/"
  url "https://github.com/VictoriaMetrics/VictoriaMetrics/archive/v1.79.8.tar.gz"
  sha256 "aed027c8dabe1cb001f393e361930c675283f4818fd683641e59521eba15cf0b"
  license "Apache-2.0"
  head 'https://git@github.com:VictoriaMetrics/VictoriaMetrics.git'    

  depends_on "go" => :build
  depends_on "cmake" => :build
  
  def install
    ENV.deparallelize
    mkdir_p buildpath/"src/github.com/VictoriaMetrics"
    ln_sf buildpath, buildpath/"src/github.com/VictoriaMetrics"

    system "make", "victoria-metrics"
    bin.install "bin/victoria-metrics"
    mkdir_p etc"/victoriametrics/vmsingle"
    mkdir_p var"/log/victoriametrics/vmsingle"
    mkdir_p var"/lib/victoriametrics-data"

    (bin/"victoriametrics_brew_services").write <<~EOS
      #!/bin/bash
      exec #{bin}/victoria-metrics $(<#{etc}/victoriametrics/vmsingle/victoriametrics.args)
    EOS

    (buildpath/"victoriametrics.args").write <<~EOS
      --config.file #{etc}/victoriametrics/vmsingle/scrape.yml --storageDataPath=/var/lib/victoria-metrics-data
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
        #{etc}/victoria-metrics/vmsingle/vmsingle.args
    EOS
  end

  service do
    run [opt_bin/"victoriametrics_brew_services"]
    keep_alive false
    log_path var/"log/victoriametrics/vmsingle/victoria-metrics.log"
    error_log_path var/"log/victoriametrics/vmsingle/victoria-metrics.err.log"
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
  