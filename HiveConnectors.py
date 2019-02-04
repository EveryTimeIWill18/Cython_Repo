# -*- coding: utf-8 -*-
"""
Created on Wed Jan 30 08:22:33 2019

@author: wmurphy

RemoteControl
=============
This module is used to pass commands to a remote server.
Specifically, it will be used to pass commands to hive.


"""
import sys
import os
import io
import configparser
import socket
import socks
import paramiko
import fabric


class HiveConnection:
    """
    HiveConnection
    --------------
    Create a conection to the linux server that
    hosts our hadoop file system(hdfs).
    """
    def __init__(self):
        self.hive_connection = None
        
    
    def load_config_file(self, path_: str, config_file: str) -> None:
        """
        Import the config file.
        
        :return:
        """
        try:
            if os.path.exists(path_):
                if os.path.isfile(os.path.join(path_, config_file)):
                    
                    # - load in a configuration file
                    config = configparser.ConfigParser()
                    config.read(os.path.join(path_, config_file))
                    sections = config.sections()
                    
                    # - import the configuration data
                    host = config.get(sections[1], 'HOST')
                    port = config.get(sections[1], 'PORT')
                    un = config.get(sections[1], 'USERNAME')
                    pw = config.get(sections[1], 'PASSWORD')
                    
                    # - attempt a connection to the remote server
                    self.hive_connection = fabric \
                                    .connection \
                                    .Connection(host=host, user=un, port=port,
                                    connect_kwargs={"password": pw})
                    # - open the connection
                    self.hive_connection.open()
                    # - test output
                    print(self.hive_connection.run('hive -e "show databases;"'))
                    
                else:
                    print("File: {} not found".format(config_file))
            else:
                raise OSError("OSError: Path: {} not found".format(path_))
                
        except OSError as e:
            print(e)
        finally:
            pass
        
        
hive_con = HiveConnection()
fp = "C:\\Users\\wmurphy\\Claims\\Networking"
f = "ssh.ini"
hive_con.load_config_file(fp, f)
        
