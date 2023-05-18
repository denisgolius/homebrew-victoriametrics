class Vmagent < Formula
  desc "Tiny agent which helps you collect metrics from various sources"
  homepage "https://docs.victoriametrics.com/vmagent.html"
  url "https://github.com/VictoriaMetrics/VictoriaMetrics.git",
      tag:      "v1.90.0",
      revision: "b5d18c0d281b5bcd4dc13cc72d897c38fd4bb374"
  license "Apache-2.0"
  head "https://github.com/VictoriaMetrics/VictoriaMetrics.git", branch: "master"

  depends_on "go" => :build

  def install
    ldflags = %W[
      -s -w
      -X github.com/VictoriaMetrics/VictoriaMetrics/lib/buildinfo.Version=vmagent-#{time.strftime("%Y%m%d-%H%M%S")}-#{version}
    ]
    system "go", "build", *std_go_args(ldflags: ldflags), "./app/vmagent"

    (etc/"vmagent/scrape.yml").write <<~EOS
      global:
        scrape_interval: 10s
      scrape_configs:
        - job_name: "vmagent"
          static_configs:
          - targets: ["127.0.0.1:8429"]
    EOS
  end

  service do
    run [
      opt_bin/"vmagent",
      "-httpListenAddr=127.0.0.1:8429",
      "-promscrape.config=#{etc}/vmagent/scrape.yml",
      "-remoteWrite.tmpDataPath==#{var}/vmagent-data",
      "-remoteWrite.url=https://example.com:8428/api/v1/write",
    ]
    keep_alive false
    log_path var/"log/vmagent.log"
    error_log_path var/"log/vmagent.err.log"
  end

  test do
    http_port = free_port

    (testpath/"scrape.yml").write <<~EOS
      global:
        scrape_interval: 10s
      scrape_configs:
        - job_name: "vmagent"
          static_configs:
          - targets: ["127.0.0.1:#{http_port}"]
    EOS

    pid = fork do
      exec bin/"vmagent",
        "-httpListenAddr=127.0.0.1:#{http_port}",
        "-promscrape.config=#{testpath}/scrape.yml",
        "-remoteWrite.tmpDataPath==#{testpath}/vmagent-data",
        "-remoteWrite.url=https://example.com:8428/api/v1/write"
    end
    sleep 30
    assert_match "reload configuration", shell_output("curl -s 127.0.0.1:#{http_port}")
  ensure
    Process.kill(9, pid)
    Process.wait(pid)
  end
end
