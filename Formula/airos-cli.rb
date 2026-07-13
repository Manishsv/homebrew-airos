# Homebrew formula for the AirOS CLI.
#
# This lives in a TAP repo (github.com/<you>/homebrew-airos) as
# Formula/airos-cli.rb. The formula is named "airos-cli" but installs the
# `airos` executable. See packaging/homebrew/README.md for the full publish
# workflow (build sdist -> GitHub release -> generate resources -> tap).
class AirosCli < Formula
  include Language::Python::Virtualenv

  desc "AirOS CLI — data explorer & AI chat for Sustainable Cities (IIT Kanpur)"
  homepage "https://github.com/Manishsv/AirOS"
  # Released sdist of the cli/ package (python -m build), hosted on the PUBLIC
  # tap repo so `brew install` can fetch it without auth (the AirOS source repo
  # is private). Update version + sha256 each release via publish.sh.
  url "https://github.com/Manishsv/homebrew-airos/releases/download/cli-v0.1.0/airos-0.1.0.tar.gz"
  sha256 "08fbcfbbc2f2061287d44e0dcd21aa93dff7252e9b53a35114ddc852c8610b11"
  license "MIT"

  depends_on "python@3.12"

  # --- Python dependency resources -----------------------------------------
  # Direct + transitive deps of the BASE CLI (auth, registry, data explorer),
  # pinned to PyPI sdists. All pure-Python — they build in brew's offline venv.
  # Regenerate on a dep bump with:
  #     brew update-python-resources Formula/airos-cli.rb
  # `airos chat` extras (anthropic, openai) are intentionally NOT bundled: their
  # tree needs a Rust toolchain (tokenizers) that won't build in the sandbox.
  # For full chat, use the pipx install in packaging/homebrew/README.md instead.
  resource "click" do
    url "https://files.pythonhosted.org/packages/96/d3/f04c7bfcf5c1862a2a5b845c6b2b360488cf47af55dfa79c98f6a6bf98b5/click-8.1.7.tar.gz"
    sha256 "ca9853ad459e787e2192211578cc907e7594e294c7ccc834310722b41b9ca6de"
  end

  resource "requests" do
    url "https://files.pythonhosted.org/packages/63/70/2bf7780ad2d390a8d301ad0b550f1581eadbd9a20f896afe06353c2a2913/requests-2.32.3.tar.gz"
    sha256 "55365417734eb18255590a9ff9eb97e9e1da868d4ccd6402399eaf68af20a760"
  end

  resource "PyYAML" do
    url "https://files.pythonhosted.org/packages/54/ed/79a089b6be93607fa5cdaedf301d7dfb23af5f25c398d5ead2525b063e17/pyyaml-6.0.2.tar.gz"
    sha256 "d584d9ec91ad65861cc08d42e834324ef890a082e591037abe114850ff7bbc3e"
  end

  resource "h3" do
    url "https://files.pythonhosted.org/packages/8f/8d/b10085f4f6ef7d4cb126a2e0eaf9e907e89cf99965b6578a3d1666f1435e/h3-3.7.7.tar.gz"
    sha256 "33d141c3cef0725a881771fd8cb80c06a0db84a6e4ca5c647ce095ae07c61e94"
  end

  # requests transitive deps:
  resource "certifi" do
    url "https://files.pythonhosted.org/packages/c9/c7/424b75da314c1045981bd9777432fad05a9e0c69daa4ed7e308bbaffe405/certifi-2026.6.17.tar.gz"
    sha256 "024c88eeec92ca068db80f02b8b07c9cef7b9fe261d1d535abfd5abd6f6af432"
  end

  resource "charset-normalizer" do
    url "https://files.pythonhosted.org/packages/63/09/c1bc53dab74b1816a00d8d030de5bf98f724c52c1635e07681d312f20be8/charset-normalizer-3.3.2.tar.gz"
    sha256 "f30c3cb33b24454a82faecaf01b19c18562b1e89558fb6c56de4d9118a032fd5"
  end

  resource "idna" do
    url "https://files.pythonhosted.org/packages/21/ed/f86a79a07470cb07819390452f178b3bef1d375f2ec021ecfc709fc7cf07/idna-3.7.tar.gz"
    sha256 "028ff3aadf0609c1fd278d8ea3089299412a7a8b9bd005dd08b9f8285bcb5cfc"
  end

  resource "urllib3" do
    url "https://files.pythonhosted.org/packages/ed/63/22ba4ebfe7430b76388e7cd448d5478814d3032121827c12a2cc287e2260/urllib3-2.2.3.tar.gz"
    sha256 "e7d814a81dad81e6caf2ec9fdedb284ecc9c73076b62654547cc64ccdcae26e9"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match "airos", shell_output("#{bin}/airos --help")
  end
end
