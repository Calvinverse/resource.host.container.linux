Describe 'The firewall' {
    $ufwOutput = & sudo ufw status

    Context 'on the machine' {
        It 'should return a status' {
            $ufwOutput | Should Not Be $null
            $ufwOutput.GetType().FullName | Should Be 'System.Object[]'
            $ufwOutput.Length | Should Be 31
        }

        It 'should be enabled' {
            $ufwOutput[0] | Should Be 'Status: active'
        }
    }

    Context 'should allow SSH' {
        It 'on port 22' {
            ($ufwOutput | Where-Object {$_ -match '(22)\s*(ALLOW)\s*(Anywhere)'} ) | Should Not Be ''
        }
    }

    Context 'should allow consul' {
        It 'on port 8300' {
            ($ufwOutput | Where-Object {$_ -match '(8300)\s*(ALLOW)\s*(Anywhere)'} ) | Should Not Be ''
        }

        It 'on port 8301' {
            ($ufwOutput | Where-Object {$_ -match '(8301)\s*(ALLOW)\s*(Anywhere)'} ) | Should Not Be ''
        }

        It 'on port 8500' {
            ($ufwOutput | Where-Object {$_ -match '(8500)\s*(ALLOW)\s*(Anywhere)'} ) | Should Not Be ''
        }

        It 'on port 8600' {
            ($ufwOutput | Where-Object {$_ -match '(8600)\s*(ALLOW)\s*(Anywhere)'} ) | Should Not Be ''
        }
    }

    Context 'should allow nomad' {
        It 'on port 4646' {
            ($ufwOutput | Where-Object {$_ -match '(4646)\s*(ALLOW)\s*(Anywhere)'} ) | Should Not Be ''
        }

        It 'on port 4647' {
            ($ufwOutput | Where-Object {$_ -match '(4647)\s*(ALLOW)\s*(Anywhere)'} ) | Should Not Be ''
        }

        It 'on port 4648' {
            ($ufwOutput | Where-Object {$_ -match '(4647)\s*(ALLOW)\s*(Anywhere)'} ) | Should Not Be ''
        }
    }

    Context 'should allow vault' {
        It 'on port 8200'{
            ($ufwOutput | Where-Object {$_ -match '(8200)\s*(ALLOW)\s*(Anywhere)'} ) | Should Not Be ''
        }

        It 'on port 8201' {
            ($ufwOutput | Where-Object {$_ -match '(8201)\s*(ALLOW)\s*(Anywhere)'} ) | Should Not Be ''
        }
    }
}
