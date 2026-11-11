require "rails_helper"
require "open3"
require "tmpdir"

# Runs script/backup/backup.sh against a fake `docker` that prints a known dump,
# so the encryption can be checked without a database.
RSpec.describe "script/backup/backup.sh" do
  let(:script) { Rails.root.join("script/backup/backup.sh").to_s }
  let(:dump) { "-- fake dump\nSELECT 1;\n" }

  around do |example|
    Dir.mktmpdir do |dir|
      @dir = dir
      example.run
    end
  end

  def path(name) = File.join(@dir, name)

  def run_backup(recipients:)
    bin = path("bin")
    Dir.mkdir(bin)
    File.write(File.join(bin, "docker"), "#!/bin/sh\nprintf '%s' '#{dump}'\n")
    File.chmod(0o755, File.join(bin, "docker"))

    env = {
      "PATH" => "#{bin}:#{ENV.fetch("PATH")}",
      "APP_DIR" => @dir,
      "BACKUP_DIR" => path("backups"),
      "AGE_RECIPIENTS" => recipients
    }
    Open3.capture3(env, script)
  end

  it "writes only an age-encrypted dump that the private key decrypts" do
    system("age-keygen", "-o", path("key.txt"), err: File::NULL, exception: true)
    File.write(path("recipients.txt"), `age-keygen -y #{path("key.txt")}`)

    _out, err, status = run_backup(recipients: path("recipients.txt"))

    expect(status).to be_success, err
    files = Dir.children(path("backups"))
    expect(files).to contain_exactly(match(/\Aeasy_admin_\d{8}_\d{6}\.sql\.gz\.age\z/))

    encrypted = File.binread(File.join(path("backups"), files.first))
    expect(encrypted).to start_with("age-encryption.org/v1")
    expect(encrypted).not_to include("SELECT 1")

    decrypted, = Open3.capture2("sh", "-c", "age -d -i #{path("key.txt")} | gunzip", stdin_data: encrypted, binmode: true)
    expect(decrypted).to eq(dump)
  end

  it "refuses to run without the public key, so it never writes a plain dump" do
    _out, err, status = run_backup(recipients: path("missing.txt"))

    expect(status).not_to be_success
    expect(err).to include("Missing age recipients file")
    expect(Dir.exist?(path("backups"))).to be(false)
  end
end
