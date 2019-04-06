Import-Module UniversalDashboard.Community

#local and remote servers for comparison
$remoteResolverAddress = "208.67.222.222"
$localResolverAddress = "192.168.0.11"
$strRemoteAddressFilter = "Address=`"$remoteResolverAddress`""
$strLocalAddressFilter = "Address=`"$localResolverAddress`""

#Constants
$intDataPointHistory = 60
$RefreshIntervalSeconds = 1

$strLeftChartBackgroundColor = '#80FF6B63'
$strLeftBorderColor = '#FFFF6B63'

$strRightChartBackgroundColor = '#50f442'
$strRightBorderColor = 'green'

$MyDashboard = New-UDDashboard -Title "Ping and DNS test" -Content {
$options = New-UDLineChartOptions -yAxes (New-UDLinearChartAxis -Minimum 0)

    #Row 1
    New-UDRow -Columns {            
        New-UDColumn -Size 3 {
            New-UdMonitor -Title "google.com@OpenDNS-222" -Type Line -DataPointHistory $intDataPointHistory -RefreshInterval $RefreshIntervalSeconds -ChartBackgroundColor $strLeftChartBackgroundColor -ChartBorderColor $strLeftBorderColor -Options $options   -Endpoint {
                Measure-Command {Resolve-DnsName google.com -Server $remoteResolverAddress -DnsOnly} | Select-Object -ExpandProperty Milliseconds | Out-UDMonitorData
           }
        }
        New-UDColumn -Size 3 {
            New-UdMonitor -Title "blog@OpenDNS-222" -Type Line -DataPointHistory $intDataPointHistory -RefreshInterval $RefreshIntervalSeconds -ChartBackgroundColor $strLeftChartBackgroundColor -ChartBorderColor $strLeftBorderColor -Options $options   -Endpoint {
                Measure-Command {Resolve-DnsName blog.mesmontgomery.co.uk -Server $remoteResolverAddress -DnsOnly} | Select-Object -ExpandProperty Milliseconds | Out-UDMonitorData
           }
        }
        New-UDColumn -Size 3 {
            New-UdMonitor -Title "blog@Pi-2" -Type Line -DataPointHistory $intDataPointHistory -RefreshInterval $RefreshIntervalSeconds -ChartBackgroundColor $strRightChartBackgroundColor -ChartBorderColor $strRightBorderColor -Options $options   -Endpoint {
                Measure-Command {Resolve-DnsName blog.mesmontgomery.co.uk -Server $localResolverAddress -DnsOnly} | Select-Object -ExpandProperty Milliseconds | Out-UDMonitorData
                }   
        }
        New-UDColumn -Size 3 {
                New-UdMonitor -Title "google.com@Pi-2" -Type Line -DataPointHistory $intDataPointHistory -RefreshInterval $RefreshIntervalSeconds -ChartBackgroundColor $strRightChartBackgroundColor -ChartBorderColor $strRightBorderColor -Options $options   -Endpoint {
                    Measure-Command {Resolve-DnsName google.com -Server $localResolverAddress -DnsOnly} | Select-Object -ExpandProperty Milliseconds | Out-UDMonitorData
                    }   
        }          
    }

    #Row 2
    New-UDRow -Columns {            
        New-UDColumn -Size 6 {
            New-UdMonitor -Title "Ping Response OpenDNS-222" -Type Line -DataPointHistory $intDataPointHistory -RefreshInterval $RefreshIntervalSeconds -ChartBackgroundColor $strLeftChartBackgroundColor -ChartBorderColor $strLeftBorderColor -Options $options   -Endpoint {
                Get-WmiObject -Class Win32_PingStatus -Filter $strRemoteAddressFilter | Select-Object -ExpandProperty responseTime | Out-UDMonitorData
           }
    }
    New-UDColumn -Size 6 {
        New-UdMonitor -Title "Ping Response Pi-2" -Type Line -DataPointHistory $intDataPointHistory -RefreshInterval $RefreshIntervalSeconds -ChartBackgroundColor $strRightChartBackgroundColor -ChartBorderColor $strRightBorderColor -Options $options   -Endpoint {
            Get-WmiObject -Class Win32_PingStatus -Filter $strLocalAddressFilter | Select-Object -ExpandProperty responseTime | Out-UDMonitorData
        }
    }
}
   
}

#Start the dashboard and autoreload if you change the variables above (such as interval or history)
Start-UDDashboard -Port 1000 -Dashboard $MyDashboard -AutoReload
