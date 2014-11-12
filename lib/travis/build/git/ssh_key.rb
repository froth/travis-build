module Travis
  module Build
    class Git
      class SshKey < Struct.new(:sh, :data)
        def apply
          sh.echo messages

          sh.file '~/.ssh/id_rsa', key.value
          sh.chmod 600, '~/.ssh/id_rsa', echo: false
          sh.raw 'eval `ssh-agent` &> /dev/null'
          sh.raw 'ssh-add ~/.ssh/id_rsa &> /dev/null'

          # BatchMode - If set to 'yes', passphrase/password querying will be disabled.
          # TODO ... how to solve StrictHostKeyChecking correctly? deploy a known_hosts file?
          sh.file '~/.ssh/config', "Host #{data.source_host}\n\tBatchMode yes\n\tStrictHostKeyChecking no\n", append: true
        end

        private

          def key
            data.ssh_key
          end

          def messages
            msgs = ["\nInstalling an SSH key #{" from: #{source}" if key.source}"]
            msgs = "Key fingerprint: #{key.fingerprint}\n" if key.fingerprint
            msgs
          end

          def source
            key.source.gsub(/[_-]+/, ' ')
          end
      end
    end
  end
end