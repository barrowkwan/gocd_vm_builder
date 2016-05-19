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

import os
import sys
import shutil
import re

from cloudinit.settings import PER_INSTANCE
from cloudinit import util


frequency = PER_INSTANCE

def replace_config(goagent_file, goagent_key, goagent_value):
  found_key = False
  outputfile = open(goagent_file + ".tmp","w")
  if os.path.exists(goagent_file):
    inputfile = open(goagent_file,"r")
    for line in inputfile.readlines():
      if re.match('^'+goagent_key+'[\s]*=',line):
        found_key = True
        outputfile.write("%s=%s\n" % (goagent_key,goagent_value))
      else:
        outputfile.write(line)
  if not found_key:
    outputfile.write("%s=%s\n" % (goagent_key,goagent_value))
  outputfile.close()
  if os.path.exists(goagent_file):
    inputfile.close()
  shutil.move(goagent_file + ".tmp", goagent_file)


def handle(name, cfg, cloud, log, _args):
  try:

    # Make sure Go Agent is not running
    util.subp(['service', 'go-agent', 'stop'])

    # Go Agent Config Prefix
    go_agent_prefix = "goagent_"
    go_agent_default = "/etc/default/go-agent"
    
    go_server_prefix = "goserver_"
    go_server_config_dir = "/var/lib/go-agent/config"
    if not os.path.exists(go_server_config_dir):
      os.makedirs(go_server_config_dir)
      util.chownbyname(go_server_config_dir,"go","go")
    go_server_config = go_server_config_dir + "/autoregister.properties"


    md = cloud.datasource.metadata
    for key in md['meta']:
      if key.startswith(go_agent_prefix):
        replace_config(go_agent_default,key[len(go_agent_prefix):],md['meta'][key])
      elif key.startswith(go_server_prefix):
        replace_config(go_server_config,key[len(go_server_prefix):],md['meta'][key])
    
    replace_config(go_server_config,"agent.auto.register.elasticAgent.agentId",md['instance-id'])
        
    if os.path.exists(go_server_config):
      util.chownbyname(go_server_config,"go","go")

    if os.path.exists(go_agent_default):
      util.chmod(go_agent_default,0644)
    
    # Start Go Agent
    util.subp(['service', 'go-agent', 'start'])

  except:
    log.debug("Error configuring Go Agent")
    return
