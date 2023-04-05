class Vmrestore < Formula
    desc "Tool which restores data from backups created by vmbackup."
    homepage "https://docs.victoriametrics.com/vmrestore.html"
    url "https://github.com/VictoriaMetrics/VictoriaMetrics.git",
        tag:      "v1.89.1",
        revision: "388d6ee16e6b51597f05d5556027943a4cb07547"
    license "Apache-2.0"
    head "https://github.com/VictoriaMetrics/VictoriaMetrics.git", branch: "master"
  
    depends_on "go" => :build
  
    def install
      system "make", "vmrestore"
      bin.install "bin/vmrestore"
      ohai "Documentation: https://docs.victoriametrics.com/vmrestore.html"
      ohai "VictoriaMetrics Github : https://github.com/VictoriaMetrics/VictoriaMetrics"
      ohai "Join our communities: https://docs.victoriametrics.com/Single-server-VictoriaMetrics.html#contacts"
    end
  
    test do
      assert_match version.to_s, shell_output("#{bin}/vmctl --version")
    end
  end
  