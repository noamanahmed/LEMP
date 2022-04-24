exists()
{
  command -v "$1" >/dev/null 2>&1
}

php_versions()
{
  php_versions_array=("8.1" "8.0" "7.4" "7.3" "7.2" "7.1" "7.0" "5.6" )
}
