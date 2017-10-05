Describe 'The network' {
    Context 'on the machine' {
        It 'should have a SSH configuration' {
            '/etc/ssh/sshd_config' | Should Exist
        }

        $sshdConfig = Get-Content /etc/ssh/sshd_config

        It 'should allow SSH' {
            $sshdConfig | Should Not Be $null
            ($sshdConfig | Where-Object { $_ -match '(Port)\s*(22)' }) | Should Not Be ''
        }
    }

    Context 'interface' {
        $netstatOutput = & netstat -i
        $line = $netstatOutput | Where-Object { $_.StartsWith('eth0') } | Select-Object -First 1
        $flags = $line.Substring($line.LastIndexOf(' ')).Trim()

        It 'should be in promiscuous mode' {
            $flags | Should Be 'BMPRU'
        }
    }
}
