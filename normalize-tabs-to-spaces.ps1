foreach ($ext in @("*.cs")) {
    (dir -Recurse -Filter $ext) | foreach {
        Get-Content $_.FullName | Expand-Tab 4 | Out-File $_.FullName
    }
}

# See http://windowsitpro.com/powershell/expanding-tabs-spaces-powershell
function Expand-Tab {
  param([UInt32] $TabWidth)
  process {
    $line = $_
    while ( $TRUE ) {
      $i = $line.IndexOf([Char] 9)
      if ( $i -eq -1 ) { break }
      if ( $TabWidth -gt 0 ) {
        $pad = " " * ($TabWidth - ($i % $TabWidth))
      } else {
        $pad = ""
      }
      $line = $line -replace "^([^\t]{$i})\t(.*)$", "`$1$pad`$2"
    }
    $line
  }
}
