function Get-IpAddress
{
    $ErrorActionPreference = 'Stop'

    $output = & ip a show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1

    return $output.Trim()
}

function Initialize-Environment
{
    $ErrorActionPreference = 'Stop'

    try
    {
        Start-TestConsul

        Install-Nomad -nomadVersion '1.0.4'
        Start-TestNomad

        Write-Output "Waiting for 10 seconds for consul, nomad and vault to start ..."
        Start-Sleep -Seconds 10

        Join-Cluster

        Set-ConsulKV

        Write-Output "Giving consul-template 30 seconds to process the data ..."
        Start-Sleep -Seconds 30
    }
    catch
    {
        $currentErrorActionPreference = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'

        try
        {
            Write-Error $errorRecord.Exception
            Write-Error $errorRecord.ScriptStackTrace
            Write-Error $errorRecord.InvocationInfo.PositionMessage
        }
        finally
        {
            $ErrorActionPreference = $currentErrorActionPreference
        }

        # rethrow the error
        throw $_.Exception
    }
}

function Install-Nomad
{
    [CmdletBinding()]
    param(
        [string] $nomadVersion
    )

    & wget "https://releases.hashicorp.com/nomad/$($nomadVersion)/nomad_$($nomadVersion)_linux_amd64.zip" --output-document /test/nomad.zip
    & unzip /test/nomad.zip -d /test/nomad
}

function Join-Cluster
{
    Write-Output "Joining the local consul ..."

    # connect to the actual local consul instance
    $ipAddress = Get-IpAddress
    Write-Output "Joining: $($ipAddress):8351"

    Start-Process -FilePath 'consul' -ArgumentList "join $($ipAddress):8351"

    Write-Output "Getting members for client"
    & consul members

    Write-Output "Getting members for server"
    & consul members -http-addr=http://127.0.0.1:8550
}

function Set-ConsulKV
{
    Write-Output "Setting consul key-values ..."

    # Load config/services/consul
    & consul kv put -http-addr=http://127.0.0.1:8550 config/services/consul/datacenter 'test-integration'
    & consul kv put -http-addr=http://127.0.0.1:8550 config/services/consul/domain 'integrationtest'

    & consul kv put -http-addr=http://127.0.0.1:8550 config/services/consul/statsd/rules '\"*.*.* measurement.measurement.field\",'

    # Explicitly don't provide a metrics address because that means telegraf will just send the metrics to
    # a black hole
    & consul kv put -http-addr=http://127.0.0.1:8550 config/services/metrics/databases/system 'system'
    & consul kv put -http-addr=http://127.0.0.1:8550 config/services/metrics/databases/statsd 'services'

    # Load config/services/jobs
    & consul kv put -http-addr=http://127.0.0.1:8550 config/services/jobs/bootstrap '1'
    & consul kv put -http-addr=http://127.0.0.1:8550 config/services/jobs/protocols/http/host 'http.jobs'
    & consul kv put -http-addr=http://127.0.0.1:8550 config/services/jobs/protocols/http/port '4646'
    & consul kv put -http-addr=http://127.0.0.1:8550 config/services/jobs/protocols/http/tls 'false'
    & consul kv put -http-addr=http://127.0.0.1:8550 config/services/jobs/protocols/rpc/tls 'false'
    & consul kv put -http-addr=http://127.0.0.1:8550 config/services/jobs/region 'integrationtest'
    & consul kv put -http-addr=http://127.0.0.1:8550 config/services/jobs/tls/verify 'false'
    & consul kv put -http-addr=http://127.0.0.1:8550 config/services/jobs/vault/enabled 'false'
    & consul kv put -http-addr=http://127.0.0.1:8550 config/services/jobs/vault/ts/skip 'true'

    # load config/services/queue
    & consul kv put -http-addr=http://127.0.0.1:8550 config/services/queue/protocols/http/host 'http.queue'
    & consul kv put -http-addr=http://127.0.0.1:8550 config/services/queue/protocols/http/port '15672'
    & consul kv put -http-addr=http://127.0.0.1:8550 config/services/queue/protocols/amqp/host 'amqp.queue'
    & consul kv put -http-addr=http://127.0.0.1:8550 config/services/queue/protocols/amqp/port '5672'

    & consul kv put -http-addr=http://127.0.0.1:8550 config/services/queue/logs/syslog/username 'testuser'
    & consul kv put -http-addr=http://127.0.0.1:8550 config/services/queue/logs/syslog/vhost 'testlogs'

    # Load config/services/vault
    & consul kv put -http-addr=http://127.0.0.1:8550 config/services/secrets/protocols/http/host 'secrets'
    & consul kv put -http-addr=http://127.0.0.1:8550 config/services/secrets/protocols/http/port '8200'
}

function Start-TestConsul
{
    [CmdletBinding()]
    param(
    )

    if (-not (Test-Path /test/consul))
    {
        New-Item -Path /test/consul -ItemType Directory | Out-Null
    }

    Write-Output "Starting consul ..."
    $process = Start-Process `
        -FilePath "consul" `
        -ArgumentList "agent -config-file /test/pester/environment/consul.json" `
        -PassThru `
        -RedirectStandardOutput /test/consul/output.out `
        -RedirectStandardError /test/consul/error.out

    Write-Output "Waiting for Consul to start ..."
    Start-Sleep -Seconds 10

    Write-Output "Getting members for client"
    & consul members

    Write-Output "Getting members for server"
    & consul members -http-addr=http://127.0.0.1:8550
}

function Start-TestNomad
{
    [CmdletBinding()]
    param(
    )

    Write-Output "Starting nomad ..."
    Start-Process `
        -FilePath "/test/nomad/nomad" `
        -ArgumentList 'agent -config=/test/pester/environment/nomad.hcl' `
        -RedirectStandardOutput /test/nomad/output.out `
        -RedirectStandardError /test/nomad/error.out
}
