class Vmutils < Formula
  homepage "https://victoriametrics.com/"
  url "https://github.com/VictoriaMetrics/VictoriaMetrics/archive/v1.90.0.tar.gz"
  sha256 "13ab7de804c5d1f1deed52657fff2e454842bd0f469f9c0bbc913c69511f34ed"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on "go" => :build

  def install
    system "make", "vmutils"
    bin.install %w[vmagent vmctl vmalert vmauth vmbackup vmrestore]

    (etc/"vmagent/scrape.yml").write <<~EOS
      global:
        scrape_interval: 10s
      scrape_configs:
        - job_name: "vmagent"
          static_configs:
          - targets: ["127.0.0.1:8429"]
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/vmctl --version")
  end
end
