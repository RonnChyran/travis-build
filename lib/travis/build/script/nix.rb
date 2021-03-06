# Maintained by
#  - Domen Kožar   @domenkozar   <domen@dev.si>
#  - Rok Garbas    @garbas       <rok@garbas.si>
#  - Matthew Bauer @matthewbauer <mjbauer95@gmail.com>

module Travis
  module Build
    class Script
      class Nix < Script
        DEFAULTS = {}

        def export
          super

          # prevent curl from polluting logs but still show errors
          sh.export 'NIX_CURL_FLAGS', '-sS'
        end

        def configure
          super

          # Set nix config dir and make config Hydra compatible
          sh.cmd "sudo mkdir -p /etc/nix"
          sh.cmd "echo 'build-max-jobs = 4' | sudo tee /etc/nix/nix.conf > /dev/null"

          # Nix needs to be able to exec on /tmp on Linux
          # This will emit an error in the container but
          # it's still needed for "trusty" Linux.
          if config[:os] == 'linux'
            sh.cmd "sudo mount -o remount,exec /run"
            sh.cmd "sudo mount -o remount,exec /run/user"
          end

          # setup /nix dir for rootless install in setup
          sh.cmd "sudo mkdir -p -m 0755 /nix/"
          sh.cmd "sudo chown $USER /nix/"
        end

        def setup
          super

          sh.fold 'nix.install' do
            sh.cmd "wget --retry-connrefused --waitretry=1 -O /tmp/nix-install https://nixos.org/nix/install"
            sh.cmd "sh /tmp/nix-install"
            sh.cmd "source $HOME/.nix-profile/etc/profile.d/nix.sh"
          end
        end

        def announce
          super

          sh.echo 'Nix support for Travis CI is community maintained.', ansi: :green
          sh.echo 'Please open any issues at https://github.com/travis-ci/travis-ci/issues/new and cc @domenkozar @garbas @matthewbauer', ansi: :green

          sh.cmd "nix-env --version"
        end

        def script
          sh.cmd 'nix-build'
        end
      end
    end
  end
end
