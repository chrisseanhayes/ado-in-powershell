$client = new-object System.Net.Http.HttpClient
#accept header for json
$client.DefaultRequestHeaders.Accept.Clear()
$acceptjson = new-object System.Net.Http.Headers.MediaTypeWithQualityHeaderValue -ArgumentList "application/json"
$client.DefaultRequestHeaders.Accept.Add($acceptjson)

#auth header
$pat = $env:PAT
$base64authheader = [Convert]::ToBase64String([System.Text.ASCIIEncoding]::ASCII.GetBytes(":$pat"))
$auth = new-object System.Net.Http.Headers.AuthenticationHeaderValue -ArgumentList ("Basic", $base64authheader)
$client.DefaultRequestHeaders.Authorization = $auth

#url formatting
$organization = "chrisseanhayes"
$url = "https://dev.azure.com/$organization/_apis/projects?api-version=5.1"

#request
$response = $client.GetAsync($url).Result

$result = $response.Content.ReadAsStringAsync().Result

$result