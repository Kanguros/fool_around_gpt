param(
    [Parameter(Mandatory = $true)]
    [string]$MarkdownFilePath
)

function ExtractCodeSections($MarkdownFilePath) {
    $MarkdownContent = Get-Content -Path $MarkdownFilePath -Raw
    $CodeSections = [regex]::Matches($MarkdownContent, "(?sm)```(?<lang>\w+)\r?\n(?<code>.*?)\r?\n```")

    foreach ($CodeSection in $CodeSections) {
        $Language = $CodeSection.Groups["lang"].Value
        $Code = $CodeSection.Groups["code"].Value

        $FileName = "{0}_{1}.txt" -f $MarkdownFilePath, $Language
        $FilePath = Join-Path -Path (Split-Path -Parent $MarkdownFilePath) -ChildPath $FileName

        Write-Host "Saving $Language code to $FilePath"
        Set-Content -Path $FilePath -Value $Code
    }
}

ExtractCodeSections -MarkdownFilePath $MarkdownFilePath

#        .\extract-code.ps1 -MarkdownFilePath "C:\path\to\your\markdown-file.md"
