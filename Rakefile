#
# Copyright 2016 ThoughtWorks, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
 
require 'erb'
require 'fileutils'
require 'yaml'

namespace :gocd_vm_builder do

	task :init do
    vm_config = load_vm_config
    FileUtils.mkdir_p "#{vm_config['gocd_vm_builder']['output_dir']}"
    FileUtils.mkdir_p "#{vm_config['gocd_vm_builder']['packer_dir']}"
    FileUtils.mkdir_p "#{vm_config['gocd_vm_builder']['http_dir']}"
	end

	task :cleanup do
    vm_config = load_vm_config
    FileUtils.rm_rf Dir.glob("#{vm_config['gocd_vm_builder']['output_dir']}/*")
    FileUtils.rm_rf Dir.glob("#{vm_config['gocd_vm_builder']['http_dir']}/*")
    FileUtils.rm_rf Dir.glob("#{vm_config['gocd_vm_builder']['packer_dir']}/*")
	end
  
	task :default do
    Rake::Task["gocd_vm_builder:cleanup"].invoke
    Rake::Task["gocd_vm_builder:init"].invoke
    case ENV['TARGET'].nil? ? "not_exists" : ENV['TARGET']
    when 'centos'
      puts "Building CentOS VM"
      Rake::Task["gocd_vm_builder:centos_vm"].invoke()
    else
      puts "Nothing to build"
    end
  end
  

	task :centos_vm do

    vm_distro_version = ENV['VERSION'].nil? ? "" : ENV['VERSION']
    vm_target = ENV['TARGET'].nil? ? "" : ENV['TARGET']
    

    vm_config = load_vm_config
    centos_url=vm_config['centos'][vm_distro_version]['url']
		epel_url=vm_config['epel'][vm_distro_version.to_i.to_s]['url']
		centos_iso_url=vm_config['centos'][vm_distro_version]['iso_url']
		centos_iso_checksum=vm_config['centos'][vm_distro_version]['iso_checksum']
		centos_iso_checksum_type=vm_config['centos'][vm_distro_version]['iso_checksum_type']
    
    puts "Generate Kickstart Script"
		render_template("#{vm_config['gocd_vm_builder']['http_template_dir']}/#{vm_target}#{vm_distro_version.to_i.to_s}/ks.cfg.erb",
      "#{vm_config['gocd_vm_builder']['http_dir']}/ks.cfg",
      binding)

    puts "Generate Packer Configuration"
    render_template("#{vm_config['gocd_vm_builder']['packer_template_dir']}/#{vm_target}#{vm_distro_version.to_i.to_s}/packer.json.erb",
          "#{vm_config['gocd_vm_builder']['packer_dir']}/packer.json",
          binding)

    puts "Packer start building VM"
    output= %x{packer build "#{File.dirname(__FILE__)}"/"#{vm_config['gocd_vm_builder']['packer_dir']}"/packer.json}
    puts output

  end

end

def upload_openstack_image(options={})
  puts "gocd_agent => #{options[:gocd_agent]}"
end

def render_template(template, output, scope)
    tmpl = File.read(template)
    erb = ERB.new(tmpl, 0, "<>")
    File.open(output, "w") do |f|
        f.puts erb.result(scope)
    end
end
    
def load_vm_config
  if File.exists? "vm_config.yaml"
    YAML.load_file("vm_config.yaml")
  end
end


