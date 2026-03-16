$port = 8080
$dir  = Split-Path -Parent $MyInvocation.MyCommand.Path

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()

Write-Host "サーバー起動中: http://localhost:$port/heic-converter.html"
Write-Host "終了するにはこのウィンドウを閉じてください"
Write-Host ""

Start-Process "http://localhost:$port/heic-converter.html"

$mime = @{
    html = "text/html"
    js   = "application/javascript"
    wasm = "application/wasm"
    css  = "text/css"
    png  = "image/png"
    jpg  = "image/jpeg"
}

while ($listener.IsListening) {
    $ctx  = $listener.GetContext()
    $req  = $ctx.Request
    $res  = $ctx.Response
    $path = $req.Url.LocalPath.TrimStart("/")
    if ([string]::IsNullOrEmpty($path)) { $path = "heic-converter.html" }

    $file = Join-Path $dir $path

    if (Test-Path $file) {
        $bytes = [System.IO.File]::ReadAllBytes($file)
        $ext   = [System.IO.Path]::GetExtension($file).TrimStart(".")
        $res.ContentType     = if ($mime[$ext]) { $mime[$ext] } else { "application/octet-stream" }
        $res.ContentLength64 = $bytes.Length
        $res.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
        $res.StatusCode = 404
    }
    $res.Close()
}
