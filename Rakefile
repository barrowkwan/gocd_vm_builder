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


    upload_openstack_image({
      :packer_vm_version => vm_distro_version,
      :output_dir => vm_config['gocd_vm_builder']['output_dir'],
      :vm_target => vm_target,
      :gocd_agent => vm_config['gocd_vm_builder']['with_gocd_agent'],
      :cloud_init => vm_config['gocd_vm_builder']['with_cloud_init']
      })
      
  end

end

def upload_openstack_image(options={})
  
  puts "Upload the Image to OpenStack"
  get_image_list = "glance image-list --owner #{ENV['OS_TENANT_ID']} --property-filter packer_vm_version=#{options[:vm_target]}-#{options[:packer_vm_version]}  --property-filter gocd_agent=#{ENV['GOCD_AGENT'] || options[:gocd_agent]} --property-filter cloud_init=#{ENV['CLOUD_INIT'] || options[:cloud_init]}"
  get_image = IO.popen(get_image_list)
  output = get_image.readlines(sep="\n")
  get_image.close
  if output.size > 5
    fail "Glance found more than one image.  Please clean up the image before you run this task again"
  elsif output.size < 5
    puts "========================================================================"
    puts "Glance cannot found image to delete : #{ENV['OS_TENANT_ID']} packer_vm_version=#{options[:vm_target]}-#{options[:packer_vm_version]} gocd_agent=#{ENV['GOCD_AGENT'] || options[:gocd_agent]} cloud_init=#{ENV['CLOUD_INIT'] || options[:cloud_init]}\n#{output}"
    puts "========================================================================"
  else
    output.each do |line|
      image_data = line.split(/[|\s]+/)
      if image_data[6].eql?("active")
        remove_image_list = "glance image-delete #{image_data[1]}"
        remove_image = IO.popen(remove_image_list)
        check_result = remove_image.readlines
        remove_image.close
        get_image_list = "glance image-list --owner #{ENV['OS_TENANT_ID']} --property-filter packer_vm_version=#{options[:vm_target]}-#{options[:packer_vm_version]} --property-filter gocd_agent=#{ENV['GOCD_AGENT'] || options[:gocd_agent]} --property-filter cloud_init=#{ENV['CLOUD_INIT'] || options[:cloud_init]}"
        get_image = IO.popen(get_image_list)
        output = get_image.readlines(sep="\n")
        get_image.close
        fail "Glance cannot delete image with id #{image_data[1]}" unless output.size == 4
      end
    end
  end
  upload_image_cmd = "glance image-create --owner #{ENV['OS_TENANT_ID']} --name packer-#{options[:vm_target]}-#{options[:packer_vm_version]} --property vm_build_version=#{ENV['vm_build_version'] || "0.0"} --property packer_vm_version=#{options[:vm_target]}-#{options[:packer_vm_version]} --property gocd_agent=#{ENV['GOCD_AGENT'] || options[:gocd_agent]} --property cloud_init=#{ENV['CLOUD_INIT'] || options[:cloud_init]} --human-readable --disk-format qcow2 --is-public True --container-format bare --progress  --file #{options[:output_dir]}/#{options[:vm_target]}#{options[:packer_vm_version].to_i.to_s}/qemu-#{options[:vm_target]}#{options[:packer_vm_version]}-x86_64.img"
  puts upload_image_cmd
  upload_image = IO.popen(upload_image_cmd)
  output = upload_image.readlines(sep="\n")
  upload_image.close

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


