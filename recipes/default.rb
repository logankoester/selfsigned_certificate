#
# Cookbook Name:: selfsigned_certificate
# Recipe:: default
#
# Copyright (C) 2013 Christophe Gravier, Universite Jean Monnet
#
# Licence : Apache 2.0 
#

# install openssl if not present

if node['platform'] == 'debian' || node['platform'] == 'ubuntu'
  apt_package "openssl" do
    action :install
  end
else
  package 'openssl' do
    action :install
  end
end

# create output dir
directory node['selfsigned_certificate']['destination'] do
    owner "root"
    group "root"
    mode 0755
    action :create
    recursive true
end

bash "selfsigned_certificate" do
  user "root"
  cwd node['selfsigned_certificate']['destination']
  code <<-EOH
    openssl genrsa -passout pass:#{node[:selfsigned_certificate][:sslpassphrase]} -out server.key 2048
    chmod 600 server.key
    openssl req -passin pass:#{node[:selfsigned_certificate][:sslpassphrase]} -new -key server.key -out server.csr
    openssl req -passin pass:#{node[:selfsigned_certificate][:sslpassphrase]} -subj "/C=#{node[:selfsigned_certificate][:country]}/ST=#{node[:selfsigned_certificate][:state]}/L=#{node[:selfsigned_certificate][:city]}/O=#{node[:selfsigned_certificate][:orga]}/OU=#{node[:selfsigned_certificate][:depart]}/CN=#{node[:selfsigned_certificate][:cn]}/emailAddress=#{node[:selfsigned_certificate][:email]}" -new -key server.key -out server.csr
    openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt
  EOH
end
