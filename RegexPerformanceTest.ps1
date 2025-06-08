function MeasurePerformance([scriptblock]$scriptBlock, [int]$loopCount, [string]$method, [System.Diagnostics.Stopwatch]$sw) {
    $sw.Restart()
    for ($j = 0; $j -lt $loopCount; $j++) {
        $scriptBlock.Invoke() | Out-Null
    }
    $sw.Stop()

    return [PSCustomObject]@{
        method = $method
        loopCount = $loopCount
        iteration = $i
        elapsedMs = [math]::Round($sw.Elapsed.TotalMilliseconds, 3)
    }
}

# テスト対象
$string = "The quick brown fox jumps over the lazy dog 1234567890" * 10
$pattern = '\d{10}'
$regexInstance = [regex]::new($pattern)
$compiledRegex = [regex]::new($pattern, [System.Text.RegularExpressions.RegexOptions]::Compiled)

# ループ回数と測定回数の設定
$loopCounts = @(10, 100, 1000, 10000)
$measurementCount = 100

# パフォーマンス測定のためのストップウォッチ
$stopWatch = [System.Diagnostics.Stopwatch]::new()

# 結果を格納するCSV
$outputPath = "regex_performance_results.csv"
if (Test-Path $outputPath) {
    Remove-Item $outputPath
}

for ($i = 0; $i -lt $measurementCount; $i++) {
    foreach ($loopCount in $loopCounts) {
        # 1. Staticメソッド
        MeasurePerformance -scriptBlock { 
            [regex]::IsMatch($string, $pattern) | Out-Null 
        } -loopCount $loopCount -method "Static" -sw $stopWatch | Export-Csv -Path $outputPath -NoTypeInformation -Append -Encoding UTF8

        # 2. インスタンスメソッド
        MeasurePerformance -scriptBlock {
            $regexInstance.IsMatch($string) | Out-Null
        } -loopCount $loopCount -method "Instance" -sw $stopWatch | Export-Csv -Path $outputPath -NoTypeInformation -Append -Encoding UTF8

        # 3. Compiled オプション付きインスタンス
        MeasurePerformance -scriptBlock {
            $compiledRegex.IsMatch($string) | Out-Null
        } -loopCount $loopCount -method "Compiled" -sw $stopWatch | Export-Csv -Path $outputPath -NoTypeInformation -Append -Encoding UTF8
    }
}
