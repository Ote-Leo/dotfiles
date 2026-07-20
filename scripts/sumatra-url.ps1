param (
	[string] $url
)

$uri = [System.Uri] $url
$localpath = $uri.LocalPath
