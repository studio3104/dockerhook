require 'sinatra'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'dockerhook/app'
run DockerHook::App
