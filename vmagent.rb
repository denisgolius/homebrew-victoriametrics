class Vmagent < Formula
    desc "A tiny agent which helps you collect metrics from various sources"
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
    end

    test do
      assert_match version.to_s, shell_output("#{bin}/vmagent --version")
    end
  end
