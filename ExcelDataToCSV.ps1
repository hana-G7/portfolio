# インスタンス作成
$excel = New-Object -ComObject Excel.Application

# Excelを非表示
$excel.Visible = $false

# 'sample.xlsx' Excelファイル名
$filePath = "C:\Users\user\sample.xlsx" 
$workbook = $excel.Workbooks.Open($filePath)

# エクセルシートの番号を()に入力
$worksheet = $workbook.Sheets.Item(1)

# 配列を初期化
$data = @()

# 例: B列(2)、C列(3)、D列(4)のデータを取得
$row = 2  # Excelのデータが入力されている最初の行番号行
while ($worksheet.Cells.Item($row, 2).Value2 -ne $null) {
    $bValue = $worksheet.Cells.Item($row, 2).Value2
    $cValue = $worksheet.Cells.Item($row, 3).Value2
    $dValue = $worksheet.Cells.Item($row, 4).Value2
    
    # 取得したデータを配列に格納
    $data += [PSCustomObject]@{
        Column1 = $bValue
        Column2 = $cValue
        Column3 = $dValue
    }
    
    # 次の行に進む
    $row++
}

# Excelファイルを閉じる
$workbook.Close($false)  # 変更を保存せずに閉じる
$excel.Quit()

# CSVファイルとして保存（'data.csv'）
$csvPath = "C:\Users\user\data.csv"  # 保存先パス
$data | Export-Csv -Path $csvPath -NoTypeInformation

# メッセージ
Write-Host "CSVファイルが作成されました: $csvPath"
