# CPU、メモリ、ディスクの使用料80%で警告
$cpuThreshold = 80  # CPU
$memoryThreshold = 80  # メモリ
$diskThreshold = 80  # ディスク

# メールの設定
$smtpServer = "smtp.example.com"  # SMTPサーバー
$smtpFrom = "user.example.com"  # 送信元メールアドレス
$smtpTo = "admin@example.com"  # 管理者メールアドレス
$smtpSubject = "System Alert"
$smtpBody = ""

# システム情報を取得
$cpuUsage = (Get-WmiObject -Class Win32_Processor | Select-Object -First 1).LoadPercentage
$memoryUsage = (Get-WmiObject -Class Win32_OperatingSystem).FreePhysicalMemory
$totalMemory = (Get-WmiObject -Class Win32_OperatingSystem).TotalVisibleMemorySize
$memoryUsagePercentage = [math]::Round((($totalMemory - $memoryUsage) / $totalMemory) * 100)

$diskUsage = (Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType=3" | 
              Select-Object DeviceID, @{Name="UsedSpace";Expression={[math]::round($_.Size - $_.FreeSpace)}}).UsedSpace
$diskTotal = (Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType=3" | 
              Select-Object @{Name="TotalSize";Expression={[math]::round($_.Size)}}).TotalSize
$diskUsagePercentage = [math]::Round(($diskUsage / $diskTotal) * 100)

# 監視結果をチェックしてしきい値を超えているか確認
if ($cpuUsage -gt $cpuThreshold) {
    $smtpBody += "Warning: CPU Usage is at $cpuUsage%`n"
}

if ($memoryUsagePercentage -gt $memoryThreshold) {
    $smtpBody += "Warning: Memory Usage is at $memoryUsagePercentage%`n"
}

if ($diskUsagePercentage -gt $diskThreshold) {
    $smtpBody += "Warning: Disk Usage is at $diskUsagePercentage%`n"
}

# もし80％以上ならメールを送信
if ($smtpBody -ne "") {
    Send-MailMessage -SmtpServer $smtpServer -From $smtpFrom -To $smtpTo -Subject $smtpSubject -Body $smtpBody
    Write-Host "Alert sent: $smtpBody"
} else {
    Write-Host "System is running normally."
}

$logFile = "C:\MonitoringLogs\system_monitor_log.txt"
Add-Content -Path $logFile -Value "$(Get-Date): $smtpBody"
