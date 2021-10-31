BeforeAll {
    $serviceConfigurationPath = '/lib/systemd/system/docker.service'
}

Describe 'Docker' {
    Context 'is installed' {
        It 'with binaries in /usr/bin' {
            '/usr/bin/docker' | Should -Exist
        }

        It 'with deamon configuration in /etc/docker/daemon.json' {
            '/etc/docker/daemon.json' | Should -Exist
        }
    }

    Context 'has been daemonized' {

        It 'has a systemd configuration' {
            if (-not (Test-Path $serviceConfigurationPath))
            {
                $false | Should -Be $true
            }
        }

        It 'with a systemd service' {
            $expectedContent = @'
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service containerd.service
Wants=network-online.target
Requires=docker.socket containerd.service

[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always

# Note that StartLimit* options were moved from "Service" to "Unit" in systemd 229.
# Both the old, and new location are accepted by systemd 229 and up, so using the old location
# to make them work for either version of systemd.
StartLimitBurst=3

# Note that StartLimitInterval was renamed to StartLimitIntervalSec in systemd 230.
# Both the old, and new name are accepted by systemd 230 and up, so using the old name to make
# this option work for either version of systemd.
StartLimitInterval=60s

# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity

# Comment TasksMax if your systemd version does not support it.
# Only systemd 226 and above support this option.
TasksMax=infinity

# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes

# kill only the docker process, not all processes in the cgroup
KillMode=process
OOMScoreAdjust=-500

[Install]
WantedBy=multi-user.target

'@
            $serviceFileContent = Get-Content $serviceConfigurationPath | Out-String
            $serviceFileContent | Should -Be ($expectedContent -replace "`r", "")

            $systemctlOutput = & systemctl status docker
            $systemctlOutput | Should -Not -Be $null
            $systemctlOutput.GetType().FullName | Should -Be 'System.Object[]'
            $systemctlOutput.Length | Should -BeGreaterThan 3
            $systemctlOutput[0] | Should -Match 'docker.service - Docker Application Container Engine'
        }

        It 'that is enabled' {
            $systemctlOutput = & systemctl status docker
            $systemctlOutput[1] | Should -Match 'Loaded:\sloaded\s\(.*;\senabled;.*\)'

        }

        It 'and is running' {
            $systemctlOutput = & systemctl status docker
            $systemctlOutput[2] | Should -Match 'Active:\sactive\s\(running\).*'
        }
    }

    <#
    Context 'has the network' {
        It 'should have a macvlan network' {
            $output = docker network ls
            $line = $output |
            Where-Object { $_.Contains('docker_macvlan') } |
            Select-Object -First 1

            $line | Should -Not -Be $null
            $line | Should -Not -Be ''
        }
    }
    #>
}
