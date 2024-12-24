# インポート
Add-Type -AssemblyName "System.Windows.Forms"  # 通知用

# 商品ページURL
$url = "https://www.amazon.co.jp/dp/B09Z2QYYD1"

# ウェブページの内容を取得
$response = Invoke-WebRequest -Uri $url

# 金額を正規表現で抽出
$priceText = $response.Content | Select-String -Pattern '<span class="a-price-whole">(\d{1,3}(?:,\d{3})*)</span>' | ForEach-Object { $_.Matches.Groups[1].Value }

# 金額を整える
$price = [int]$priceText.Replace(',', '')

# CSVに保存
$csvPath = "C:\Users\username\rice.csv"  # パスは実際に保存する場所に変更してください
$priceData = [PSCustomObject]@{ Date = (Get-Date); Price = $price }
$priceData | Export-Csv -Path $csvPath -Append -NoTypeInformation

# 価格が40,000円を切った場合、メール通知を送る
if ($price -lt 40000) {
    # メール設定
    $smtpServer = "smtp.gmail.com"  # Gmailの場合
    $smtpPort = 587
    $smtpFrom = "user@gmail.com"  # 送信元
    $smtpTo = "recipient@example.com"  # 受信者
    $smtpUsername = "your_email@gmail.com"  # 送信元アカウント
    $smtpPassword = "your_app_password"  # Gmailアプリパスワード

    # メール内容の設定
    $subject = "価格の通知"
    $body = "商品価格が $price 円になりました。"

    # メール送信
    Send-MailMessage -SmtpServer $smtpServer -Port $smtpPort -From $smtpFrom -To $smtpTo -Subject $subject -Body $body -UseSsl -Credential (New-Object System.Management.Automation.PSCredential($smtpUsername, ($smtpPassword | ConvertTo-SecureString -AsPlainText -Force)))
}
