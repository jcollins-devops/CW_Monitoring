#agent install file

<powershell>
            Start-Transcript -path "$env:temp\Logs\UserDataTranscript.log" -append
            (Test-Path "C:\CloudWatchFiles\") -OR (mkdir C:\CloudWatchFiles)
            Copy-S3Object -BucketName aws-ddhc-dealer-prod-bootstrap-storage -KeyPrefix artifacts/monitoring/ -LocalFolder C:\CloudWatchFiles
            Start-Process msiexec.exe -Wait -ArgumentList "/i `"c:\CloudWatchFiles\amazon-cloudwatch-agent.msi`" /qn /l* `"c:\cloudwatchfiles\agentinstall.log`" " 
            $AgentConfigTemplate = Get-Content "C:\CloudWatchFiles\amazon-cloudwatch-agent.template.json"
            $AgentConfigTemplate | % {$_ -replace 'var_instance_hostname','${InstanceHostname}'} | set-content -path "C:\Cloudwatchfiles\config.json" -encoding default -nonewline -force
            $AgentConfigTemplate = Get-Content "C:\CloudWatchFiles\config.json"
            $AgentConfigTemplate | % {$_ -replace 'var_dealer_ou','${DealerOu}'} | set-content -path "C:\Cloudwatchfiles\config.json" -encoding default -nonewline -force
            & "C:\Program Files\Amazon\AmazonCloudWatchAgent\amazon-cloudwatch-agent-ctl.ps1" -a fetch-config -m ec2 -s -c file:C:\CloudWatchFiles\config.json
            Stop-Transcript 
            </powershell>
            <runAsLocalSystem>true</runAsLocalSystem>
            
