class Vmagent < Formula
  desc "Data migration tool used to migrate data from supported DBs to VictoriaMetrics"
  homepage "https://docs.victoriametrics.com/vmctl.html"
  url "https://github.com/VictoriaMetrics/VictoriaMetrics.git",
      tag:      "v1.90.0",
      revision: "b5d18c0d281b5bcd4dc13cc72d897c38fd4bb374"
  license "Apache-2.0"
  head "https://github.com/VictoriaMetrics/VictoriaMetrics.git", branch: "master"

  depends_on "go" => :build

  def install
    ldflags = %W[
      -s -w
      -X github.com/VictoriaMetrics/VictoriaMetrics/lib/buildinfo.Version=vmctl-#{time.strftime("%Y%m%d-%H%M%S")}-#{version}
    ]
    system "go", "build", *std_go_args(ldflags: ldflags), "./app/vmctl"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/vmctl --version")
  end
end
