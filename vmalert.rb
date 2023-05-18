class Vmalert < Formula
  desc "Alerting tool which executes a list of the given alerting or recording rules"
  homepage "https://docs.victoriametrics.com/vmalert.html"
  url "https://github.com/VictoriaMetrics/VictoriaMetrics.git",
      tag:      "v1.90.0",
      revision: "b5d18c0d281b5bcd4dc13cc72d897c38fd4bb374"
  license "Apache-2.0"
  head "https://github.com/VictoriaMetrics/VictoriaMetrics.git", branch: "master"

  depends_on "go" => :build

  def install
    ldflags = %W[
      -s -w
      -X github.com/VictoriaMetrics/VictoriaMetrics/lib/buildinfo.Version=vmalert-#{time.strftime("%Y%m%d-%H%M%S")}-#{version}
    ]
    system "go", "build", *std_go_args(ldflags: ldflags), "./app/vmalert"

    (etc/"vmalert/alerts.yml").write <<~EOS
      groups:
      # Alerts group for vmalert assumes that Grafana dashboard
      # https://grafana.com/grafana/dashboards/14950-victoriametrics-vmalert/ is installed.
      # Pls update the `dashboard` annotation according to your setup.
      # See more alerts and recoring rules at https://github.com/VictoriaMetrics/VictoriaMetrics/tree/master/deployment/docker
      - name: vmalert
        interval: 30s
        rules:
          - alert: ConfigurationReloadFailure
            expr: vmalert_config_last_reload_successful != 1
            labels:
              severity: warning
            annotations:
              summary: "Configuration reload failed for vmalert instance {{ $labels.instance }}"
              description: "Configuration hot-reload failed for vmalert on instance {{ $labels.instance }}.
                Check vmalert's logs for detailed error message."
    EOS
  end

  service do
    run [
      opt_bin/"vmalert",
      "-rule=alerts.yml",
      "-datasource.url=http://vmsingle-url:8428",
      "-notifier.url=http://alertmanager-url:9093",
      "-remoteWrite.url=http://vmsingle-url:8428",
      "-remoteRead.url=http://vmsingle-url:8428",
      "-external.label=cluster=east-1",
      "-external.label=replica=a",
    ]
    keep_alive false
    log_path var/"log/vmalert.log"
    error_log_path var/"log/vmalert.err.log"
  end

  test do
    (testpath/"alerts.yml").write <<~EOS
      groups:
      # Alerts group for vmalert assumes that Grafana dashboard
      # https://grafana.com/grafana/dashboards/14950-victoriametrics-vmalert/ is installed.
      # Pls update the `dashboard` annotation according to your setup.
      - name: vmalert
        interval: 30s
        rules:
          - alert: ConfigurationReloadFailure
            expr: vmalert_config_last_reload_successful != 1
            labels:
              severity: warning
            annotations:
              summary: "Configuration reload failed for vmalert instance {{ $labels.instance }}"
              description: "Configuration hot-reload failed for vmalert on instance {{ $labels.instance }}.
                Check vmalert's logs for detailed error message."
    EOS
    system "#{bin}/vmalert", "-rule=#{testpath}/alerts.yml", "-dryRun"
  end
end
