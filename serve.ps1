# Throwaway static file server for local testing (no Python/Node on this machine).
$root = "C:\Claude\Personal\Training dashboard"
$port = 8123

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
try {
    $listener.Start()
} catch {
    Write-Output "FAILED to start listener: $($_.Exception.Message)"
    exit 1
}
Write-Output "Serving $root on http://localhost:$port/"

$types = @{
    ".html" = "text/html; charset=utf-8"
    ".js"   = "text/javascript; charset=utf-8"
    ".json" = "application/json; charset=utf-8"
    ".css"  = "text/css; charset=utf-8"
    ".md"   = "text/plain; charset=utf-8"
}

while ($listener.IsListening) {
    try {
        $context = $listener.GetContext()
        $rel = [System.Uri]::UnescapeDataString($context.Request.Url.AbsolutePath.TrimStart("/"))
        if ([string]::IsNullOrWhiteSpace($rel)) { $rel = "index.html" }
        $path = Join-Path $root $rel

        if (Test-Path $path -PathType Leaf) {
            $ext = [System.IO.Path]::GetExtension($path).ToLower()
            $ct = $types[$ext]
            if (-not $ct) { $ct = "application/octet-stream" }
            $bytes = [System.IO.File]::ReadAllBytes($path)
            $context.Response.ContentType = $ct
            $context.Response.Headers.Add("Cache-Control", "no-store")
            $context.Response.ContentLength64 = $bytes.Length
            $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
            Write-Output "200 $rel"
        } else {
            $context.Response.StatusCode = 404
            $msg = [System.Text.Encoding]::UTF8.GetBytes("not found: $rel")
            $context.Response.OutputStream.Write($msg, 0, $msg.Length)
            Write-Output "404 $rel"
        }
        $context.Response.OutputStream.Close()
    } catch {
        Write-Output "ERR $($_.Exception.Message)"
    }
}
